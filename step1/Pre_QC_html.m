Home='/your/work/path/TBSS_pipeline/'; %PATH to change
QC=fullfile(Home,'TBSS/Pre_QC/QC_FA_V1');
sub0=dir(sprintf('%s/*.png',QC));
sub0={sub0.name}';
l=length(sub0);
fid0 = fopen(sprintf('%s/index.html',QC),'w');
fprintf(fid0,'<HTML><TITLE>slicedir</TITLE><BODY BGCOLOR="#aaaaff">\n');
for i=1:l
	fprintf(fid0,'<a href="%s"><img src="%s" WIDTH=1000 > %s</a><br>\n',sub0{i},sub0{i},sub0{i});
end
fprintf(fid0,'</BODY></HTML>\n');
fclose(fid0);
close all;
