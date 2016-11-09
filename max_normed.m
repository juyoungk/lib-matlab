function norm_data = max_normed(data)
% 
% Normalized data by its max value. No subtraction of background

% data conversion if a is an integer array
a = double(data);

% Normalization
norm_data = a / (max(a(:))+0.001);

end