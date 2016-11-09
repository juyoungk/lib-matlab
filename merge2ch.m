function C = merge2ch(a, ch1, b, varargin)
%
% CH should be the last dimension of data set.
% merge2ch(a, ch1, ch2)
% merge2ch(a, ch1, ch2, fraction)
% merge2ch(a, ch1, ch2, fraction1, fraction2)

% merge2ch(a, ch1, B)
% merge2ch(a, ch1, b, ch2)
% merge2ch(a, ch1, B, ch2, fraction)
% merge2ch(a, ch1, B, ch2, fraction1, fraction2)
%

%
% merge 2 images [row col ch] into composite image
%
if isscalar(a)
    disp('fn: merge2ch: A is a scalar. Not an image. error.');
    return;
elseif ismatrix(a) 
    disp('fn: merge2ch: A is a just 2-D image. ch1 value was ignored.');
    A = a;
elseif ndims(a) == 3
    A = comp(a, ch1);
else
    disp('fn: merge2ch: A is an invalid image data.');
    return;
end

nVarargs = length(varargin);
        
if isscalar(b)
    B = comp(a, b);
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
    
elseif ismatrix(b)
    B = b;
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
 
elseif ndims(b) == 3
    switch nVarargs
        case 0
            disp('fn: merge2ch: CH for stack B should be specified.');
            return;
        case 1
            B = comp(b, varargin{1});
            fraction1 = 0.5;
            fraction2 = 0.5;
        case 2
            fraction1 = varargin{1};
            fraction2 = varargin{1};
        case 3
            fraction1 = varargin{1};
            fraction2 = varargin{2};
    end
end

C = merge(A, B, fraction1, fraction2);

end