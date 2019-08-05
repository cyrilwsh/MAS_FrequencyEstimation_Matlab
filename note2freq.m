function [freq] = note2freq(note,A4Freq)

% typical tune is A4=440 Hz

% initial A4Freq = 440 Hz
if nargin<2
  A4Freq = 440;
end

freq = 2.^((note-69)./12).*A4Freq;

end

