function scaled = scaled(data)
% Scale the (2-D) matrix a onto [0, 1] range.
% For true color image.
% Min & Max operation will be made over whole elements.

% data conversion if a is an integer array
a = double(data);

min_subtracted = a - min(a(:));
scaled = min_subtracted/(max(min_subtracted(:))+0.001);

end