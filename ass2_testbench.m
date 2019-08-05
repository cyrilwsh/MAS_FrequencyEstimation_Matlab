%% test funcion fundamentals
audioFile = "bach_pr1_a.wav";
% audioFile = "bach_pr1_b.wav";

% get the note information from bach_pr1.m
bach_pr1
transcriptionMatrix = notes;

[f0,B] = fundamentals(audioFile, transcriptionMatrix);