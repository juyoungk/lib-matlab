function trace = roi_trace_interpolated_xy_trajectory(r, rois, frame_ids)
% 
%   rois      - list of roi ids for interpolation
%   frame_ids - list of ids for frames
    
    if nargin < 3
        frame_ids = 1:r.numFrames;
    end

    numFrames = length(frame_ids);
    numRois = length(rois);
    
    trace = zeros(numFrames, numRois);
    
    for j = 1:numRois
    for i = 1:numFrames
        
        t = frame_ids(i);
        roi = rois(j);
        
        x = r.roi_shift.x(t, roi);
        y = r.roi_shift.y(t, roi);
        
        trace(i, j) = r.roi_trace_interpolated(t, roi, x, y);
    end
    end
    
end
