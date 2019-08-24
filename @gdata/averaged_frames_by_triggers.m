function vol_averaged = averaged_frames_by_triggers(g, triggers)
% Smooth, and then, averaged the frames in response to given trigger times
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

% Duration
numframes = ids(2)-ids(1);
disp('The time gap between the first two events were assumed to be the duration for the averaged movie.');

% Average
vol_averaged = zeros(g.header.pixelsPerLine, g.header.linesPerFrame, numframes);
for i=1:numTriggers
   frames = ids(i):ids(i)+numframes-1;
   vol_averaged = vol_averaged + g.vol_smoothed(:,:,frames);
end

% Averaged volume
imvol(vol_averaged, 'globalContrast', true);

% Max projection
imvol(max(vol_averaged, [], 3), 'title', 'max projection of averaged video');

end