function waveform = sawtoothpulse(lowV, highV, nSampling, freq, numPulse)
% nSampling of the analog output device (per one second) e.g. 10K
% width = (ms)

period = round(nSampling/freq); % num of update points over one period

% single waveform
singlewave = linspace(lowV,highV,period);
singlewave(end) = lowV;
%
waveform = repmat(singlewave(:), numPulse, 1);

end