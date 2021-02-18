% Script name: gigica_netmats.m
%
% Description: Function to run netmats analysis on GIGICA mat files
% subj - subject ID
% general_subj_dir - upper level directory on which subject directory exists
% fslnets - FSLNets directory for calculating nodal amplitudes,correlations
% l1precision
% ncomp - number of group components for which features should be extracted - Here we 	are using 25 or 100 components from UKBB
% gmapDir - group maps where melodic_IC_25 or melodic_IC_100 is
% TR - Temporal Resolution(Rep time) in seconds 

function gigica_netmats(subj, general_subj_dir,fslnets,ncomp,gmapDir,TR,ntimepoints,outDir)

	addpath(fslnets)
	addpath(sprintf('%s/etc/matlab',getenv('FSLDIR')))
	subj_dir=strcat(general_subj_dir,'/',subj)
        out_dir=strcat(outDir,'/',subj) 

  	dimensionality={ncomp}
	D=dimensionality{1}
	group_maps=strcat(gmapDir,'/melodic_IC_',D)
		
	% converting mat file to text file to make it compatible with nets_load 
	tmp=load(strcat(subj_dir,'/',subj,'_gigica.mat'))
	ts_dir = strcat(out_dir,'/',sprintf('rfMRI_%s.dr',D))
	status= mkdir(ts_dir)

 	dlmwrite(strcat(ts_dir,'/',subj,'_gigica.txt'),tmp.tc,'delimiter','\t','newline','pc')

		% nets_load(inDir,tr,varnorm,NrunsPerSubject,NtimepointsPerSubject);
		% indir: string, naming a folder that contains multiple timeseries 			files (e.g. as output by dual_regression/gigica)
		% tr: float containing TR (temporal resolution, in seconds)
		% varnorm: temporal variance normalisation to apply:
			%      0 = none
			%      1 = normalise overall stddev for each run (normally one 					run/subject per timeseries file)
			%      2 = normalise separately each separate timeseries from 					each run
		% NrunsPerSubject (optional, default=1): specify how many sub-runs per 			subject-file(i.e., if sub-runs had previously been combined into 			single timeseries files)
		% nets_load loads data from a dual regression/gigica output directory, 			whatever the name of the file (dr_stage1_subject*.txt or other). Files 			are loaded in alphabetical order.

		ts=nets_load(ts_dir,TR,0,1,ntimepoints)

		% r2z scaling factor has been determined from UK Biobank subjects
		% calculate only r values and z-values WITHOUT SCALING

		%{ 
			From UKBB forum on selecting scaling factor:
			--------------------------------------------
		
		We are converting netmats from corrcoefs into Z - to get the scaling right we need these scaling factors. We can't just use the number of timepoints to get this right, because of temporal smoothness (autocorrelation) in the data.  The "true" value in individual subjects is probably more consistent (across subjects) than it would appear to be if we tried to estimate it for subjects one at a time (as it's a bit of a noisy thing to estimate), so we estimated the average value for a set of initial subjects and apply this correct to all subjects.
		Given that this scaling is the same for all subjects, for most purposes we could have just not bothered applying a (constant) scaling at all and it would make no difference - for most analyses.
		
		%}

 
		if strcmp(D,'25')
			ts.DD=[setdiff([1:25],[4 23 24 25])];
			r2zFULL=10.6484;
			r2zPARTIAL=10.6707;
		else
			ts.DD=[setdiff([1:100],[1 44 47 51 54 55 56 59 61 62 65:92 94:100])];
			r2zFULL=19.7177;
			r2zPARTIAL=18.8310;
		end
		ts=nets_tsclean(ts,1);

		% partial correlation with regularization rho=0.5
		% we are not using scaling factor as it is derived from UKBB data
		% nets_netmats(ts,z(0-r,1-z,<0-negative r2z scaling factor)

		%netmats1=  nets_netmats(ts,-r2zFULL,'corr');
		netmats1 = nets_netmats(ts,0,'corr');		
		%netmats1=nets_netmats(ts,1,'corr');
		%netmats2=  nets_netmats(ts,-r2zPARTIAL,'ridgep',0.5);
		netmats2 = nets_netmats(ts,0,'ridgep',0.5);
		%netmats2= nets_netmats(ts,1,'ridgep',0.5);
		clear NET;

		grot=reshape(netmats1(1,:),ts.Nnodes,ts.Nnodes);
		NET(1,:)=grot(triu(ones(ts.Nnodes),1)==1);
		
		po=fopen(strcat(ts_dir,sprintf(strcat('/',subj,'_fullcorr_v1.txt'))),'w');
		%po=fopen(strcat(ts_dir, sprintf('rfMRI_d%s_fullcorr_z_v1.txt',D)),'w');
		fprintf(po,[ num2str(NET(1,:),'%14.8f') '\n']);
		fclose(po);

		clear NET;

		grot=reshape(netmats2(1,:),ts.Nnodes,ts.Nnodes);
		NET(1,:)=grot(triu(ones(ts.Nnodes),1)==1);

		po=fopen(strcat(ts_dir,sprintf(strcat('/',subj,'_partialcorr_v1.txt'))),'w');
		%po=fopen(strcat(ts_dir, sprintf('rfMRI_d%%s_partialcorr_z_v1.txt',D)),'w');
		fprintf(po,[num2str(NET(1,:),'%14.8f') '\n']);
		fclose(po);

		ts_std=std(ts.ts);
		po=fopen(strcat(ts_dir, sprintf(strcat('/',subj,'_NodeAmplitudes_v1.txt'))),'w');
		fprintf(po,[num2str(ts_std(1,:),'%14.8f') '\n']);
		fclose(po);
		
		%movefile(ts_dir,[out,ts_dir])
end
