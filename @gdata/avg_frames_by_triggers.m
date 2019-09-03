function vol_averaged = avg_frames_by_triggers(g, triggers, duration)
% Smooth, and then, averaged the frames in response to given trigger times
%
% triggers - regular or irregular series of trigger times
% duration - duration of frames for averaging

if nargin < 3
    duration = triggers(2) - triggers(1);
    disp('The time gap between the first two triggers were assumed to be the duration for the averaged movie.');
end

numTriggers = length(triggers);
if numTriggers < 2
    error('Too few triggers (<2) were given.');
end

% smooth if the smoothing was not performed.
if isempty(g.vol_smoothed)
    g.smoothVolOverTime;
else
    disp('No new smoothing. g.vol_smoothed was used.');
end

% Trigger times as frame ids
ids = zeros(1, numTriggers); 
for i=1:numTriggers
    ids(i) = find(g.f_times>=triggers(i), 1);
end

% Average over triggered duration (repeats)
numframes = round(duration / g.ifi);
vol_averaged = zeros(g.header.pixelsPerLine, g.header.linesPerFrame, numframes);
for i=1:numTriggers
   frames = ids(i):ids(i)+numframes-1;
   if frames(end) <= g.nframes
       vol_averaged = vol_averaged + g.vol_smoothed(:,:,frames);
   end
end
g.avg_vol = vol_averaged;

% Normalize vol_average.

% Max & Min projection of the averaged
max_projected = max(vol_averaged, [], 3);
min_projected = min(vol_averaged, [], 3);
% normalize for making images have positive values.
%max_projected = mat2gray(max_projected);
%min_projected = mat2gray(min_projected);

% Opening filter setting
disk_min_opening = 1;
se_min_opening = strel('disk', disk_min_opening);

% Opened image for min projection (for smoothed difference image)
% Also, it usually doens't catch the dendrite. Thus, it emphasizes the
% dendritic structure if data is substracted by this. 
min_projected_opened = imopen(min_projected, se_min_opening);

% Averaged volume
session_id = find(g.pd_events1 == triggers(1), 1);
if ~isempty(session_id)
    s_title = sprintf('%s - avg %d repeats (session %d: trigger started at %.0f sec)', g.ex_name, numTriggers, session_id, triggers(1));
else
    s_title = sprintf('%s - avg %d repeats (trigger started at %.0f sec)', g.ex_name, numTriggers, triggers(1));
end
imvol(vol_averaged, 'title', s_title, 'globalContrast', true, 't_step', g.ifi);
imvol(vol_averaged - min_projected, 'title', [s_title, ' diff'], 'globalContrast', true, 't_step', g.ifi);
imvol(vol_averaged - min_projected_opened, 'title', [s_title, ' diff by min projection: disk size ', num2str(disk_min_opening)], 'globalContrast', true, 't_step', g.ifi);

% Opening filter setting 
disk_size = 9;
se = strel('disk', disk_size);

% saturated max projection iamge for bg image
c_percentage = 0.2;
Tol = [0 1-c_percentage*0.01]; % saturate only biright pixels. 
I = mat2gray(max_projected);
MinMax = stretchlim(I, Tol);
J = imadjust(I, MinMax);

% BG image for max projection
bg_open = imopen(J, se);

% BG substracted max-projected image
%max_projected_bg_substracted = mat2gray(max_projected) - bg_open;
% 
% J = cat(3, J, imtophat(J, se));
% J = cat(3, J, bg_open);
% imvol(J);

% diff image
diff_image = mat2gray(max_projected - min_projected);
MinMax = stretchlim(diff_image, Tol);
J_diff = imadjust(diff_image, MinMax);

% BG image with minimum saturation
scaling = 0.1;
penality = scaling * 1./bg_open - scaling;
bg_penalized = bg_open + penality;

% image stacks
stack = cat(3, max_projected, imtophat(J, se)); % J is a saturated max-projected image
%stack = cat(3, stack, min_projected);
%stack = cat(3, stack, min_projected_opened);
stack = cat(3, stack, diff_image);
stack = cat(3, stack, imtophat(J_diff, se));
stack = cat(3, stack, diff_image./bg_penalized);
stack = cat(3, stack, bg_open);

time_snap = (triggers(1) + triggers(end) + duration)/2.;
imvol(stack, 'title', ['1. Max projected.  2. w/ bg substracted.  3. diff_image  4. w/ bg substracted  5. norm.  6. bg image (disk size -',num2str(disk_size),')'], 'timestamp', time_snap*ones(1, size(stack, 3)));




end