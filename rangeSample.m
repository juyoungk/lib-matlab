function [qy, qx] = rangeSample(y, x, a, b)
%
% [qy, qx] = rangeSample(y, x, a, b)
%
% y & x are timed data as "coulumn" number increases.
% y: data. if Dim==2, [t1, t2, t3, ..] is assumed. time progress as column
% x: timestamps
% a: start time (x) of the new data
% b: end time (x) of the new data
% # Assumption: y and x starts simulataneously.
% 1. y and x data size compare
% 2. pick timestamps which lies in the time(x) range [start, end] 
% 3. Return qy and qx

% 
Nx = length(x); 
% DATA (y) info and reshape 
Dim = ndims(y);
if Dim >2
    disp('[fn: rangeSample] data (y) is dim>3 array. It should be 1-D or 2-D data');
    qy = []; qx = [];
    return;
elseif Dim == 2
    [Ny_row, Ny_col] = size(y);
    Nt = Ny_col;
elseif Dim == 1
    Nt = length(y);
    % Timeindex should be column index.
    if iscolumn(y)
        y = y';
    end
end

if Nx > Nt
    x = x(1:Nt);
elseif Nx < Nt
    y = y(:, 1:Nx);
end
[Nch, Nt] = size(y);

% start, end is in the range of x?
if a < x(1)
    fprintf('[fn: rangeSample] Start(%.3f) is earlier than the initial point of x (%.3f)\n', a, x(1));
    a = x(1);
end
if b > x(end)    
    fprintf('[fn: rangeSample] End(%.3f) is later than the last point of x (%.3f)\n', b, x(end));
    b = x(end);
end

idx = find(x>=a & x<=b);
qx = x(idx);
qy = y(:,idx);

end