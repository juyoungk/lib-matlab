function plot_trace_image(r, rois)

if nargin < 2
    num_cells = min(r.numRoi, 64);
    rois = r.roi_good(1:num_cells);
end

if isempty(rois)
    return;
end

figure('Position', [170 350 1500 450]);

%
y = r.roi_smoothed_norm(:, rois);

% clim: lower than 120%
clim = min(max(abs(y(:))), 120);

imagesc(y.', [-clim, clim]);
xlabel('times');
ylabel('ROI ids');

end