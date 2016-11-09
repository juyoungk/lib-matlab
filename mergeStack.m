function C = mergeStack(A, B, varargin)
%
% C = mergeStack(A, B, varargin)
% Direct merge between A and B

if (ndims(A) ~= 3) || (ndims(B) ~= 3)
    disp('fn: mergeStack: either A or B are not image stacks.');
    return
end

[row_a, col_a, frame_a] = size(A);
[row_b, col_b, frame_b] = size(B);

if frame_a ~= frame_b
    disp('fn: mergeStack: unmatched frame numbers');
    return
end

nframe = frame_a;

% Parameters for contrast fractions
nVarargs = length(varargin);
switch nVarargs
    case 0
        fraction1 = 0.5;
        fraction2 = 0.5;
    case 1
        fraction1 = varargin{1};
        fraction2 = varargin{1};
    case 2
        fraction1 = varargin{1};
        fraction2 = varargin{2};
end

C = zeros(max(row_a, row_b), max(col_a, col_b), 3, nframe);

for i=1:nframe
    C(:,:,:,i) = merge(A(:,:,i),B(:,:,i), fraction1, fraction2);
end

end
