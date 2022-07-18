# Music Listening- Genre EEG Dataset (MusinG)

This repo contains EEG dataset collected on 20 participants at BrainLab, IIT Gandhinagar using 129 channels high-density Geodesic cap,
consisting of 12 naturalistic stimuli(songs).

Dataset is provided in the ".mat" format with initials as song_(song_ID).mat

Every mat file contains the following structure
electrodes * timepoints * subjects 

Two steps of preprocessing are completed - 
1. Filtered at 0.2 Hz
2. Downsampled at 250 Hz

Electrode locations are provided, and the 129th electrode is Vertex Ref.

Please refer to the following paper for more detail.

Pandey, P., Ahmad, N., Miyapuram, K. P., & Lomas, D. (2021, December). Predicting dominant beat frequency from brain responses while listening to music. In 2021 IEEE International Conference on Bioinformatics and Biomedicine (BIBM) (pp. 3058-3064). IEEE.

This dataset is licensed under CC-BY Attribution. 

Acknowledgment

This research is supported by PlayPowerLabs, San Diego, USA. 
