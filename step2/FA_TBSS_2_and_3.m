%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%   Process FA data using FSL/TBSS_2-3 on BIOS Sever     %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% March  8, 2016 @ by CH

clear all;


FDTDir = '/your/work/path/TBSS_pipeline/';               % directory containing the data folder and other files.  you need to change the directory accordingly

raw_dir = fullfile(FDTDir,'TBSS/FAtbss');
codedir=fullfile(FDTDir,'code/');
mkdir(codedir);
delete(fullfile(codedir,'*'));

subNames = dir(fullfile(raw_dir,'/origdata'));  % 'DATA': name of directory containing the imaging data files.  you need to change the directory accordingly
subNames = {subNames.name}';
subNames = subNames(3:end); % first two are sup-directory and current one

done = dir(fullfile(raw_dir,''));


nn = size(subNames,1);

fid0 = fopen(sprintf('%stbss_23_all.sh',codedir),'w');
fprintf(fid0,'#!/bin/bash\n');
N=10;
K=ceil(nn/N);


for kk=1:K
    batNames = sprintf('tbss_23_%i.pbs',kk);%%%%%%%%%%%%%
    fid2 = fopen(sprintf('%s/%s',codedir,batNames),'w');  
    fprintf(fid2,'#!/bin/bash\n');
    fprintf(fid2,'#SBATCH --ntasks=1\n');
    fprintf(fid2,'#SBATCH --time=01:59:59\n');
    fprintf(fid2,'#SBATCH --mem=8000\n');
    fprintf(fid2,'#SBATCH --wrap=TBSS_%i\n',kk);
    fprintf(fid2,'module load fsl\n');
    fprintf(fid2,'module load python/2.7.12\n');
    fprintf(fid2,'export FSLDIR=/nas/longleaf/apps/fsl/5.0.9/fsl/\n');
    fprintf(fid2,'source ${FSLDIR}/etc/fslconf/fsl.sh\n');
    fprintf(fid2,'export PATH=${FSLDIR}/bin:${PATH}\n');
    flag=0;
    for ii=min(kk*N,nn)+((kk-1)*N+1)-(((kk-1)*N+1):min(kk*N,nn))
    ID=subNames{ii};
    if exist(sprintf('%sTBSS/FAtbss/FA_individ/%s/FA/%s_masked_FA.nii.gz',FDTDir,ID(1:(end-10)),ID(1:(end-10))))&exist(sprintf('%sTBSS/FAtbss/FA_individ/%s/stats/%s_masked_FAskel.nii.gz',FDTDir,ID(1:(end-10)),ID(1:(end-10))))
        continue;
    end 
    disp(ii)
    fprintf(fid2,'cd %s\n',raw_dir);
    fprintf(fid2,'mkdir -p ./FA_individ/%s/stats/\n',ID(1:(end-10)));
    fprintf(fid2,'mkdir -p ./FA_individ/%s/FA/\n',ID(1:(end-10)));
    fprintf(fid2,'cp ./FA/%s_*.nii.gz ./FA_individ/%s/FA/\n',ID(1:(end-10)),ID(1:(end-10)));
    fprintf(fid2,'cd %s/FA_individ/%s\n',raw_dir,ID(1:(end-10)));
    %fprintf(fid2,'tbss_2_reg -t %sTBSS/ENIGMA_targets/ENIGMA_DTI_FA.nii.gz\n',FDTDir);
    fprintf(fid2,'fsl_reg ./FA/%s_FA_FA.nii.gz %s/TBSS/ENIGMA_targets/ENIGMA_DTI_FA.nii.gz ./FA/%s_FA_FA_to_target -FA\n',ID(1:(end-10)),FDTDir,ID(1:(end-10)));
    fprintf(fid2,'cp %sTBSS/ENIGMA_targets/ENIGMA_DTI_FA.nii.gz ./FA/target.nii.gz\n',FDTDir);
    fprintf(fid2,'tbss_3_postreg -S\n');
    fprintf(fid2,'rm ./FA/%s_FA_to_target.nii.gz\n',ID(1:(end-10)));
    fprintf(fid2,'${FSLDIR}/bin/fslmaths ./FA/%s*_FA_to_target.nii.gz -mas ',ID(1:(end-10)));
    fprintf(fid2,'%sTBSS/ENIGMA_targets/ENIGMA_DTI_FA_mask.nii.gz ',FDTDir);
    fprintf(fid2,'./FA/%s_masked_FA.nii.gz\n',ID(1:(end-10)));

    %Skeletonize images%
    ID=subNames{ii};
    fprintf(fid2,'cp ./FA/%s_masked_FA.nii.gz %s/FA/\n',ID(1:(end-10)),raw_dir);
    fprintf(fid2,'${FSLDIR}/bin/tbss_skeleton -i ./FA/%s_masked_FA.nii.gz -p 0.049 ',ID(1:(end-10)));
    fprintf(fid2,'%sTBSS/ENIGMA_targets/ENIGMA_DTI_FA_skeleton_mask_dst ${FSLDIR}/data/standard/LowerCingulum_1mm.nii.gz ',FDTDir);
    fprintf(fid2,'./FA/%s_masked_FA.nii.gz ',ID(1:(end-10)));
    fprintf(fid2,'./stats/%s_masked_FAskel.nii.gz -s ',ID(1:(end-10)));
    fprintf(fid2,'%sTBSS/ENIGMA_targets/ENIGMA_DTI_FA_skeleton_mask.nii.gz\n',FDTDir);
    flag=1;
    end
    fclose(fid2);
    if flag==1
    fprintf(fid0,'sbatch tbss_23_%i.pbs\n',kk);
    end
end

fclose(fid0);
