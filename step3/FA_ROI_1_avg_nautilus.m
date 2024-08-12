%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%   Process FA data using FSL/TBSS_2-3 on BIOS Sever     %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% March  8, 2016 @ by CH

clear all;


FDTDir = '/your/work/path/TBSS_pipeline/';               % PATH to change

raw_dir = fullfile(FDTDir,'TBSS/FAtbss');
codedir = fullfile(FDTDir,'code');
mkdir(codedir);
delete(fullfile(codedir,'*'));



subNames = dir(fullfile(raw_dir,'/origdata'));  
subNames = {subNames.name}';
subNames = subNames(3:end); % first two are sup-directory and current one

nn = size(subNames,1);

fid2 = fopen(sprintf('%s/FA_ROI_1_avg.sh',codedir),'w');
fprintf(fid2,'#!/bin/bash\n');
%fprintf(fid2,'#SBATCH --ntasks=1\n');
%fprintf(fid2,'#SBATCH --time=23:59:59\n');
%fprintf(fid2,'#SBATCH --mem=8000\n');
%fprintf(fid2,'#SBATCH --wrap=TBSS\n');
fprintf(fid2,'module load fsl\n');
fprintf(fid2,'module load python/2.7.12\n');
fprintf(fid2,'export FSLDIR=/nas/longleaf/apps/fsl/5.0.9/fsl/\n');
fprintf(fid2,'source ${FSLDIR}/etc/fslconf/fsl.sh\n');
fprintf(fid2,'export PATH=${FSLDIR}/bin:${PATH}\n');  
fprintf(fid2,'cd %s\n',fullfile(FDTDir,'TBSS','Enigma_ROI_1'));
fprintf(fid2,'chmod 775 singleSubjROI_exe\n');
fprintf(fid2,'chmod 775 averageSubjectTracts_exe\n');
for ii=1:nn
    ID=subNames{ii};
    fprintf(fid2,'./singleSubjROI_exe ENIGMA_look_up_table.txt mean_FA_skeleton.nii.gz JHU-WhiteMatter-labels-1mm.nii.gz');
    fprintf(fid2,' %s_ROIout %s/FA_individ/%s/stats/%s_*_FAskel.nii.gz\n',ID(1:(end-10)),raw_dir,ID(1:(end-10)),ID(1:(end-10)));
    fprintf(fid2,'./averageSubjectTracts_exe %s_ROIout.csv avg_%s_ROIout.csv\n',ID(1:(end-10)),ID(1:(end-10)));
end 

fclose(fid2);
