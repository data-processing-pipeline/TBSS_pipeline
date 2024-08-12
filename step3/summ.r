Home0='/your/work/path/TBSS_pipeline/TBSS/'
Home=paste0(Home0,'FAtbss/')
out=paste0(Home,'/tosave')
system(paste0('mkdir ',out))
system(paste0('cp ',Home,'/FA_individ/*/FA/*_FA_FA_to_target.mat ',out))
system(paste0('cp ',Home,'/FA_individ/*/FA/*_FA_FA_to_target_warp.nii.gz ',out))
system(paste0('cp ',Home,'/FA_individ/*/stats/*_masked_FAskel.nii.gz ',out))
system(paste0('cp ',Home,'/MD_individ/*/MD/*_masked_MD.nii.gz ',out))
system(paste0('cp ',Home,'/MD_individ/*/stats/*_masked_MDskel.nii.gz ',out))
system(paste0('cp ',Home,'/MO_individ/*/MO/*_masked_MO.nii.gz ',out))
system(paste0('cp ',Home,'/MO_individ/*/stats/*_masked_MOskel.nii.gz ',out))
system(paste0('cp ',Home,'/S0_individ/*/S0/*_masked_S0.nii.gz ',out))
system(paste0('cp ',Home,'/S0_individ/*/stats/*_masked_S0skel.nii.gz ',out))
system(paste0('cp ',Home,'/L1_individ/*/L1/*_masked_L1.nii.gz ',out))
system(paste0('cp ',Home,'/L1_individ/*/stats/*_masked_L1skel.nii.gz ',out))
system(paste0('cp ',Home,'/L2_individ/*/L2/*_masked_L2.nii.gz ',out))
system(paste0('cp ',Home,'/L2_individ/*/stats/*_masked_L2skel.nii.gz ',out))
system(paste0('cp ',Home,'/L3_individ/*/L3/*_masked_L3.nii.gz ',out))
system(paste0('cp ',Home,'/L3_individ/*/stats/*_masked_L3skel.nii.gz ',out))
mod0=c('MD','MO','L1','L2','L3','FA')
sub0=dir('/your/work/path/TBSS_pipeline/TBSS/FAtbss/MD_individ/MD_ENIGMA_ROI_part2')
sub0=unlist(strsplit(sub0,'_MD_ROIout_avg.csv'))
# sub0=sub0[-which(sub0=="1460208")]
l=length(mod0)
for(i in 1:l)
{
	if(i<l){temp=read.csv(paste0(Home,mod0[i],'_individ/',mod0[i],'_ENIGMA_ROI_part2/',sub0[1],'_',mod0[i],'_ROIout_avg.csv'))}
	if(i==l){temp=read.csv(paste0(Home0,'Enigma_ROI_1/avg_',sub0[1],'_ROIout.csv'))}
	Stat=matrix(NA,length(sub0),dim(temp)[1])
	colnames(Stat)=temp[,1]
	rownames(Stat)=sub0
	for(j in 1:length(sub0))
	{
	  if(i<l){temp=read.csv(paste0(Home,mod0[i],'_individ/',mod0[i],'_ENIGMA_ROI_part2/',sub0[j],'_',mod0[i],'_ROIout_avg.csv'))}
	  if(i==l){temp=read.csv(paste0(Home0,'Enigma_ROI_1/avg_',sub0[j],'_ROIout.csv'))}
	  rownames(temp)=temp[,1]
      Stat[j,]=temp[colnames(Stat),2]
	}
	write.table(Stat,file=paste0(out,'/',mod0[i],'_ROIavg.csv'))
}

