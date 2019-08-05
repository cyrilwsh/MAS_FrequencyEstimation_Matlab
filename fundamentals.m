function [f0,B] = fundamentals(audioFile, transcriptionMatrix)


% hide the warning of 'non-integer index'
warning('off','MATLAB:colon:nonIntegerIndex')   

[sndread,Fs] = audioread(audioFile);    % read audioFile
snd=(sndread(:,1)+sndread(:,2))/2;  % average stereo to mono
% sound(snd,Fs)

notes = transcriptionMatrix;    % load transcriptionMatrix into notes
noteDic=zeros(90,length(notes)); %creat a dictionary to record each note in the audioFile

%%  scan Audiofile from 0 to the end
% initiallise A4Freq = 440 Hz
% (at first, we don't know what does this audioFile tuned at.
%  so give it a initial value, and then let it learn the actual tuned A4)
A4Freq=440;
A4FreqLog=zeros(length(notes),1); % DEBUG use. Save A4Freq in every iteration

% initialise scan interval
% scan FFT to find maxFreq, 
% initialise at refFreq*90% ~ refFreq*110%
% Finally according to learned A4Freq, will change to minimum 98%~102%
scanInitial = 0.1;  % its a percentage, 0.1 = 10%
scanPercent = scanInitial;
scanPercentLog = zeros(length(notes),1); % DEBUG use. Save scanPercent in every iteration

% set learningRate to update actual A4Freq
% initialise to 0.2
learningRate = 0.2;

% iterate more than 1 times of audioFile,
% to use the up-to-date A4Freq and get the accurate result.
% In practice, 1 time learning is enough,
% so only set 2 iterations can get a accurate result from the 2nd run.
for iteration=1:2
    for i=1:length(notes)   % iterate each sample of audioFile
        inputStartTime = notes(i,1);    % get startTime
        inputEndTime = notes(i,2);      % get endTime
        refNote = notes(i,3);           % get refNote
        refFreq=note2freq(refNote, A4Freq); % Calculate refFreq from refNote & A4Freq

        % accurateFreqFinder is a function to find the accurate Frequency
        % 1. inputStartTime, get from transcription
        % 2. inputEndTime, get from transcrition
        % 3. refFreq, input which frequency does this frame tend to find
        % 4. snd, the audioFile
        % 5. Fs, sampleRate from audioFile
        % 6. scanPercent, the interval for scanning freq based on refFreq
        % output: proposedFreq, the result calculated by this frame
        [proposedFreq]= accurateFreqFinder(inputStartTime, inputEndTime, refFreq, snd, Fs, scanPercent);
        
        % fill the proposedFreq into noteDic
        noteDic(round(refNote),i)=proposedFreq;

        % ----- Update A4Freq & scanPercent in each iteration -----
        % Calculate difference of Freq to update actual A4Freq
        errorPercent = (proposedFreq - refFreq) / proposedFreq;
        % update A4Freq, update rate can also be tuned by learningRate
        A4Freq = A4Freq * ( 1 + errorPercent * learningRate);
        % update scanPercent by the error of this note,
        % but remain 0.02 if the error is very small
        % 0.02 is good enough because Note difference is still 0.0561
        scanPercent = max(abs(errorPercent), 0.02);

        % DEBUG use. Save learning curve.
        A4FreqLog(i)=A4Freq;
        scanPercentLog(i)=scanPercent;

    end
end

%% Note summary
% create a dictionary to save summary of each note
% 1st column: average freq of the Note
% 2nd column: standard deviation of the Note
% 3rd column: number count of the Note
noteSummary=zeros(size(noteDic,1),3);   
for i=1:size(noteDic,1)
    noteSeries=noteDic(i,:);    % extract just one note
    noteAvailable=noteSeries(find(noteSeries)); % take non-zero value only
    if noteAvailable    % if there is more than 1 value, then summarise it
        noteSummary(i,1)=mean(noteAvailable);
        noteSummary(i,2)=std(noteAvailable);
        noteSummary(i,3)=length(noteAvailable);
    else    % if there is no value, just write 0
        noteSummary(i,:)=0;
    end
end

% return fundamental frequency 
f0 = noteSummary(:,1);
B = 0;
end

