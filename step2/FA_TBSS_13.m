%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%   Process FA data using FSL/TBSS_1 on BIOS Sever     %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% March  8, 2016 @ by CH

clear all;


FDTDir = '/your/work/path/TBSS_pipeline/';               % directory containing the data folder and other files.  you need to change the directory accordingly

raw_dir = fullfile(FDTDir,'TBSS/FA');

codedir=fullfile(FDTDir,'code');
mkdir(codedir);
delete(fullfile(codedir,'*'));


fid2 = fopen(sprintf('%s/tbss_13.sh',codedir),'w');
fprintf(fid2,'#!/bin/bash\n');
fprintf(fid2,'module load fsl\n');
fprintf(fid2,'module load python/2.7.12\n');
fprintf(fid2,'export FSLDIR=/nas/longleaf/apps/fsl/5.0.9/fsl/\n');
fprintf(fid2,'source ${FSLDIR}/etc/fslconf/fsl.sh\n');
fprintf(fid2,'export PATH=${FSLDIR}/bin:${PATH}\n');
fprintf(fid2,'mkdir %sTBSS/FAtbss/QC_Reg\n',FDTDir);
fprintf(fid2,'cd %sTBSS/FAtbss\n',FDTDir);
fprintf(fid2,'cp ./FA2ENIGMAtemplate/*_FA_to_target.nii.gz ./QC_Reg\n');
fprintf(fid2,'cd %sTBSS/FAtbss/QC_Reg/\n',FDTDir);
fprintf(fid2,'$FSLDIR/bin/slicesdir `$FSLDIR/bin/imglob *_FA_to_target.*` > grot 2>&1\n');
fprintf(fid2,'cat grot | tail -n 2\n');
fprintf(fid2,'/bin/rm grot\n');
fclose(fid2);
