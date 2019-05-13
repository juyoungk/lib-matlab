function trace = roi_trace_interpolated(r, roi, x, y)
% For single roi id, mew Trace will be interpolated with a fixed amount of shift (offset) x & y for all frame times.
% x & y would be different for different ROI id. 
    
    if roi > r.numRoi
        error('Invalid ROI id.');
    end

    trace = zeros(r.numFrames, 1);

    % x & y
    [xint, xratio] = decompose(x);
    [yint, yratio] = decompose(y);

    xnum = length(r.traces_xlist);
    ynum = length(r.traces_ylist);
    xmax = r.traces_xlist(end); % it can be either 0 (neg x) or n-1 (pos x)
    ymax = r.traces_ylist(end);

    % index for x & y shift
    xid = xint + (xnum-xmax);
    yid = yint + (ynum-ymax);


    for i = 1:2 % range start end
    for j = 1:2
            trace = trace + xratio(i) * yratio(j) * r.traces{roi}(:, xid(i), yid(j));
    end
    end

end

function [int_range, ratio] = decompose(x)

    lower = floor(x);
    int_range = [lower lower+1];
    
    % dist
    d = abs(int_range - x);
    ratio = [d(2) d(1)];

end