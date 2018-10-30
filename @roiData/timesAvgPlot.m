function tt = timesAvgPlot(r)
% consider using 'traceAvgPlot' function instead. It outputs time series as
% a second variable.

    duration = r.avg_trigger_interval;
    
    % convert c_range to real time
    
    tt = duration * r.c_range;
    
    % still under construction?

end