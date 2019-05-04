function y = roimean(vol, pixelIdxList, x, y)
% Average over ROI pixels (pixelIdsList) with shift parameter x and y.
% vol (or rehsaped vol)
% x(roi, t), y(roi, t)
% Interpolration bwtween integder pixel shift.


    if nargin < 4
        x = 0;
    end
    if nargin < 3
        y = 0;
    end


end

% Note


% Wrapper function?
% roimean(r, roi id, t)
% since x(roi, t), y(roi, t)

% what should be passed to roiData?
% wouldn't be effective to generate many 
% library for each roi? !!

% roi_trace[times][id] : final trace
% r.traces{roi id}{shift id} --> library of the traces! 

% Given x, y --> shift id
% shiftid(roi, x, y)
