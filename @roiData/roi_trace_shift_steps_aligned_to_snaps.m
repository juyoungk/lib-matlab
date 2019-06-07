function traces = roi_trace_shift_steps_aligned_to_snaps(r, rois)
%
%  snap1 -  snap2 -  snap3 - ..
% shift1 - shift2 - shift3 - ..
% trace1 - trace2 - trace3 - ..
% 
% exclude last snap. 
% update roi_trace for given rois.

if nargin < 2
    rois = 1:r.numRoi;
end

numRoi = length(rois);

numSnaps = size(r.snaps, 3);

traces = zeros(r.numFrames, numRoi);

preparation_time = 10; % sec


for i = 1:numRoi
        
    roi = rois(i);

    for s = 1:numSnaps-1 % exclude last snap
        
        y = roi_trace_single_shift_aligned_to_snap(r, s, roi);
        
        % start time
        if s == 1
            t = 0;
        else
            t = max(r.snaps_trigger_times(s) - preparation_time, 0);
        end
        
        % udpate after the start time
        y = y(r.f_times > t);
        
        traces(r.f_times > t, i) = y;
        
        % update roi_trace
        r.roi_trace(r.f_times > t, roi) = y;
    end
    
end


end