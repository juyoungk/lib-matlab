function roi_shift_xy_interpolation(r, times, shifts)
% Given 'x, y shifts' for 'times', the function will interpolate x,y shifts
% for all frame times.
% 
% inputs:
%       times - sampling times
%       shifts - struct having x & y at sampled times.

if nargin < 2
     times = r.snaps_middle_times;
    shifts = r.roi_shift_snaps;
end

r.roi_shift.x = zeros(r.numFrames, r.numRoi);
r.roi_shift.y = zeros(r.numFrames, r.numRoi);

for roi = 1:r.numRoi
%     r.roi_shift.x(:,roi) = spline(times, shifts.x(:,roi), r.f_times);
%     r.roi_shift.y(:,roi) = spline(times, shifts.y(:,roi), r.f_times);
    r.roi_shift.x(:,roi) = interp1(times, shifts.x(:,roi), r.f_times, 'pchip', 'extrap');
    r.roi_shift.y(:,roi) = interp1(times, shifts.y(:,roi), r.f_times, 'pchip', 'extrap');
end
disp('roi shift x & y were interpolated between offset of snapshots.');

% zero offset x, y at roi_cc_time
i_frame = find(r.f_times > r.roi_cc_time, 1);
r.roi_shift.x = r.roi_shift.x - r.roi_shift.x(i_frame, :);
r.roi_shift.y = r.roi_shift.y - r.roi_shift.y(i_frame, :);
fprintf('Offset x, y were zeroed at time %.1f sec (roi_cc_time).\n', r.roi_cc_time);

%% Reject odd cases


%% Integer grid of shift xy
% only after the 1st trigger from all ROIs
xshift = r.roi_shift.x(r.f_times>r.snaps_trigger_times(1), :);
yshift = r.roi_shift.y(r.f_times>r.snaps_trigger_times(1), :); 

% or limit the range on shifted values of snaps
xshift = r.roi_shift_snaps.x;
yshift = r.roi_shift_snaps.y;
disp('roi shift range - limited by offsets in snapshots.');

[r.traces_xlist, r.traces_ylist] = utils.integer_xy_offset_lists(xshift, yshift);
disp('Integer x y shift grid was selected for a library of traces.');
% i = x + (xnum-xmax)
% j = y + (ynum-ymax)
%r.i_for_xshift
%r.j_for_xshift
               
% Params for trace library
r.roi_shift.xnum = length(r.traces_xlist);
r.roi_shift.ynum = length(r.traces_ylist);
r.roi_shift.xmax = r.traces_xlist(end); % it can be either 0 (neg x) or n-1 (pos x)
r.roi_shift.ymax = r.traces_ylist(end);
r.roi_shift.xmin = r.traces_xlist(1);
r.roi_shift.ymin = r.traces_ylist(1);
end