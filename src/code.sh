#!/bin/bash
# eggd_calc_downsample_fraction 

set -e -x -o pipefail

main() {
    dx-download-all-inputs

    # Tests for file type
    FILE_TEST_OUTPUT=$(file --brief "$flagstat_path")
    if [[ $FILE_TEST_OUTPUT == "JSON data"* ]]; then
        READ_COUNT=$(jq -r '."QC-passed reads" | ."total"' "$flagstat_path")
    elif [[ $FILE_TEST_OUTPUT == "ASCII text"* ]]; then
        READ_COUNT=$(grep "total" "$flagstat_path" | awk '{print $1}')
    else
        echo "Unsupported flagstat format: ${FILE_TEST_OUTPUT}" >&2
        exit 1
    fi

    # Tests for file integrity
    if [ -z "$READ_COUNT" ]; then
        echo "ERROR: Read count could not be parsed from flagstat file input. Please check the validity of $flagstat_name"
        exit 1
    elif ! [[ "$READ_COUNT" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Read count value parsed from flagstat is not numeric: $READ_COUNT" >&2
        exit 1
    elif [[ "$READ_COUNT" -eq 0 ]]; then
        echo "ERROR: samtools flagstat reports zero reads in input BAM. Cannot calculate downsampling fraction." >&2
        exit 1
    fi

    # Only do calculation if target < actual
    if (( target_read_count > READ_COUNT )); then
        echo "WARNING: Requested read count is greater than maximum possible for this file. Requested: $target_read_count; N reads in BAM: $READ_COUNT. Setting fraction to 1.0"
        TARGET_FRACTION="1.0"
    elif (( target_read_count == READ_COUNT )); then
        echo "INFO: Requested read count is equal to number of reads found in file."
        TARGET_FRACTION="1.0"
    else
        TARGET_FRACTION=$(bc -l <<< "scale=3; $target_read_count / $READ_COUNT")
    fi
    echo "$TARGET_FRACTION" > target_fraction.txt

    OUTPUT_FILE_ID=$(dx upload --brief target_fraction.txt)
    dx-jobutil-add-output "target_fraction_file" "$OUTPUT_FILE_ID" --class="file"
    dx-jobutil-add-output "target_fraction_float" "$TARGET_FRACTION" --class="float"
}
