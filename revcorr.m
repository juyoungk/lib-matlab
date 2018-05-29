function rf = revcorr(x, y, corr_length)
% Reverse correlation between aligned signals x & y (same lengths)
%
% Input: 
%
%       x (or stim): 2D matrix. [ch, frames] (reshaped)
%       y          : Vector. Response.
%
%       corr_length: correlation length or window size.
%
% Output: 
%       rf - [ch, time delay]


if nargin < 3
    corr_length = 40;
end

if ~isvector(y)
    error('Input (y) should be a vector.');
end

if size(x, 2) ~= length(y)
    disp('x and y has differnet sampling points (or frames).');
end

x_rolled = rollingwindow(x, corr_length);
rf = zeros(size(x, 1), corr_length);

for i = 1:size(x_rolled, 3)
    rf = rf + x_rolled(:,:,i) * y(corr_length + i -1);
end


end