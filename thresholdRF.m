function rf = thresholdRF(data, time, num_bin, stim, fperiod, avgtime)
    % Detect events after binning (averaging) and calculate RF using
    % prerunned stimulus
    % time : DAQ time when it measured the data. 
    % stim: whole stim data
    % avgtime: time duration for STA or Event-Triggered Avg.
    % Assumption: data and stimulus are synchronized.
    bindata = binning1d(data, num_bin);
    bintime = binning1d(time, num_bin);
    
    % two level thresholding
    th1 = mean(bindata);
    r = 0.65;
    th2 = r*max(bindata)+(1-r)*min(bindata);
    
    % Analyze bindata and get the event timestamps in real time unit.
    idx1 = th_crossing(bindata,th1);
    idx2 = th_crossing(bindata,th2);
    idx = [idx1,idx2];
    % 
    EventStamps = bintime(idx2);
    
    % real time stamps of the stimulus edges
    % stim(i) = (edge(i) + edge(i+1))/2
    totframeN = size(stim, 3);
    stim_binedges = 0:fperiod:(totframeN-1)*fperiod;
    % n_avgbin = 20; % frameduration 30 ms * 20 = 600 ms
    N_avgbin = round(avgtime/fperiod);
    % calculate RF
    rf = evTriggerAvg(stim, stim_binedges, N_avgbin, EventStamps);
    
    % display
    displayRF(rf);
end

% fperiod? 0.333 ?
% rf = calculateRF(resp(range),dtime(range), 100, stim, 0.03)