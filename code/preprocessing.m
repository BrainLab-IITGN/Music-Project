clear all; clc;

% reading file path
read_path= '/home/brainlab/set_files/19*.set';

% save file path
save_path= '/home/pankaj/Documents/Research/Music/Music_Project/Data/preprocessed_6/';
silence_save_path = '/home/pankaj/Documents/Research/Music/Music_Project/Data/preprocessed_6/silence_data/';

load('chanlocs.mat');
load('event.mat');

file_list=dir(read_path);

save_dir = save_path;
if ~exist(save_dir,'dir')
    mkdir(save_dir)
end

for k= 1:size(file_list)
    
    %file name and file path
    file_name = file_list(k).name;
    file_path = file_list(k).folder;
    
    % loading set file
    EEG = pop_loadset([file_path,'/',file_name]);
    
    originalEEG = EEG;
    %% high pass filter at 0.2 Hz 
    EEG = pop_eegfiltnew(EEG, [],0.2,[],1,[],0);
    EEG = eeg_checkset( EEG );
    
    %% Line Noise
    EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:EEG.nbchan],'computepower',1,'linefreqs',...
        [50,100,150] ,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype',...
        'Channels','tau',100,'verb',0,'winsize',4,'winstep',1, 'ComputeSpectralPower','False');
    EEG = eeg_checkset(EEG);
    
    %% Downsample
    srate = EEG.srate;
    
    if srate > 250
        EEG =pop_resample(EEG, 250);
        EEG = eeg_checkset(EEG);
    end 
    
    %% Extracting timings of trial markers
    
    fixclose=find(strcmp({EEG.event.type},'fxcl'));
    stimplus=find(strcmp({EEG.event.type},'stm+'));
    fixend=find(strcmp({EEG.event.type},'fxnd'));
    
    % silence time during experiment
    stim = find(strcmp({EEG.event.type},'stim'));
    stimend=find(strcmp({EEG.event.type},'opyp'));
    
    stim_bgntime = round(EEG.event(stim).latency);
    stim_endtime =   round(EEG.event(stimend).latency);
    silence_data= EEG.data(:,stim_bgntime:stim_endtime);
    
    silence_preprocess(EEG,file_name, k,silence_data,silence_save_path);

    data={};
    times={};


    for i = 1:length(stimplus)
        j=str2num(EEG.event(stimplus(i)).mffkey_cel);
        % bgntime=(EEG.event(fixclose(i)).latency);
        bgntime = round(EEG.event(stimplus(i)).latency);
        %bgndata=find(EEG.times<=round(bgntime),1,'last');
        endtime= round(EEG.event(fixend(i)).latency);
        %enddata=find(EEG.times<=round(endtime),1,'last');
        %data{j}=EEG.data(bgndata:enddata);
        data{j}=EEG.data(:,bgntime:endtime);
        %%timing=round(enddata-bgndata);
        times{j}=EEG.times(bgntime:endtime);
        eeg_detail{k,1} = file_name(1:end-4);
        eeg_detail{k,j+1} = size(data{j},2);
    % outEEG=pop_epoch(EEG, EEG,stimplus(i),[-10 (endtime-bgntime)/EEG.srate]);
    % tmpEEG = pop_saveset( outEEG,[fileName,'_sgm_' num2str(j), '.set'],saveDir);
    end
    
   %% Epoch process is starting
   reject = EEG.reject;
   
   
    for i = 1:length(data)
        
        EEG.data = data{i};
        EEG.pnts = size(data{i},2);
        step = 250/EEG.srate;
        EEG.times = 0:step:step*(EEG.pnts-1);
        EEG.xmin = 0;
        EEG.xmax = size(EEG.data,2)/EEG.srate;
        EEG.chanlocs = chanlocs;
        EEG.event = event;
        EEG.event.duration = size(EEG.data,2);
        
        %reset these parameters
        EEG.reject = reject;
        EEG.icaact =[];
        EEG.icawinv = [];
        EEG.icasphere = [];
        EEG.icaweights = [];
        EEG.icachansind = [];
        
        EEG = eeg_checkset(EEG);
        %EEG.fileLen = fileLen;
    
    %% crude bad channel detection using spectrum criteria and 3SDeviations as channel outlier threshold
        [EEG,EEG.reject.chn] = pop_rejchan(EEG,'elec', [1:128], 'threshold',[-3 3],'norm','on','measure','spec','freqrange',[0.3 125]);
        pre_info.reject_chn(k,i) = size(EEG.reject.chn,2);
        %EEG = eeg_checkset(EEG);
    
    %%  run ICA to evaluate components this time 
        EEG = pop_runica(EEG, 'extended',1,'interupt','on');

    %%  use MARA to flag artifactual IComponents automatically if artifact probability > .5
        [~,EEG,~]= processMARA(EEG,EEG,EEG);
        
        EEG.reject.gcompreject = zeros(size(EEG.reject.gcompreject));
        threshold = 0.50;
        EEG.reject.gcompreject(EEG.reject.MARAinfo.posterior_artefactprob > threshold) = 1;
        
        artifact_ICs = [];
        artifact_ICs=find(EEG.reject.gcompreject == 1);
        
        pre_info.artifact_ICs(k,i) = length(artifact_ICs);
        % store MARA related variables to assess ICA/data quality
        index_ICs_kept=(EEG.reject.MARAinfo.posterior_artefactprob < threshold);
        pre_info.median_artif_prob_good_ICs(k,i) = median(EEG.reject.MARAinfo.posterior_artefactprob(index_ICs_kept));
        pre_info.mean_artif_prob_good_ICs(k,i) = mean(EEG.reject.MARAinfo.posterior_artefactprob(index_ICs_kept));
        pre_info.range_artif_prob_good_ICs(k,i) = range(EEG.reject.MARAinfo.posterior_artefactprob(index_ICs_kept));
        pre_info.min_artif_prob_good_ICs(k,i) = min(EEG.reject.MARAinfo.posterior_artefactprob(index_ICs_kept));
        pre_info.max_artif_prob_good_ICs(k,i) = max(EEG.reject.MARAinfo.posterior_artefactprob(index_ICs_kept));
        
        EEG = pop_subcomp( EEG, artifact_ICs, 0);
        
        %EEG = eeg_checkset(EEG);
    
    %% interpolate removed channels
    
    %[EEGc, HP, BUR]=clean_artifacts(EEG);
        EEG = pop_interp(EEG,chanlocs,'spherical');
        %EEG = eeg_checkset(EEG);
   
    %% Re-reference
        EEG = pop_reref(EEG, []);
        %EEG = eeg_checkset(EEG);
            
    %%  Saving mat files
        pre_info.eeg_chn(k,i) = EEG.nbchan;
        pre_info.eeg_sec(k,i) = EEG.xmax;
        pre_info.eeg_len(k,i) = size(EEG.data,2);
        pre_info.eeg_srate(k,i) = EEG.srate;
       
        song_id = 100+i;
        save(strcat(save_dir,'/',file_name(1:end-4),'_clean_', int2str(song_id), '.mat'),'EEG');
    end    
    save([save_dir,'/','pre_info','.mat'],'pre_info');
        
end
