% image A and B

% A =
% B =

%% 
Ac = myshow(A, 0.8);
Bc = myshow(B, 0.8);

%%
registrationEstimator;

%%
[Bc_transformed, RB] = imwarp(Bc, movingReg.SpatialRefObj, movingReg.Transformation);

%%
[D, RD] = imfuse(Ac, imref2d(size(Ac)), Bc_transformed, RB, 'ColorChannel', [2, 1, 2]);

imshow(D);


%% composite between two images
