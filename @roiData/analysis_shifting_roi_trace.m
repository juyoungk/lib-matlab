%% Analysis for Bilinear interpolation of shifting ROI
r = g.rr;

%% How much was the ROI shifted over time?

%% 1. Compute shift params for multiple snap shots of ROIs

%% 2. Interpolate x, y for all frames (or 1st sess. trigger to last trigger)
sampled_times = r.snaps_middle_times;
roi_xy_shifts = r.roi_shift_snaps;

r.roi_shift_xy_interpolation(r.snaps_middle_times, roi_xy_shifts);
% r.roi_shift has been updated.

%% plot interpolated shift trajectories
figure;
plot(r.f_times, r.roi_shift.x); hold on
plot(sampled_times, roi_xy_shifts.x, 'o')

figure;
plot(r.f_times, r.roi_shift.y); hold on
plot(sampled_times, roi_xy_shifts.y, 'o')

%% 3. 
[r.traces_xlist, r.traces_ylist] = utils.integer_xy_offset_lists(r.roi_shift_snaps.x, r.roi_shift_snaps.y);

disp(r.traces_xlist)
disp(r.traces_ylist)


% 4. 




%%
xnum = length(r.traces_xlist);
ynum = length(r.traces_ylist);
xmax = r.traces_xlist(end); % it can be either 0 (neg x) or n-1 (pos x)
ymax = r.traces_ylist(end);
xmin = r.traces_xlist(1);
ymin = r.traces_ylist(1);

%% Bilinear Interpolation test
roi = 159;
t = 200*20;

x = r.roi_shift.x(t, roi);
y = r.roi_shift.y(t, roi);

% direct x y input test
x = -5.99;
y = 1.99;

f = r.traces{roi};

%
[xrange, xratio] = decompose(x)
[yrange, yratio] = decompose(y)

% Make the range within the max & min of (x,y) list 
xrange = min([xrange; xmax xmax], [], 1);
xrange = max([xrange; xmin xmin], [], 1)
yrange = min([yrange; ymax ymax], [], 1);
yrange = max([yrange; ymin ymin], [], 1)
% Convert into index
xid = xrange + (xnum-xmax)
yid = yrange + (ynum-ymax)
% Grid value matrix
M = [ f(t, xid(1), yid(1)) f(t, xid(1), yid(2)); f(t, xid(2), yid(1)) f(t, xid(2), yid(2)) ]
%
interpolarted = xratio * M * yratio.'
%%
figure;
times = 4000:5000;
output = zeros(length(times), 1);
for i=1:length(times)
    t = times(i);
    output(i) = r.roi_trace_interpolated(roi, t, x, y);
end
plot(times, output)

%%
function [int_range, ratio] = decompose(x)

    lower = floor(x);
    int_range = [lower lower+1];
    
    % dist
    d = abs(int_range - x);
    ratio = [d(2) d(1)];

end



