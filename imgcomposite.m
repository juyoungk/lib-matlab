function C = imgmerge(a, ch_a, b, ch_b, varargin)
% merge 2 images (x by y by channels) into composite image

A = comp(a, ch_a);
B = comp(b, ch_b);

RA = imref2d(size(A));
RB = imref2d(size(B));

RB.XWorldLimits = RA.XWorldLimits;
RB.YWorldLimits = RA.YWorldLimits;

[C,RC] = imfuse(A,RA,B,RB,'ColorChannels',[2 1 0]);
[C,RC] = imfuse(scaled(A),RA,scaled(B),RB,'ColorChannels',[2 1 0]);

figure; imshow(C);

end