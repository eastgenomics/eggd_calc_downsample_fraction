#!/bin/bash
# eggd_calc_downsample_fraction 

set -e -x -o pipefail

main() {
    dx-download-all-inputs

    FILE_TEST_OUTPUT=$(file --brief "$flagstat_path")
    if [[ $FILE_TEST_OUTPUT == "JSON data" ]]; then
        READ_COUNT=$(jq -r '."QC-passed reads" | ."primary"' "$flagstat_path")
    elif [[ $FILE_TEST_OUTPUT == "ASCII text" ]]; then
        READ_COUNT=$(grep "primary$" "$flagstat_path" | cut -f1)
    fi

    TARGET_FRACTION=$(bc -l <<< "scale=3; $target_read_count / $READ_COUNT")
    if (( $(echo "$TARGET_FRACTION < 1" | bc -l) )); then
        # if the result is less than 1.0, bc won't add a leading zero
        # so we add it ourselves
        TARGET_FRACTION="0$TARGET_FRACTION"
    elif (( $(echo "$TARGET_FRACTION > 1" | bc -l) )); then
        echo "Something's gone wrong"
        exit 1
    fi
    echo "$TARGET_FRACTION" > target_fraction.txt

    OUTPUT_FILE_ID=$(dx upload --brief target_fraction.txt)
    dx-jobutil-add-output "target_fraction_file" "$OUTPUT_FILE_ID"
    dx-jobutil-add-output "target_fraction_float" "$TARGET_FRACTION"
}
