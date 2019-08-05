function [note] = freq2note(freq)

note=69+12.*log2(freq./440);

% freq = 2.^((note-69)./12).*440;

end

