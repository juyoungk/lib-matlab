function [mean_r, peak_r, peak_t, first_t] = rate_analysis_all(rates, bin_size, varargin)
%
% input:
%       rates - cell arrays of [m X n] FR array

num = numel(rates);

mean_r = cell(1, num);
peak_r = cell(1, num);
peak_t = cell(1, num);
first_t = cell(1, num);

for i=1:num
    [mean_r{i}, peak_r{i}, peak_t{i}, first_t{i}] = rate_analysis(rates{i}, bin_size, varargin);
end

end
