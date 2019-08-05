function [proposedFreq] = accurateFreqFinder(inputStartTime, inputEndTime, refFreq, snd, Fs, scanPercentage, plotOn)


if nargin < 6
    scanPercentage = 0.05;    
    plotOn = false;
elseif nargin < 7
    plotOn = false; 
end

%% play a specific time FFT

% assume Max note = 88 ~= 1319Hz (tuned 440Hz), {Finally, the Max note is 95}
% choos sampleRate for fft should be > 1319Hz*2 = 2638Hz
% so choose inputFs for fft :
inputDownSampleRatio=floor(Fs/2638);    % choose int ratio smaller than calculation
inputFs=Fs/inputDownSampleRatio; 
M=8192; % fft size = 8192, to get small freq-bin = 2638/8192 = 0.32 Hz
% for 0.5 Hz resolution, we can set the Max Note to 95

% initially, scanPercentage=0.1;
% it will change while learning
refBin=round(refFreq/inputFs*(M));
scanMinFreq=round(refBin*(1-scanPercentage));
scanMaxFreq=round(refBin*(1+scanPercentage));

% choose FFT sample interval not bigger than interval in time
inputStartNumber = ceil(inputStartTime*Fs); 
inputEndNumber = floor(inputEndTime*Fs);
% selecting the corresponding input range
inputFFTSample=snd(inputStartNumber : inputDownSampleRatio : inputEndNumber);
w=hann(length(inputFFTSample)); % apply hanning window

% Do fft, zero-padding to M
inputFFT=fft(inputFFTSample.*w,M);
inputFFTdB=20*log10(abs(inputFFT(1:M/2+1)));

% % for plot vs frequency
if plotOn
    inputFreqSeries=(1:M/2+1)./M*inputFs;
    figure()
    plot(inputFreqSeries,inputFFTdB)
end

%% Calculate prposed Freq & update A4Freq
% learningRate for updating A4Freq
% Max=1
% learningRate = 0.2;

% find Max f0 from correspondingFreq 90%~110%
maxAmpBin=find(inputFFTdB==max(inputFFTdB(scanMinFreq:scanMaxFreq)));
proposedFreq=maxAmpBin/M*inputFs;

% errorPercent = (proposedFreq - refFreq) / proposedFreq;
% A4Freq = A4Freq * ( 1 + errorPercent * learningRate);

end

