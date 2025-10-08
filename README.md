<!-- dx-header -->
# eggd_calc_downsample_fraction (DNAnexus Platform App)

<!-- Insert a description of your app here -->
## What does this app do?
This app returns the fraction required to reach the desired read counts when downsampling a BAM file with `picard DownsampleSam`.

## What are the typical use cases for this app?
This app will usually be used as part of a workflow that requires BAM downsampling with `picard DownsampleSam`. The app
is intended to convert a known desired read count into a fractional value to be passed to `picard`.

## What are the inputs?
- `-iflagstat`: The output from running `samtools flagstat` on the target BAM file
- `-itarget_read_count`: The desired count of reads after downsampling

## What are the outputs?
- `target_fraction_float`: A floating point number representing the downsampling fraction required to reach the desired read counts
- `target_fraction_file`: A file containing the `target_fraction_float`

## How to run this app from command line?
```
dx run app-eggd_calc_downsample_fraction \
  -iflagstat=<FILE_ID> \
  -itarget_read_count=<INT>
```

### This app was made by EMEE GLH
