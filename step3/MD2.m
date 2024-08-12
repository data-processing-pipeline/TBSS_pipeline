%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Process MRI data using dqshtc Group Analysis on BIOS Sever   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% March 19, 2012 @ by LLK
% Jan    8, 2015 @ by CH
% May   17, 2016 @ by TFL

clear all;

home_dir = '/your/work/path/TBSS_pipeline/';               % PATH to change
home_dir1 = fullfile(home_dir,'TBSS');
home_dir2= fullfile(home_dir1,'MD');
codedir=fullfile(home_dir,'code');
mkdir(codedir);
delete(fullfile(codedir,'*'));
FSLDIR = '/nas/longleaf/apps/fsl/5.0.9/fsl/';


dtifit_folder=home_dir1;
ENIGMAtemplateDirectory= fullfile(home_dir1,'ENIGMA_targets');
parentDirectory=fullfile(home_dir1,'FAtbss');
runDirectory=fullfile(home_dir1,'Enigma_ROI_1');



mkdir(fullfile(parentDirectory,'MD_individ','MD_ENIGMA_ROI_part1')); 
mkdir(fullfile(parentDirectory,'V1_individ','V1_ENIGMA_ROI_part1')); 
mkdir(fullfile(parentDirectory,'L1_individ','L1_ENIGMA_ROI_part1')); 
mkdir(fullfile(parentDirectory,'L2_individ','L2_ENIGMA_ROI_part1')); 
mkdir(fullfile(parentDirectory,'L3_individ','L3_ENIGMA_ROI_part1')); 
mkdir(fullfile(parentDirectory,'MO_individ','MO_ENIGMA_ROI_part1')); 

mkdir(fullfile(parentDirectory,'MD_individ','MD_ENIGMA_ROI_part2')); 
mkdir(fullfile(parentDirectory,'V1_individ','V1_ENIGMA_ROI_part2')); 
mkdir(fullfile(parentDirectory,'L1_individ','L1_ENIGMA_ROI_part2')); 
mkdir(fullfile(parentDirectory,'L2_individ','L2_ENIGMA_ROI_part2')); 
mkdir(fullfile(parentDirectory,'L3_individ','L3_ENIGMA_ROI_part2')); 
mkdir(fullfile(parentDirectory,'MO_individ','MO_ENIGMA_ROI_part2')); 


subj = dir(home_dir2);        
subj = {subj.name}';
subj = subj(3:end); % first two are sup-directory and current one
temp = cellfun(@(x)strsplit(x,'_MD'),subj,'UniformOutput',0);
subj = cellfun(@(x)x(1),temp,'UniformOutput',0);
nn = size(subj,1);

fid0 = fopen(sprintf('%s/FS_batAll.sh',codedir),'w');
fprintf(fid0,'#!/bin/bash\n');

%MD={'MD','V1','V2','V3','L1','L2','L3','MO','S0'};
MD={'MD','L1','L2','L3','MO'};

N=40;
K=ceil(nn/N);

for kk=1:K
    batNames = sprintf('%s/FS_bat%i.pbs',codedir,kk);
    fid = fopen(batNames,'w'); 
    fprintf(fid,'#!/bin/bash\n');
    fprintf(fid,'#SBATCH --ntasks=1\n');
    fprintf(fid,'#SBATCH --time=01:00:0\n');
    fprintf(fid,'#SBATCH --mem=8000\n');
    fprintf(fid,'#SBATCH --wrap=TBSS_%i\n',kk);
    fprintf(fid,'module load fsl\n');
    fprintf(fid,'module load python/2.7.12\n');
    fprintf(fid,'export FSLDIR=/nas/longleaf/apps/fsl/5.0.9/fsl/\n');
    fprintf(fid,'source ${FSLDIR}/etc/fslconf/fsl.sh\n');
    fprintf(fid,'export PATH=${FSLDIR}/bin:${PATH}\n');
    
    fprintf(fid,'export ENIGMAtemplateDirectory=%s\n',ENIGMAtemplateDirectory);
    fprintf(fid,'export parentDirectory=%s\n',parentDirectory);
    fprintf(fid,'export dtifit_folder=%s\n',dtifit_folder);
    fprintf(fid,'export runDirectory=%s\n',runDirectory);
    
    for ii=min(kk*N,nn)+((kk-1)*N+1)-(((kk-1)*N+1):min(kk*N,nn))
    subjj=subj{ii};subjj=subjj{1};
for jj=1:length(MD)
    dir01=sprintf('%s/%s_individ/%s_ENIGMA_ROI_part1/',parentDirectory,MD{jj},MD{jj});
    dir02=sprintf('%s/%s_individ/%s_ENIGMA_ROI_part2/',parentDirectory,MD{jj},MD{jj});
    fprintf(fid,'export dirO1=%s\n',dir01);fprintf(fid,'export dirO2=%s\n',dir02);
    fprintf(fid,'%s/singleSubjROI_exe %s/ENIGMA_look_up_table.txt %s/mean_FA_skeleton.nii.gz %s/JHU-WhiteMatter-labels-1mm.nii.gz %s/%s_%s_ROIout %s/%s_individ/%s/stats/%s_masked_%sskel.nii.gz\n', ...,
        runDirectory,runDirectory,runDirectory,runDirectory,  dir01,subjj,MD{jj}, parentDirectory,MD{jj},subjj,subjj,MD{jj});
    fprintf(fid,'%s/averageSubjectTracts_exe %s/%s_%s_ROIout.csv %s/%s_%s_ROIout_avg.csv\n',runDirectory,dir01,subjj,MD{jj}, dir02,subjj,MD{jj});
end
    end
fclose(fid);
fprintf(fid0,'sbatch FS_bat%i.pbs\n',kk);
end

fclose(fid0);

clear all;
