#!/bin/bash

#set -euf -o pipefail
cd /Users/vgonzenb/PennSIVE/mscamras

for h5 in $(find $(pwd) -name "*.h5" -type f | grep -v .git); do

    # TODO: change output directory to parent after QC
    
    #if 
        fn=$(basename $h5 .h5)
        dir=$(dirname $h5)

        subj=$(echo $dir | grep -Eo [0-9]+-[0-9]+)
        site=$(echo $dir | grep -Eo "${subj}-[A-Za-z]+" | cut -d- -f3)

        modality=$(echo $fn | cut -d_ -f4,5,6) 

        mid=$(echo $fn | cut -d_ -f2 | sed 's/MID//g')
        other_fn=$(ls $dir/*.h5 | grep $modality | grep -v $fn)
        
        if [ "$other_fn" == "" ]; then 
            echo $h5 could not be paired with a reference >> logs/h5_nii.log
            continue # end current iteration here
        fi
        
        other_mid=$(echo $(basename $other_fn) | cut -d_ -f2 | sed 's/MID//g')
        if [ "$mid" -gt "$other_mid" ]; then
            # echo "$h5 must be scan 2 since numbers in filename greater than other raw data file: ${other_fn}"
            suffix="a"
        else
            # echo "$h5 must be scan 1 since numbers in filename less than other raw data file: ${other_fn}"
            suffix=""
        fi
        reference_nifti=data/Data/${subj}/${site}/NIFTI/${modality}_ND${suffix}.nii.gz
        
        out_nifti=$(dirname $h5)/$(basename $h5 .h5)_ND${suffix}.nii.gz
        if [ ! -e $out_nifti ]; then
        echo Running conversion on $h5 and $reference_nifti. Saving output to $out_nifti >> logs/h5_nii.log
            /opt/miniconda3/envs/fmri/bin/python3 gadgetron-code/h5_to_nifti.py $h5 $reference_nifti $out_nifti
        fi
done
