function [a_demean, baseline] = demean_baseline(a, i_baseline, f_baseline)
% Substract the baseline level, which is the mean over a fraction of
% datapoints starting from i-th to (i + numpoints -1)-th data.

if ndims(a) ~= 2
    error('Input should be a matrix (ndims = 2).');
end

[nrows, ~] = size(a);

if i_baseline > nrows
    error('Too large index for baseline start index.');
end

if f_baseline > nrows
    error('Too large index for baseline end index.');
end

baseline = mean( a(i_baseline:f_baseline, :), 1);
a_demean = a - baseline;

end