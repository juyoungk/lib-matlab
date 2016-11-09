function C = merge(A, B, varargin)
%
% merge(A, B)
% merge(A, B, f)        % Adjust contrast with a fraction of outlier f
% merge(A, B, f1, f2)
% Current Color setting: [2 1 0]: A is green, B is red
%
% %% 'merge' will do scaling. Input for 'imadjust' must be scaled.

if ~ismatrix(A)
    disp('fn: merge: A is not (image) matrix.');
    return
end

if ~ismatrix(B)
    disp('fn: merge: B is not (image) matrix.');
    return
end

% percentage for saturation level for top and low pixels.
nVarargs = length(varargin);
if nVarargs == 1
    fraction1 = varargin{1};
    fraction2 = varargin{1}; 
elseif nVarargs >= 2
    fraction1 = varargin{1};
    fraction2 = varargin{2}; 
else
    fraction1 = 0.5; % percentage for saturation level for top and low pixels.
    fraction2 = 0.5; % percentage for saturation level for top and low pixels.
end
Tol1 = [fraction1*0.01 1-fraction1*0.01];
Tol2 = [fraction2*0.01 1-fraction2*0.01];
% disp(['Contrast adjustment for   ',num2str(Tol),' (outliers is ',num2str(fraction),'%)']);

A = scaled(A);
B = scaled(B);

AJ = imadjust(A,stretchlim(A,Tol1));
BJ = imadjust(B,stretchlim(B,Tol2));

RA = imref2d(size(A));
RB = imref2d(size(B));

RB.XWorldLimits = RA.XWorldLimits;
RB.YWorldLimits = RA.YWorldLimits;

[C,RC] = imfuse(AJ,RA,BJ,RB,'ColorChannels',[2 1 0]);

%imshow(C); 
%title([inputname(1), ' + ', inputname(2)]);

end