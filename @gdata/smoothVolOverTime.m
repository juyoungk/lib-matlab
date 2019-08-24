function smoothVolOverTime(g, smooth_size, ch)
% smooth and store the result at vol_smoothed. 

if nargin < 3
    ch = g.roi_channel;
end

if nargin < 2
    %smooth_size = g.vol_smooth_size;
    smooth_size = 9;
end

fprintf('Smoothing channel %d raw imaging data... (smooth size is %d)\n', ch, smooth_size);

g.vol_smoothed = smooth3(g.AI{ch}, 'box', [1 1 smooth_size]);

end