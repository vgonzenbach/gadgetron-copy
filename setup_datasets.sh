#!/bin/bash

set -euf -o pipefail # be safe

cd $(dirname "$0") # the dir this scripts in, currently /project/mscamras/repos/gadgetron/code
cd ..
project_dir=$PWD
ls datasets || datalad create -d . datasets
dat_dirs=$(find ../../Data -name raw_data -type d) # to copy in datalad dataset

for dir in $dat_dirs; do
    outdir=datasets/$(echo $dir | cut -d"/" -f4,5 | tr "/" "-")
    if [ ! -d $outdir ]; then
        datalad create -d datasets $outdir
        for potential_dat in $(find $dir -type f); do
            ftype=$(file $potential_dat | cut -d":" -f2)
            if [ $ftype = 'data' ]; then
                fsize=$(du $potential_dat | cut -f1)
                if [ $fsize -gt 2000000 ]; then
                    outfile=$(basename $potential_dat)
                    echo "cp $potential_dat $outdir/$outfile.dat"
                    cp $potential_dat $outdir/$outfile.dat
                    cd $outdir
                    datalad save -m "copied in raw data"
                    cd $project_dir
                fi
            fi
        done
    fi
done

