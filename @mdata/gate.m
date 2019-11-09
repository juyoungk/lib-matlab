function count_gated = gate(m, ti, window_size)
% gate the counts over a certain time window in DTOF
% window_size in nano-second unit.

if nargin < 3
    window_size = 1; %ns
end

i = find(m.tau > ti, 1);
numBins = window_size * 1000 / m.dtof_param.resolution;
fprintf('numBins for time gating : %d\n', numBins);

dtof_gated  = m.dtof(i:i+numBins-1, :, :);
count_gated = sum(dtof_gated, 1);
count_gated = squeeze(count_gated); % ch x timestamps

end