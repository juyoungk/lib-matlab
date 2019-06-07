function trace = roi_trace_dynamic_xy(r, rois)

    if isempty(r.roi_shift) || isempty(r.roi_shift.x) || isempty(r.roi_shift.y)
        error('x & y shift trajectories are not yet interpolated.');
    end

    numRoi = length(rois);
    trace = zeros(r.numFrames, numRoi);
    
    % params for x,y -> index
    xnum = length(r.traces_xlist);
    ynum = length(r.traces_ylist);
    xmax = r.traces_xlist(end); % it can be either 0 (neg x) or n-1 (pos x)
    ymax = r.traces_ylist(end);
    xmin = r.traces_xlist(1);
    ymin = r.traces_ylist(1);

    for id = 1:numRoi
        
        roi = rois(id);
        f = r.traces{roi};

        for t = 1:r.numFrames

            % xy at frame t
            x = r.roi_shift.x(t, roi);
            y = r.roi_shift.y(t, roi);
            
            trace(t, id) = r.roi_trace_interpolated(id, t, x, y);
            
            

            [xrange, xratio] = decompose(x);
            [yrange, yratio] = decompose(y);

            % Make the range within the max & min of (x,y) list 
            xrange = min([xrange; xmax xmax], [], 1);
            xrange = max([xrange; xmin xmin], [], 1);
            yrange = min([yrange; ymax ymax], [], 1);
            yrange = max([yrange; ymin ymin], [], 1);

            % Convert into index
            xid = xrange + (xnum-xmax);
            yid = yrange + (ynum-ymax);

            % Grid value matrix for bilinear interpolation
            M = [ f(t, xid(1), yid(1)) f(t, xid(1), yid(2)); f(t, xid(2), yid(1)) f(t, xid(2), yid(2)) ];
            
            % Interpolated roi trace
            trace(t, id) = xratio * M * yratio.';
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