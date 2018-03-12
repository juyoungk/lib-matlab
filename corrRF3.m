function rf = corrRF3(rdata, rtime, stim, fliptimes, upsampling, maxlag, varargin)
% version3: fliptimes as input
% Optimized for sampling rate ~ stim flip rate
% delay time 0 to maxlag as increasing col#
% Default setting: 10K sampling data, 100 binning, 0.033 flipinterval
% rtime: recording timestamps (real time)
% stim: checker box array sequence (type:doulble, row * col * # frames)
% upsampling: of stimulus
p = ParseInput(varargin{:});

stimFrameInterval = fliptimes(2)-fliptimes(1);     
     samplingRate = 1/(rtime(2)-rtime(1));

% stim size & reshape [ch, frames]
Dim_stim = ndims(stim);
if Dim_stim >3
    disp('stim is dim>3 array. It should be dim 1-3 data');
    rf = [];
    return;
elseif Dim_stim ==3
    [Xstim, Ystim, Nframe] = size(stim);
elseif Dim_stim == 2
    [Ystim, Nframe] = size(stim);
elseif Dim_stim == 1
    Nframe = length(stim);
end

% Reshape and then limit the stim only during the recording time
stim = reshape(stim, [], Nframe);   % reshaped stim. [t1 t2 t3 ..] coulmn vector as time goes.
[stim, ~] = rangeSample(stim, fliptimes, rtime(1), rtime(end)); 
[~,NframeRange] = size(stim);
%
fprintf('\n');
fprintf('fliptime(1) = %.3f s, fliptime(end) = %6.3f s, %d frames (total)\n', fliptimes(1), fliptimes(end), Nframe);
fprintf('   rtime(1) = %.3f s,    rtime(end) = %6.3f s, %d frames (range)\n\n', rtime(1), rtime(end), NframeRange);

% Stim upsampling (after reshape?)
sstim = expandTile(stim, 1, upsampling);
stimInterval = stimFrameInterval/upsampling;

    % rate matching by rdata binning? This was used for corrRF1,2
    % srate = rtime(2)-rtime(1);
    % num_bin = max(1, round(stimInterval*samplingRate)); % Estimate binning number

% resample stim at recording (or imaging) times
sstim = double(sstim);
sstim = interp1(fliptimes, sstim, rtime(rtime>fliptimes(1))); % automatically limits time range of stim.
rdata = rdata(rtime>fliptimes(1));
% 
% %
% fprintf(' stimulus flip interval = %.5f,  upsampling = %d\n', stimFrameInterval, upsampling); 
% fprintf('Upsampled flip interval = %.5f\n', stimInterval);
% fprintf('       data sampling rate = %.5f, binning num = %d\n', srate, num_bin);
% fprintf('binned data sampling rate = %.5f\n\n', num_bin*srate);
% %
% bindata = binning1d(rdata, num_bin);
% bintime = binning1d(rtime, num_bin);

% check the size for dot product btw upsampled stim and binned data
[~,Nframe] = size(sstim);
Ny = length(bindata);
fprintf('Data size after binning: %d, (upsampled stimulus frames = %d)\n\n', Ny, Nframe);
if Nframe > Ny
    sstim = sstim(:, 1:Ny);
elseif Nframe < Ny
    bindata = bindata(1:Nframe);
end
% reshape bindata for dot product
bindata = reshape(bindata, [], 1); % column vector

% # of frames for maxlag duration
N_maxcorr = round(maxlag/stimInterval);
% Ignore first N_maxcorr frames for correlation
onset_idx = N_maxcorr + 1;
if N_maxcorr > length(bindata)
    disp('Length of the data is shorter than the correlation length of your interest');
    return;
end 

% normalization for the correlation computation
norm_bindata = bindata - mean(bindata);
norm_sstim = scaled(double(sstim))-0.5;

% Limit data after onset for correlation 
norm_bindata = norm_bindata(onset_idx:end);
Ndata = length( norm_bindata );
fprintf('# of binned rec data = %d, # of upsampled stim frames (range) = %d\n', Ndata, Nframe);
fprintf('Data point difference = %d, onset index = %d\n', Nframe-Ndata, onset_idx);

% correlation by dot product with varying delay
rf = [];
for i=0:N_maxcorr
    range = (onset_idx-i):(onset_idx-i + Ndata-1);
    % fprintf('(onset_idx-i) = %d, (onset_idx-i + Ndata-1) = %d\n', (onset_idx-i), (onset_idx-i + Ndata-1));
    % onset_idx - N_maxcorr = 1 (by definition)
    corr = norm_sstim(:,range) * norm_bindata;
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

fprintf('\n');
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