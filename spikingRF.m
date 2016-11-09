function [rf, t_stamps] = spikingRF(data, pSampling, num_bin, stim, fperiod, avgtime)
%
% Extract spiking events from intracellular raw recording data and compute
% the STA (Spike-Triggered-Average)
%
% 1. Binning (averaging)
% 2. Detect spiking events
% 3. Calculate spiking rate and interspike time histogram
% 4. Calculate RF using prerunned stimulus
%
% pSampling : sampling period of the data, e.g. 0.0001 (10K sampling)
% stim: whole stim data
% avgtime: time duration for STA or Event-Triggered Avg.
% Assumption: data and stimulus are synchronized.

    bindata = binning1d(data, num_bin);
    th_spiking = -35;
    % Analyze bindata and get the event timestamps in real time unit.
    idx = th_crossing(bindata,th_spiking);
    % stamps for spiking events
    t_stamps  = idx * pSampling * num_bin;
    
    % real time stamps of the stimulus edges
    % stim(i) = (edge(i) + edge(i+1))/2
    totframeN = size(stim, 3);
    stim_binedges = 0:fperiod:(totframeN-1)*fperiod;
    
    stat_spikes(t_stamps, stim_binedges(end));
    
    % n_avgbin = 20; % frameduration 30 ms * 20 = 600 ms
    N_avgbin = round(avgtime/fperiod);
    % calculate RF
    rf = evTriggerAvg(stim, stim_binedges, N_avgbin, t_stamps);
    
    % display
    displayRF(rf);
end

% fperiod? 0.333 ?