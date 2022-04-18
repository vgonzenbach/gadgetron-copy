#!/bin/bash

set -euf -o pipefail
cd $(dirname "$0")/..
project_dir=/project/mscamras/gadgetron
get_port="import socket; s=socket.socket(); s.bind(('', 0)); print(s.getsockname()[1]); s.close()"
TMPDIR=/scratch/

i=0
for dat in $(find datasets -name "*.dat" -type f | grep -v .git); do
    outdir=$(dirname $dat)
    outfile=$(basename $dat .dat).h5
    cd $outdir
    if [ ! -e $outfile ]; then
        port1=$(echo $get_port | python3)
        port2=$(echo $get_port | python3)
        port3=$(echo $get_port | python3)
        site=$(echo $outdir | rev | cut -d"-" -f1 | rev)
        if [ $site = 'Hopkins' ]; then
            script=philips_recon.sh
        else
            script=siemens_recon.sh
        fi
        #datalad run -i "*" -o "*" -m "reconstructing ${outdir}" \
        #"timeout --signal=KILL 3h \
        singularity run --cleanenv --writable-tmpfs -B $TMPDIR:/var/run -B $TMPDIR:/tmp -B $TMPDIR -B $TMPDIR:/var/log/supervisor -B $PWD:/opt/data -B $project_dir --pwd /opt/data ~/simg/ubuntu_1404_cuda75_latest.sif $project_dir/code/$script $(basename $dat) $port1 $port2 $port3 || true 
        mv out.h5 $outfile || true
        rm core.* || true
        rm noise.h5 || true 
        rm data.h5 || true
        #datalad save -r -m "reconstructed ${outdir}" || true
        ((++i))
    fi
    cd $project_dir
done

