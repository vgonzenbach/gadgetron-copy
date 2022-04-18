#!/bin/bash

set -euf -o pipefail
cd $(dirname "$0")/../datasets

for dat in $(find . -name "*.dat" -type l); do
    h5=$(dirname $dat)/$(basename $dat .dat).h5
    if [ ! -e $h5.nii.gz ]; then
        fn=$(basename $h5)
        dir=$(dirname $h5)
        mid=$(echo $fn | grep -Eo "MID[0-9]+" | grep -Eo "[0-9]+")
        # fid=$(echo $fn | grep -Eo "FID[0-9]+" | grep -Eo "[0-9]+")
        modality=$(echo $fn | grep -Eo "[A-Z_]+\.dat\.h5")
        other_fn=$(ls $dir | grep -Eo "meas_MID[0-9]+_FID[0-9]+${modality}" | sort | uniq | grep -v $fn)
        other_mid=$(echo $other_fn | grep -Eo "MID[0-9]+" | grep -Eo "[0-9]+")
        # other_fid=$(echo $other_fn | grep -Eo "FID[0-9]+" | grep -Eo "[0-9]+")
        if [ "$mid" -gt "$other_mid" ]; then
            # echo "$h5 must be scan 2 since numbers in filename greater than other raw data file: ${other_fn}"
            suffix="a"
        else
            # echo "$h5 must be scan 1 since numbers in filename less than other raw data file: ${other_fn}"
            suffix=""
        fi
        just_modality=$(basename $(basename $(echo $modality | cut -d"_" -f2,3,4) .h5) .dat)
        reference_nifti=../../../Data/$(echo $dir | grep -Eo [0-9]+-[0-9]+)/$(echo $dir | grep -Eo [A-Za-z]+)/NIFTI/${just_modality}${suffix}.nii.gz
        singularity exec --cleanenv ~/simg/neuropythy_latest.sif python ../code/h5_to_nifti.py $h5 $reference_nifti $h5.nii.gz
    fi
done
