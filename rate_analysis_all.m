function [mean_r, peak_r, peak_t, first_t] = rate_analysis_all(rates, bin_size, t_window, name, draw_plot, varargin)
%
% input:
%       rates - cell arrays of [m X n] FR array
if nargin <5
    draw_plot = 1;
end

if nargin <4
    name = [];
end

num = numel(rates);

mean_r = cell(1, num);
peak_r = cell(1, num);
peak_t = cell(1, num);
first_t = cell(1, num);

for i=1:num
    [mean_r{i}, peak_r{i}, peak_t{i}, first_t{i}, h_title] = rate_analysis(rates{i}, bin_size, t_window, draw_plot, varargin);
    if draw_plot
        title(h_title, [name, ' ', num2str(i)]);
    end
end

end
