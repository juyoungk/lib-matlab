function plot_roi_shift(r)

sampled_times = r.snaps_middle_times;
roi_target_shifts = r.roi_shift_snaps;

figure;

plot(r.f_times, r.roi_shift.x); hold on

plot(sampled_times, roi_target_shifts.x, 'o')
title('ROI shift: x');
ff;

figure;

plot(r.f_times, r.roi_shift.y); hold on

plot(sampled_times, roi_target_shifts.y, 'o')
title('ROI shift: y');
ff;


end