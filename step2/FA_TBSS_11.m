%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%   Process FA data using FSL/TBSS_1 on BIOS Sever     %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% March  8, 2016 @ by CH

clear all;

FDTDir = '/your/work/path/TBSS_pipeline/';     %PATH to change         

raw_dir = fullfile(FDTDir,'TBSS/FA');
codedir=fullfile(FDTDir,'code');
mkdir(codedir);
delete(fullfile(codedir,'*'));

fid2 = fopen(sprintf('%s/tbss_1.pbs',codedir),'w');



fprintf(fid2,'#!/bin/bash\n');
fprintf(fid2,'#SBATCH --ntasks=1\n');
fprintf(fid2,'#SBATCH --time=23:59:59\n');
fprintf(fid2,'#SBATCH --mem=8000\n');
fprintf(fid2,'#SBATCH --wrap=TBSS\n');
fprintf(fid2,'module load fsl\n');
fprintf(fid2,'module load python/2.7.12\n');
fprintf(fid2,'export FSLDIR=/nas/longleaf/apps/fsl/5.0.9/fsl/\n');
fprintf(fid2,'source ${FSLDIR}/etc/fslconf/fsl.sh\n');
fprintf(fid2,'export PATH=${FSLDIR}/bin:${PATH}\n');
fprintf(fid2,'mkdir %sTBSS/FAtbss\n',FDTDir);
fprintf(fid2,'cp %s/*_FA.nii.gz %sTBSS/FAtbss/\n',raw_dir,FDTDir);
fprintf(fid2,'cd %sTBSS/FAtbss\n',FDTDir);
fprintf(fid2,'tbss_1_preproc *.nii.gz\n');
fprintf(fid2,'mkdir %sTBSS/FAtbss/FA2ENIGMAtemplate\n',FDTDir);
fprintf(fid2,'cp %sTBSS/FAtbss/FA/*_FA_FA.nii.gz %sTBSS/FAtbss/FA2ENIGMAtemplate\n',FDTDir,FDTDir);
fclose(fid2);

