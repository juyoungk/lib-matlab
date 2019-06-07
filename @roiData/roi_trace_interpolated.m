function trace_at_frame_t = roi_trace_interpolated(r, t, roi, x, y)
% For single roi id, with given arbitrary x & y shift values, the function
% will compute the interpolated output of roi-averaged pixel intensity
% inputs:
%       t - frame id
    
    if nargin < 5
        y = r.roi_shift.y(t, roi);
    end
    
    if nargin < 4
        x = r.roi_shift.x(t, roi);
    end
    
    if nargin < 3 
        error('Please specify roi id,');
    end
    
    if roi > r.numRoi
        error('Invalid ROI id.');
    end
    
    [xrange, xratio] = decompose(x);
    [yrange, yratio] = decompose(y);

    % Make the range within the max & min of (x,y) list 
    xrange = min([xrange; r.roi_shift.xmax r.roi_shift.xmax], [], 1);
    xrange = max([xrange; r.roi_shift.xmin r.roi_shift.xmin], [], 1);
    yrange = min([yrange; r.roi_shift.ymax r.roi_shift.ymax], [], 1);
    yrange = max([yrange; r.roi_shift.ymin r.roi_shift.ymin], [], 1);

    % Convert into index
    xid = xrange + (r.roi_shift.xnum-r.roi_shift.xmax);
    yid = yrange + (r.roi_shift.ynum-r.roi_shift.ymax);
    
    f = r.traces{roi};

    % Grid value matrix for bilinear interpolation
    M = [ f(t, xid(1), yid(1)) f(t, xid(1), yid(2)); f(t, xid(2), yid(1)) f(t, xid(2), yid(2)) ];

    % Interpolated roi trace
    trace_at_frame_t = xratio * M * yratio.';
    
end

function [int_range, ratio] = decompose(x)

    lower = floor(x);
    int_range = [lower lower+1];
    
    % dist
    d = abs(int_range - x);
    ratio = [d(2) d(1)];

end