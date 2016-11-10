function rf = STA(spikes_t_stamps, STA_duration, stim, upsampling, fperiod)
% Spike-triggered average from time stampes
% Time stamps are given by spike sorting of MEA recording data.
% stim: 3-D array 
% fperiod: stim frame rate.
% 2016 SEP, Juyoung Kim

if nargin < 5
    %fperiod = 0.03322955
    fperiod = 0.01176470588*3 % D239 85Hz monitor, waitframe = 3
end

if nargin < 4
    upsampling = 2
end


% stim size & reshape [ch, frames]
Dim = ndims(stim);
if Dim >3
    disp('stim is dim>3 array. It should be dim 1-3 data');
    rf = [];
    return;
elseif Dim ==3
    [row, col, Nframe] = size(stim);
elseif Dim == 2
    [col, Nframe] = size(stim);
elseif Dim == 1
    Nframe = length(stim);
end

% Reshape stim
stim = reshape(stim, [], Nframe);   % reshaped stim
% Stim upsampling for 2x or 3x resolution
stim = expandTile(stim, 1, upsampling);
fperiod = fperiod/upsampling;
Nframe = Nframe*upsampling;

%
stim_binedges = 0:fperiod:(Nframe-1)*fperiod;
N_STA_bin = round(STA_duration/fperiod);
% reshape again
stim = reshape(stim, row, col, Nframe);

%
rf = evTriggerAvg(stim, stim_binedges, N_STA_bin, spikes_t_stamps);
% display
displayRF(rf, fperiod);

end