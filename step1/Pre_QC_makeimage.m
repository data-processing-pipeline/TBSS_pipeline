%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%   Process DTI data using QC toolbox on UNC Killdevil Sever   %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jan    8, 2016 @ by CH

Home='/your/work/path/TBSS_pipeline/'; %PATH to change
FDTDir = fullfile(Home,'TBSS/');
codedir= fullfile(Home,'code/');
mkdir(codedir);
delete(fullfile(codedir,'*'));



mkdir(fullfile(FDTDir,'Pre_QC/QC_FA_V1'));

TXTfile=sprintf('%sPre_QC/Subject_Path_Info.txt',FDTDir);
output_directory=sprintf('%sPre_QC/QC_FA_V1/',FDTDir);
thresh=0.2;
[subjs,FAs,VECs]=textread(TXTfile,'%s %s %s','headerlines',1);


fid0 = fopen(sprintf('%s/FDT_batAll.sh',codedir),'w');
fprintf(fid0,'#!/bin/bash \n');
nn=length(subjs);
N=20;
K=ceil(nn/N);


%for s = 1:nn
for kk = 1:K
	batNames = sprintf('%s/FDT_bat%i.pbs',codedir,kk);
    fid = fopen(batNames,'w');  
    fprintf(fid,'#!/bin/bash\n');
    fprintf(fid,'#SBATCH --ntasks=1\n');
    fprintf(fid,'#SBATCH --time=23:59:59\n');
    fprintf(fid,'#SBATCH --mem=8000\n');
    fprintf(fid,'#SBATCH --wrap=TBSS_%i\n',kk);
    fprintf(fid,'module load fsl\n');
    fprintf(fid,'module load python/2.7.12\n');
    fprintf(fid,'export FSLDIR=/nas/longleaf/apps/fsl/5.0.9/fsl/\n');
    fprintf(fid,'source ${FSLDIR}/etc/fslconf/fsl.sh\n');
    fprintf(fid,'export PATH=${FSLDIR}/bin:${PATH}\n');
    fprintf(fid,'cd %s \n',codedir);
	fprintf(fid,'module load matlab \n');
	fprintf(fid,'for ((i=%i;i<=%i;i++)); do\n',(kk-1)*N+1,min(kk*N,nn));
	fprintf(fid,'matlab -nosplash -nodesktop -r FDT_bat$i>>$i.out\n');
	fprintf(fid,'done\n');
	for s=min(kk*N,nn)+((kk-1)*N+1)-(((kk-1)*N+1):min(kk*N,nn))
		subj=subjs(s);
		subj
		Fa=FAs(s);
		Vec=VECs(s);
		%fprintf(fid,'matlab -nosplash -nodesktop -r FDT_bat%i>>%i.out \n',s,s);
		batNames = sprintf('%s/FDT_bat%i.m',codedir,s);
		fid1 = fopen(batNames,'w');
		% reslice FA
		fprintf(fid1,'addpath(''%senigmaDTI_QC''); \n',FDTDir);
		fprintf(fid1,'[pathstrfa,nameniifa,gzfa] = fileparts(''%s''); \n',Fa{1,1});
		fprintf(fid1,'[nafa,namefa,niifa] = fileparts(nameniifa); \n');
		fprintf(fid1,'newnamegzfa=[pathstrfa,''/'',namefa,''_reslice.nii.gz'']; \n');
		fprintf(fid1,'newnamefa=[pathstrfa,''/'',namefa,''_reslice.nii'']; \n');
		fprintf(fid1,'copyfile(''%s'',newnamegzfa); \n',Fa{1,1});
		fprintf(fid1,'gunzip(newnamegzfa); \n');
		fprintf(fid1,'delete(newnamegzfa); \n');
		fprintf(fid1,'reslice_nii(newnamefa,newnamefa); \n');

		% reslice V1
		fprintf(fid1,'[pathstrv1,nameniiv1,gzv1] = fileparts(''%s''); \n',Vec{1,1});
		fprintf(fid1,'[nav1,namev1,niiv1] = fileparts(nameniiv1); \n');
		fprintf(fid1,'newnamegzv1=[pathstrv1,''/'',namev1,''_reslice.nii.gz'']; \n');
		fprintf(fid1,'newnamev1=[pathstrv1,''/'',namev1,''_reslice.nii'']; \n');
		fprintf(fid1,'copyfile(''%s'',newnamegzv1); \n',Vec{1,1});
		fprintf(fid1,'gunzip(newnamegzv1); \n');
		fprintf(fid1,'delete(newnamegzv1); \n');
		fprintf(fid1,'reslice_nii(newnamev1,newnamev1); \n');

		% qc
		fprintf(fid1,'func_QC_enigmaDTI_FA_V1(''%s'',newnamefa,newnamev1,''%s''); \n',subj{1},output_directory);

		%fprintf(fid1,'close(1) \n');
		%fprintf(fid1,'close(2) \n');
		%fprintf(fid1,'close(3) \n');

		% delete
		fprintf(fid1,'delete(newnamefa) \n');
		fprintf(fid1,'delete(newnamev1) \n');

		fprintf(fid1,'A=imread(''%s/%s/Sagittal_V1_check.png'');\n',output_directory,subj{1});
		fprintf(fid1,'B=imread(''%s/%s/Coronal_V1_check.png'');\n',output_directory,subj{1});
		fprintf(fid1,'C=imread(''%s/%s/Axial_V1_check.png'');\n',output_directory,subj{1});
		fprintf(fid1,'newImg = cat(2,A,B,C);\n');
		fprintf(fid1,'imwrite(newImg,''%s/%s.png'');\n',output_directory,subj{1});
		fprintf(fid1,'system(''rm -r %s/%s/'')\n',output_directory,subj{1});
        fprintf(fid1,'close all;\n');
        fprintf(fid1,'exit\n');
        fclose(fid1)
	end
	fclose(fid);
	fprintf(fid0,'sbatch FDT_bat%i.pbs\n',kk);
end

fclose(fid0);
