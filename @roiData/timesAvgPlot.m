function tt = timesAvgPlot(r)

    duration = r.avg_trigger_interval;
    
    % convert c_range to real time
    
    tt = duration * r.c_range;
    


end