function [rf] = corrRF4(rdata, rtime, stim, fliptimes, maxlag, upsampling, varargin)
% v4: for imaging data (e.g. roiDATA class)
% How to match sampling rates between imaging and stimflips? 
% Resample stim at imaging frame times (matching rate & times)
% Optimized for sampling rate ~ stim flip rate
% rdata = ch (row) x time-series (col)
% delay time 0 to maxlag as increasing col#
% stim: checker box array sequence (row * col * # frames)
% upsampling: of stimulus. not
% 0312 2018 Juyoung

p = ParseInput(varargin{:});

% stim size & reshape [ch, frames]
Dim_stim = ndims(stim);
if Dim_stim >3
    disp('stim is dim>3 array. It should be dim 1-3 data');
    rf = [];
    return;
elseif Dim_stim ==3
    [Xstim, Ystim, N_flips] = size(stim);
elseif Dim_stim == 2
    [Ystim, N_flips] = size(stim);
elseif Dim_stim == 1
    N_flips = length(stim);
end

% make fliptimes row vector (1 col) for easy upsampling
if ~isrow(fliptimes)
    fliptimes = fliptimes.';
end

% inter frame interval
r_ifi = rtime(2)-rtime(1);
f_ifi = fliptimes(2)-fliptimes(1); % upsampling of stim
if upsampling == 1
    fliptimes = fliptimes +0.5*f_ifi;
elseif upsampling == 2
    fliptimes = [fliptimes+0.25*f_ifi; fliptimes+0.75*f_ifi];
end
fliptimes = reshape(fliptimes, [], 1);

% resample stim at recording (or imaging) times
sstim = reshape(stim, [], N_flips);   % reshaped stim. [t1 t2 t3 ..] coulmn vector as time goes.
sstim = expandTile(sstim, 1, upsampling);
sstim = double(sstim);
sstim = interp1(fliptimes, sstim.', rtime(rtime>fliptimes(1))); % recording times after the first flip. [N (times), D1, D2, ..] for V
sstim = sstim.';
rdata = rdata(rtime>fliptimes(1));                              % recording data  only after the first flip

% set end point
sstim = sstim(:, ~isnan(sstim(1,:))); % exclude NaN elements
[~, N_flips] = size(sstim);
rdata = rdata(1:N_flips); % col# increase as time goes

% normalization
rdata = rdata - mean(rdata);
sstim = scaled(sstim)-0.5;

% # of frames for maxlag duration
N_maxcorr = round(maxlag/r_ifi);

% Ignore first N_maxcorr frames for correlation
onset_idx = N_maxcorr + 1;
if N_maxcorr > length(rdata)
    disp('Length of the data is shorter than the correlation length of your interest');
    return;
end 

% Limit data after onset for correlation 
rdata = rdata(onset_idx:end);
Ndata = length( rdata );
% fprintf('# of rec data = %d, # of resampled stim frames (range) = %d\n', Ndata, N_flips);
% fprintf('Data point difference = %d, onset index = %d\n', N_flips-Ndata, onset_idx);

% correlation by dot product with varying delay
rf = [];
for i=0:N_maxcorr
    range = (onset_idx-i):(onset_idx-i + Ndata-1);
    corr = sstim(:,range) * rdata;
    rf = [rf, corr]; 
end

% Reshape RF matrix same as stim dims
if Dim_stim == 3 && Xstim ~= 1 && Ystim ~= 1 
    rf = reshape(rf,Xstim,Ystim,[]);
else
    % do nothing.
end

% display
%displayRF(rf);

end

function p = ParseInput(varargin)
    p  = inputParser;   % Create an instance of the inputParser class.

    % Gabor parameters
    p.addParameter('stimFrameInterval', 0.0332295, @(x)x>=0); % Juyoung
    %p.addParameter('stimFrameInterval', 0.01667294, @(x)x>=0); % Mike
    %p.addParameter('stimFrameInterval', 0.0300147072065313, @(x)x>=0); % David RF stimulus
    p.addParameter('samplingRate', 10000, @(x)x>=0);
    p.addParameter('nBinning', 1, @(x) x>=0 && x<=255);
    
    % 
    p.parse(varargin{:});
end