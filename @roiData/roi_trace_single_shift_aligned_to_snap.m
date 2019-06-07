function trace = roi_trace_single_shift_aligned_to_snap(r, snap_id, rois)
% ROI trace with drifted ROI pixellist aligned with one of the snap iamges
% saved in roiData class.
        
    if nargin < 3
        rois = 1:r.numRoi;
        disp('All ROIs are selected for estimating the interpolated traces.');
    end
    numRoi = length(rois);
    
    trace = zeros(r.numFrames, numRoi);
    
    for i = 1:numRoi
        
        roi = rois(i);
        
        x = r.roi_shift_snaps.x(snap_id, roi);
        y = r.roi_shift_snaps.y(snap_id, roi);
        
        for t = 1:r.numFrames
            trace(t, i) = r.roi_trace_interpolated(t, roi, x, y);
        end

    end
    
end