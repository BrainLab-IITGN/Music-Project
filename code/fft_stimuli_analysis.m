# This code is used to create envelope of stimuli and generate fft plots used in the following article.

# Pandey, P., Ahmad, N., Miyapuram, K. P., & Lomas, D. (2021, December). 
# Predicting dominant beat frequency from brain responses while listening to music. 
# In 2021 IEEE International Conference on Bioinformatics and Biomedicine (BIBM) (pp. 3058-3064). IEEE.

clear all; clc;


data_path = '/home/Documents/Research/Music/Music_Project/Data/consolidated_pre_processed_2/';

cd(data_path)

for i = 1:12
    currFn = ['song_' num2str(i+300) '.mat'];
    disp(['Loading ' currFn '...'])
    load(currFn);
    var = strcat('song_',num2str(i+300));
    eeg_len(i,1) = size(eval(var,';'),2);
    
    clear (var)
end
save('eeg_len','eeg_len');

load('eeg_len.mat');

%% Create Song Envelope   
% Ref (https://github.com/dmochow/SRC/blob/master/extractStimulusFeatures.m)

wav_path = '/mnt/sdc/Music/Music/Music_Project/Song_wav/';

cd(wav_path)
rawDataFiles = dir('*.wav');


for i = 1:size(rawDataFiles,2)

    soundEnvlelope = [];
    soundEnvelopeDown = [];

    stimFilename = rawDataFiles(i).name;

    % EEG sampling rate
    fsEEG = 125;

    try
        [y,fsAudio]=audioread(stimFilename);
    catch
        error('failed to read audio file');
    end

    yh=hilbert(mean(y,2));  % soundtrack is often mono
    soundEnvelope=sqrt(real(yh).^2+imag(yh).^2);

    fsAudio=round(fsAudio);
    soundEnvelopeDown=resample(soundEnvelope,fsEEG,fsAudio); % downsample to EEG sampling rate

    soundEnvelopeDown=zscore(soundEnvelopeDown);


    len = eeg_len(i,1);

    sound_envelope{i,1} = soundEnvelopeDown(1:len,1);

    song_length(i,1) = size(soundEnvelopeDown,1);
    song_length(i,2) = size(sound_envelope{i,1},1);
end

save('sound_envelope.mat','sound_envelope');

%% Compute fft of each song

wav_path = '/home/Documents/Research/Music/Music_Project/Song_wav/';

cd(wav_path)

load ('sound_envelope.mat');

for i = 1:12
    values = [];
    values = sound_envelope{i,1};
    sound_fft{i,1} = abs(fft(values)); 
end

save('sound_fft.mat','sound_fft');
