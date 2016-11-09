function waveform = pulseTrain(lowV, highV, nSampling, width_in_ms, freq, numPulse)
% nSampling of the analog output device (per one second) e.g. 10K
% width = (ms)

period = round(nSampling/freq); % num of update points over one period
width = round(width_in_ms/1000.*nSampling); % num of data point for pulse width
if width <1
    disp('[fn:pulseTrain] Pulse width is too short as compared to sampling rate. Increase sampling rate');
    % waveform = zeros(period*numPulse,1);
    return;
end

% single waveform
singlewave = zeros(period,1) + lowV;

id = round(round(period/2.) - width/2.);
% Check the index range
if id <1
    singlewave = highV;
else
    singlewave(id:(id+width-1)) = highV;
end

waveform = repmat(singlewave, numPulse, 1);

end