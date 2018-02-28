function rf = corrRF(rdata, rtime, stim, maxlag, varargin)
% Default setting: 10K sampling data, 100 binning, 0.033 flipinterval
% rtime: recording timestamps (real time)
% stim: checker box array sequence (type:doulble, row * col * # frames)
p = ParseInput(varargin{:});
          num_bin = p.Results.nBinning;
stimFrameInterval = p.Results.stimFrameInterval;
     samplingRate = p.Results.samplingRate;

% Binning the data & time
fprintf('# of data and time (original) = %d and %d, respectively.\n',length(rdata),length(rtime));
% Binning
bindata = binning1d(rdata, num_bin);
bintime = binning1d(rtime, num_bin);
fprintf('# of data and time (adjusted) = %d and %d, respectively. Binning competed.\n',length(bindata),length(bintime));
% reshape bindata for dot product
bindata = reshape(bindata, [], 1); % column vector

% sampling rate of the correlation (after binning the recording data)
%fsampling = samplingRate/num_bin;
fsampling = bintime(2)-bintime(1);
% # of frames for maxlag duration
N_maxcorr = round(maxlag/fsampling);
% Ignore first N_maxcorr frames for correlation
onset_idx = N_maxcorr + 1;

if N_maxcorr > length(bindata)
    disp('Length of the data is shorter than the correlation length of your interest');
    return;
end 

% stim size & reshape [ch, frames]
[Xstim,Ystim,Nframe] = size(stim);
stim = reshape(stim, [], Nframe);

% stim flip times (real time)
fliptimes = 0:stimFrameInterval:stimFrameInterval*Nframe;
% stim resampling at bintime (recording data times)
% sstim is resampled dim-2 matrix [Nch, Nframe]
% sstim is stim only during bintime. (e.g. 2s stim from 300s stim)
% 'bintime' will be redefined if bintime is beyond fliptimes.
[sstim, bintime] = resampleFlipData(stim, fliptimes, bintime);

% normalization for the correlation computation
norm_bindata = bindata - mean(bindata);
norm_sstim = double(sstim)-0.5;

% Limit data after onset for correlation 
norm_bindata = norm_bindata(onset_idx:end);
num_bindata = length( norm_bindata );

% correlation by dot product with varying delay
rf = [];
for i=0:N_maxcorr
    range = (onset_idx-i):(onset_idx-i + num_bindata-1);
    % onset_idx - N_maxcorr = 1 (by definition)
    corr = norm_sstim(:,range) * norm_bindata;
    rf = [rf, corr]; 
end
% final RF matrix
rf = reshape(rf,Xstim,Ystim,[]);
% display
displayRF(rf);
end

function p = ParseInput(varargin)
    p  = inputParser;   % Create an instance of the inputParser class.

    % Gabor parameters
    % p.addParameter('stimFrameInterval', 0.0333, @(x)x>=0);
    p.addParameter('stimFrameInterval', 0.0300147072065313, @(x)x>=0);
    p.addParameter('samplingRate', 10000, @(x)x>=0);
    p.addParameter('nBinning', 10, @(x) x>=0 && x<=255);
    
    % 
    p.parse(varargin{:});
end