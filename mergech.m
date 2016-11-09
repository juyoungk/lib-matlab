function C = merge2ch(a, ch1, ch2, varargin)
%
% merge2ch(a, ch1, ch2)
% merge2ch(a, ch1, ch2, fraction)
% merge2ch(a, ch1, ch2, fraction1, fraction1)
%

%
% merge 2 images [row col ch] into composite image
%
fraction = 0.5;

switch ndims(a)
    case 2
        a = a;
        disp('fn: mergech: A is just 2-D image. ch_a was ignored.');
    case 3
        a = comp(a, ch1);
    otherwise
        disp('wrong input to function imgmerge');
end

nVarargs = length(varargin);

switch ndims(ch2)
    case 1
        B = comp(a, ch2);
        if nVarargs>=1
            fraction = varargin{1};
        end 
    case 2
        B = ch2;
        if nVarargs>=1
            fraction = varargin{1};
        end 
    case 3
        if nVararg==1
            B = comp(ch2, varargin{1});
        end
        if nVarargs>=2
            fraction = varargin{2};
        end
    otherwise
        disp('wrong input to function imgmerge');
end


merge(a,B,fraction);

end