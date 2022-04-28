#!/bin/bash

#set -euf -o pipefail
cd /Users/vgonzenb/PennSIVE/mscamras

for h5 in $(find $(pwd) -name "*.h5" -type f | grep -v .git); do
    #h5=$(dirname $dat)/$(basename $dat .dat).h5
    out_nifti=$(dirname $h5)/$(basename $h5 .h5).nii.gz # TODO: change output directory to parent after QC
    
    if [ ! -e $out_nifti ]; then
        fn=$(basename $h5)
        dir=$(dirname $h5)
        mid=$(echo $fn | grep -Eo "MID[0-9]+" | grep -Eo "[0-9]+")
        modality=$(echo $fn | grep -Eo "[A-Z_]+\.h5")
        other_fn=$(ls $dir | grep -Eo "meas_MID[0-9]+_FID[0-9]+${modality}" | sort | uniq | grep -v $fn)
        other_mid=$(echo $other_fn | grep -Eo "MID[0-9]+" | grep -Eo "[0-9]+")
        if [ "$mid" -gt "$other_mid" ]; then
            # echo "$h5 must be scan 2 since numbers in filename greater than other raw data file: ${other_fn}"
            suffix="a"
        else
            # echo "$h5 must be scan 1 since numbers in filename less than other raw data file: ${other_fn}"
            suffix=""
        fi
        just_modality=$(basename $(basename $(echo $modality | cut -d"_" -f2,3,4) .h5) .dat)
        reference_nifti=data/Data/$(echo $dir | grep -Eo [0-9]+-[0-9]+)/$(echo $dir | grep -Eo [0-9]+-[0-9]+-[A-Za-z]+/ | grep -Eo [A-Za-z]+/)NIFTI/${just_modality}_ND${suffix}.nii.gz
        #bsub -J h5nifti_"$i" -o ../logs/h5_to_nifti.log -e ../logs/h5_to_nifti.log 
        # singularity exec -B /project --cleanenv ~/simg/neuropythy_latest.sif
        /opt/miniconda3/envs/fmri/bin/python3 gadgetron-code/h5_to_nifti.py $h5 $reference_nifti $out_nifti
    fi
done
