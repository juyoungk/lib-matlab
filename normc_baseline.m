function [a_norm, baseline] = normc_baseline(a, i_baseline, f_baseline)
% Column normalization by baseline. 
% baseliene will be estimate by a fraction of datapoints, starting from
% i-th to (i + numpoints -1)-th data.

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
a_norm = (a - baseline)./baseline * 100;

end