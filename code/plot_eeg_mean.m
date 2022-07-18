% plot data analysis

y = linspace(0,90,22500);
path = '/mnt/sdc/Music/Music/Music_Project/Plot_eeg_response/Pre_Processing_2/all_electrodes/time_plots/mean/';
for i = 1:12
    data = channelMeansPerSong(:,i); %PC1(:,i)
    figure();
    fig = plot(y,data);
    title(strcat('Song-',num2str(i)));
    ylabel('Amplitude');
    xlabel('Time (sec)');
    path1 = strcat(path,'song_',num2str(i+100),'.jpg');
    saveas(fig, path1);
    close;
end


dirOutput = dir(fullfile(path,'*.jpg'));
fileNames = string({dirOutput.name});


montage(fileNames,'Size',[2 6],'DisplayRange',[1000,1001]);
