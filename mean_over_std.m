function snr = mean_over_std(y)
% Average and std over dim 1, then compute mean/avg (one less dimension) 
% signal can be a contrast: y - y(:,:,ref_id);

%delta = y - y(:,:,ref_id);

% stat over dim 1
delta_mean = squeeze(mean(y));
delta_std = squeeze(std(y));

snr = delta_mean./delta_std;
end