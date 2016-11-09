function Aout = ch_normalize(data)

[row, col, d3, d4] = size(data);
% nVarargs = length(varargin);

Aout = zeros(size(data));

for i = 1:d3
    Aout(:, :, i, :) = scaled(data(:, :, i, :));
end


end