function [xlist, ylist] = integer_xy_offset_lists(x_offset, y_offset)
% outputs all possible integer combinations of x & y from given x_offset & y_offset matrices.  
% x_offset [shift values x roi ids]
% y_offset [shift values x roi ids]
%
% Assumption: monotonic increase or decrease

    if ~all( size(x_offset) == size(y_offset) )
        error('offset vectors (or matrices) have different sizes.');
    end
    
    x_all = x_offset(:);
    y_all = y_offset(:);
    
    xlist = floor(min(x_all)):ceil(max(x_all));
    ylist = floor(min(y_all)):ceil(max(y_all));

    %
    if max(abs(xlist)) > 8
        disp('Very large x offset > 8 exists.');
    end
    if max(abs(ylist)) > 8
        disp('Very large y offset > 8 exists.');
    end

%    [xlist, ylist] = meshgrid(xlist, ylist);
%     xlist = xlist(:); % vectorize
%     ylist = ylist(:); % vectorize
end


function addconstant = int_index_in_array(int_array)

n = length(int_array);
m = max(int_array);

% index = value + (num - max);



end