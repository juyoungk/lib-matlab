function cc = get_cc_from_avg_vol_frames(g, num_times)
% get cc (roi structure) from multiple snap shots of avgeraged volume.

%
if isempty(g.avg_vol)
    disp('Averaged volume shold be computed...');
    g.avg_frames_by_triggers;
end

if nargin < 2
    num_times = 10;
end

[row, col, frames] = size(g.avg_vol); 

% number of frames for one snap shot
numframes = round(g.avg_duration / g.ifi / num_times);

snaps = zeros(

for i=1:num_times
    fs = 1 + (i-1)*numframes;
    fe = fs + numframes - 1;
    fe = min(fe, frames);
    snap = max(g.avg_vol(:,:,fs:fe), [], 3);
end



end