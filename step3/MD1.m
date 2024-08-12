%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Process MRI data using dqshtc Group Analysis on BIOS Sever   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% March 19, 2012 @ by LLK
% Jan    8, 2015 @ by CH
% May   17, 2016 @ by TFL

clear all;

home_dir = '/your/work/path/TBSS_pipeline/';               % PATH to change
home_dir1=fullfile(home_dir,'TBSS');
home_dir2= fullfile(home_dir1,'MD');
codedir=fullfile(home_dir,'code');
mkdir(codedir);
delete(fullfile(codedir,'*'));
FSLDIR = '/nas/longleaf/apps/fsl/5.0.9/fsl/';


dtifit_folder=home_dir1;
ENIGMAtemplateDirectory= fullfile(home_dir1,'ENIGMA_targets');
parentDirectory=fullfile(home_dir1,'FAtbss');



mkdir(fullfile(parentDirectory,'MD'));
%mkdir(fullfile(parentDirectory,'V1')); 
%mkdir(fullfile(parentDirectory,'V2')); 
%mkdir(fullfile(parentDirectory,'V3')); 
mkdir(fullfile(parentDirectory,'L1')); 
mkdir(fullfile(parentDirectory,'L2')); 
mkdir(fullfile(parentDirectory,'L3')); 
mkdir(fullfile(parentDirectory,'MO')); 


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
    fprintf(fid,'#SBATCH --time=10:00:00\n');
    fprintf(fid,'#SBATCH --mem=8000\n');
    fprintf(fid,'#SBATCH --wrap=TBSS_%i\n',kk);
    fprintf(fid,'module load fsl\n');
    fprintf(fid,'module load python/2.7.12\n');
    fprintf(fid,'export FSLDIR=%s\n',FSLDIR);
    fprintf(fid,'source ${FSLDIR}/etc/fslconf/fsl.sh\n');
    fprintf(fid,'export PATH=${FSLDIR}/bin:${PATH}\n');
    
    fprintf(fid,'export ENIGMAtemplateDirectory=%s\n',ENIGMAtemplateDirectory);
    fprintf(fid,'export parentDirectory=%s\n',parentDirectory);
    fprintf(fid,'export dtifit_folder=%s\n',dtifit_folder);
    fprintf(fid,'cd %s\n',parentDirectory);
	
	for ii=min(kk*N,nn)+((kk-1)*N+1)-(((kk-1)*N+1):min(kk*N,nn))
    subjj=subj{ii};subjj=subjj{1};
    fprintf(fid,'cp %s/MD/%s_MD.nii.gz %s/MD/%s_MD.nii.gz\n',dtifit_folder, subjj,parentDirectory,subjj);
    fprintf(fid,'cp %s/L1/%s_L1.nii.gz %s/L1/%s_L1.nii.gz\n',dtifit_folder, subjj,parentDirectory,subjj);
    fprintf(fid,'cp %s/L2/%s_L2.nii.gz %s/L2/%s_L2.nii.gz\n',dtifit_folder, subjj,parentDirectory,subjj);
    fprintf(fid,'cp %s/L3/%s_L3.nii.gz %s/L3/%s_L3.nii.gz\n',dtifit_folder, subjj,parentDirectory,subjj);
    %fprintf(fid,'cp %s/V1/%s_V1.nii.gz %s/V1/%s_V1.nii.gz\n',dtifit_folder, subjj,parentDirectory,subjj);
	%fprintf(fid,'cp %s/V2/%s_V2.nii.gz %s/V2/%s_V2.nii.gz\n',dtifit_folder, subjj,parentDirectory,subjj);
	%fprintf(fid,'cp %s/V3/%s_V3.nii.gz %s/V3/%s_V3.nii.gz\n',dtifit_folder, subjj,parentDirectory,subjj);
	fprintf(fid,'cp %s/MO/%s_MO.nii.gz %s/MO/%s_MO.nii.gz\n',dtifit_folder, subjj,parentDirectory,subjj);
	%fprintf(fid,'cp %s/S0/%s_S0.nii.gz %s/S0/%s_S0.nii.gz\n',dtifit_folder, subjj,parentDirectory,subjj);
for jj=1:length(MD)
    fprintf(fid,'mkdir -p %s/%s/origdata/\n',parentDirectory,MD{jj});
    fprintf(fid,'mkdir -p %s/%s_individ/%s/%s\n',parentDirectory,MD{jj},subjj,MD{jj});
    fprintf(fid,'mkdir -p %s/%s_individ/%s/stats/\n',parentDirectory,MD{jj},subjj);
    fprintf(fid,'%s/bin/fslmaths %s/%s/%s_%s.nii.gz -mas %s/FA/%s_FA_FA_mask.nii.gz %s/%s_individ/%s/%s/%s_%s\n',FSLDIR,parentDirectory,MD{jj},subjj,MD{jj},parentDirectory, ...,
           subjj,parentDirectory,MD{jj},subjj,MD{jj},subjj,MD{jj});
    fprintf(fid,'%s/bin/immv %s/%s/%s %s/%s/origdata\n',FSLDIR,parentDirectory,MD{jj},subjj,parentDirectory,MD{jj});

    fprintf(fid,'%s/bin/applywarp -i %s/%s_individ/%s/%s/%s_%s -o %s/%s_individ/%s/%s/%s_%s_to_target -r %s/data/standard/FMRIB58_FA_1mm -w %s/FA_individ/%s/FA/%s_FA_FA_to_target_warp.nii.gz\n', ...,
         FSLDIR,parentDirectory,MD{jj}, subjj,MD{jj},subjj,MD{jj},   parentDirectory,MD{jj},subjj,MD{jj},subjj,MD{jj},  FSLDIR, parentDirectory,subjj,subjj);

        fprintf(fid,'%s/bin/fslmaths %s/%s_individ/%s/%s/%s_%s_to_target -mas %s/ENIGMA_DTI_FA_mask.nii.gz %s/%s_individ/%s/%s/%s_masked_%s.nii.gz\n', ...,
    FSLDIR, parentDirectory,MD{jj},subjj,MD{jj},subjj,MD{jj}, ENIGMAtemplateDirectory,parentDirectory,MD{jj}, subjj,MD{jj},subjj,MD{jj});
     
    fprintf(fid,'%s/bin/tbss_skeleton -i %s/ENIGMA_DTI_FA.nii.gz -p 0.049 %s/ENIGMA_DTI_FA_skeleton_mask_dst.nii.gz %s/data/standard/LowerCingulum_1mm.nii.gz %s/FA_individ/%s/FA/%s_masked_FA.nii.gz %s/%s_individ/%s/stats/%s_masked_%sskel -a %s/%s_individ/%s/%s/%s_masked_%s.nii.gz -s %s/ENIGMA_DTI_FA_skeleton_mask.nii.gz\n', ...,
    FSLDIR,ENIGMAtemplateDirectory,ENIGMAtemplateDirectory,FSLDIR,  parentDirectory,subjj,subjj,  parentDirectory,MD{jj},subjj,subjj,MD{jj},  parentDirectory,MD{jj},subjj,MD{jj},subjj,MD{jj}, ENIGMAtemplateDirectory);
end
end
fclose(fid);
fprintf(fid0,'sbatch FS_bat%i.pbs\n',kk);
end

fclose(fid0);

clear all;
