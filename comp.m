function Xcomp = comp(X, range)
% Pick a specific range of frames or components of X
% , which is the last dim of matrix X (usually dim.3 for 2-D images)
% 
% if Dim ==2
%     Xcomp = X(:,range);
% elseif Dim ==3
%     Xcomp = X(:,:,range);
% elseif Dim == 4
%     Xcomp = X(:,:,:,range);
% elseif Dim == 5
%     Xcomp = X(:,:,:,:,range);
%

Dim = ndims(X);
d = size(X);

if max(range)>d(end) || min(range)<1
    disp('Function comp: components (frames) are out of range');
    Xcomp = [];
    return;
end

if Dim ==2 % 2-D matrix
    Xcomp = X(:,range);
elseif Dim ==3
    Xcomp = X(:,:,range);
elseif Dim == 4
    Xcomp = X(:,:,:,range);
elseif Dim == 5
    Xcomp = X(:,:,:,:,range);
else
    Xre = reshape(img,[],size(img,ndims(img)));
    Xcomp = Xre(:,range);
    disp('Dim of matrix X @ comp function is more than 5. X was reshaped into 1-D.');
end

end
