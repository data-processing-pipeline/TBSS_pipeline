%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%   Process FA data using FSL/TBSS_1 on BIOS Sever     %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% March  8, 2016 @ by CH

clear all;


FDTDir = '/your/work/path/TBSS_pipeline/';               %PATH to change 
cd(FDTDir);
raw_dir = fullfile(FDTDir,'TBSS/FA');
codedir=fullfile(FDTDir,'code');
mkdir(codedir);
delete(fullfile(codedir,'*'));

subNames = dir(fullfile(raw_dir,'*_FA.nii.gz')); 
subNames = {subNames.name}';
%subNames = subNames(3:end); % first two are sup-directory and current one

nn = size(subNames,1);

fid2 = fopen(sprintf('%s/tbss_1T.sh',codedir),'w');
fprintf(fid2,'#!/bin/bash\n');
N=10;
K=ceil(nn/N);

for kk=1:K
    fid21 = fopen(sprintf('%s/tbss_1_%i.pbs',codedir,kk),'w');
    fprintf(fid21,'#!/bin/bash\n');
    fprintf(fid21,'#SBATCH --ntasks=1\n');
    fprintf(fid21,'#SBATCH --time=01:59:59\n');
    fprintf(fid21,'#SBATCH --mem=8000\n');
    fprintf(fid21,'#SBATCH --wrap=TBSS_%i\n',kk);
    fprintf(fid21,'module load fsl\n');
    fprintf(fid21,'module load python/2.7.12\n');
    fprintf(fid21,'export FSLDIR=/nas/longleaf/apps/fsl/5.0.9/fsl/\n');
    fprintf(fid21,'source ${FSLDIR}/etc/fslconf/fsl.sh\n');
    fprintf(fid21,'export PATH=${FSLDIR}/bin:${PATH}\n');
    fprintf(fid21,'cd %sTBSS/FAtbss\n',FDTDir);
    flag=0;
    for ii=min(kk*N,nn)+((kk-1)*N+1)-(((kk-1)*N+1):min(kk*N,nn))
		ID=subNames{ii};
		if exist(sprintf('%sTBSS/FAtbss/FA2ENIGMAtemplate/%s_FA_to_target.nii.gz',FDTDir,ID(1:(end-10))))&exist(sprintf('%sTBSS/FAtbss/FA2ENIGMAtemplate/%s_FA_to_target.mat',FDTDir,ID(1:(end-10))))&exist(sprintf('%sTBSS/FAtbss/FA2ENIGMAtemplate/%s_FA_FA.nii.gz',FDTDir,ID(1:(end-10))))
		   continue;
		end 
		disp(ii)
		fprintf(fid21,'flirt %s ./FA2ENIGMAtemplate/%s_FA_FA.nii.gz ','-in',ID(1:(end-10)));
		fprintf(fid21,'%s %sTBSS/ENIGMA_targets/ENIGMA_DTI_FA.nii.gz ','-ref',FDTDir);
		fprintf(fid21,'%s ./FA2ENIGMAtemplate/%s_FA_to_target.nii.gz ','-out',ID(1:(end-10)));
		fprintf(fid21,'%s ./FA2ENIGMAtemplate/%s_FA_to_target.mat -dof 9\n','-omat',ID(1:(end-10)));
		flag=1;
    end
    fclose(fid21);
    if flag==1
        fprintf(fid2,'sbatch %scode/tbss_1_%i.pbs\n',FDTDir,kk);
    end
end 
fclose(fid2);
