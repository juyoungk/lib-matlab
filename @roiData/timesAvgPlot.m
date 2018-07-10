function tt = timesAvgPlot(r)
% Intersected range between c_range & t_range
% e.g.) c_range = [-0.25, 1.25];


    duration = r.avg_trigger_interval;
    
    % convert c_range to real time
    
    tt = duration * r.c_range;
    


end