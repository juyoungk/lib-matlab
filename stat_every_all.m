function [r_avg, r_std] = stat_every_all(r, num, dim)
% r is 1 X N cells
% output r_avg and r_std is also 1 X N cells.

    if nargin < 3
        dim = 1; % average or std along row directions.
    end
    if dim > 2
        error('Invalid dimension for statistics');
    end
    if ~iscell(r)
        error('Input is not a cell or an array of cells.');
    end

    n_cell = numel(r);
    r_avg = cell(1, n_cell);
    r_std = cell(1, n_cell);
    
    for i = 1:n_cell
        [r_avg{i}, r_std{i}] = stat_every(r{i}, num, dim);
    end

end