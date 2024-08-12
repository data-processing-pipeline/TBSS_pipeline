#!/bin/bash
export Home=/your/work/path/TBSS_pipeline/TBSS/FAtbss/FA/ # PATH to change
cd ${Home}
module load fsl
module load python/2.7.12
export FSLDIR=/nas/longleaf/apps/fsl/5.0.9/fsl/
source ${FSLDIR}/etc/fslconf/fsl.sh
export PATH=${FSLDIR}/bin:${PATH}
$FSLDIR/bin/slicesdir `$FSLDIR/bin/imglob *_masked_FA.*` > grot 2>&1
cat grot | tail -n 2
/bin/rm grot
