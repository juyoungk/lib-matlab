function C = mergeStack2Ch(a, ch1, b, varargin)
%
% a = [row col frame ch]; Channel should be 4-th dim.
%
% merged_stack = mergeStack2ch(a, ch1, ch2)
% merged_stack = mergeStack2ch(a, ch1, b)
% merged_stack = mergeStack2ch(a, ch1, b, ch2)

if ndims(a) ~= 4
    disp('invalid dimension of image stack');
    return
end

if ~isscalar(ch1)
    disp('invalid ch1 value.');
    return
end

[row, col, frame, ch] = size(a);
nVarargs = length(varargin);

A = comp(a, ch1);
if isscalar(b)
    ch2 = b;
    B = comp(a, ch2);
elseif ndims(b) == 3
    B = b;
    disp('2nd image stack has No channels.');
elseif ndims(b) == 4
    if nVarargs < 1
        disp('Ch should be specified for imagestack b');
        return
    end
    B = comp(b, varargin{1});
else
    disp('Invalid image stack type');
    return
end

C = mergeStack(A, B);

end