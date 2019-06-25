function plot_roi_shift(r, ids)

if nargin < 2
    ids = r.roi_good(1:20);
end

%color_list = lines(numel(ids));

sampled_times = r.snaps_middle_times;
roi_target_shifts = r.roi_shift_snaps;

figure;

plot(r.f_times, r.roi_shift.x(:,ids)); hold on

ax = gca;
ax.ColorOrderIndex = 1;

plot(sampled_times, roi_target_shifts.x(:,ids), 'o')
title('ROI shift: x');
ff;

figure;

plot(r.f_times, r.roi_shift.y(:,ids)); hold on

ax = gca;
ax.ColorOrderIndex = 1;

plot(sampled_times, roi_target_shifts.y(:,ids), 'o')
title('ROI shift: y');
ff;

fprintf('%d objects'' offset trajectories has been plotted.\n', numel(ids));

end