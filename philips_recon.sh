#!/bin/bash

set -e
# $1 = .dat filename
# $2 = port 1
# $3 = port 2
# $4 = port 3

RUNTIME=2h # expected runtime for all processing steps is 1h... this is 2x the expectation
timeout --signal=KILL $RUNTIME gadgetron -p $2 -l $3 -R $4 &
echo "Converting data at $(date)"
philips_to_ismrmrd -f /opt/data/$1 -o /opt/data/data.h5
echo "Processing data with gadgetron at $(date)"
gadgetron_ismrmrd_client -p $2 -f /opt/data/data.h5 -c Generic_Cartesian_Grappa.xml -G test
# gadgetron_ismrmrd_client -p $2 -f /opt/data/data.h5 -c Generic_Cartesian_Grappa_SNR.xml -G test
# gadgetron_ismrmrd_client -p $2 -f /opt/data/data.h5 -c Generic_Cartesian_Grappa_SNR_dicom.xml -G test
echo "done at $(date)"

