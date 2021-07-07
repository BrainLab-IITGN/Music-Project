# Music-Project 
Music Listening- Genre EEG Dataset (MusinG)

This repo contains EEG dataset collected on 20 participants at BrainLab, IIT Gandhinagar using 129 channels high-density Geodesic cap,
consisting of 12 naturalistic stimuli(songs).

Dataset is provided in the ".mat" format with initials as song_(song_ID).mat

Every mat file contains the following structure
electrodes * timepoints * subjects 

Two steps of preprocessing are completed - 
1. Filtered at 0.3 Hz
2. Downsampled at 250 Hz

Electrode locations are provided, and the 129th electrode is Vertex Ref.

Please refer to the following paper for more detail.
Sonawane, D., Miyapuram, K. P., Rs, B., & Lomas, D. J. (2020). GuessTheMusic: song identification from electroencephalography response. arXiv preprint arXiv:2009.08793.

This dataset is licensed under CC-BY Attribution. 

Acknowledgment

This research is supported by PlayPowerLabs, San Diego, USA. 
