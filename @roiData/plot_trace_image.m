function plot_trace_image(r, rois)

if nargin < 2
    rois = r.roi_good(1:64);
end

figure('Position', [170 350 1500 450]);

%
y = r.roi_smoothed_norm(:, rois);

% clim: lower than 250%
clim = min(max(abs(y(:))), 150);

imagesc(y.', [-clim, clim]);
xlabel('times');
ylabel('ROI ids');

end