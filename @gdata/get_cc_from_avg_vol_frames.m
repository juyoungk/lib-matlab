function cc_cells = get_cc_from_avg_vol_frames(g, num_times)
% get cc (roi structure) from multiple snap shots of avgeraged volume.
% get rois from local max pattern and combine.
% Conditions for detecting IPL patches - High black saturation, zero sensitiviry, low connectivity threshold

%
if isempty(g.avg_vol)
    disp('Averaged volume shold be computed...');
    g.avg_frames_by_triggers;
end

if nargin < 2
    num_times = 20;
end

[row, col, frames] = size(g.avg_vol); 

% Saturation level.
% Small grain? increase black saturation level.
Tol = [0.8, 1]; 

%
se_bg = strel('disk',11);

% number of frames for one snap shot
numframes = round(g.avg_duration / g.ifi / num_times);

% diff volume
vol = g.avg_vol - min(g.avg_vol, [], 3);

% merged objects
snaps = [];
snaps_d = [];
bw_stack = [];
cc_cells = {};

for i=1:num_times
    
    fs = 1 + (i-1)*numframes;
    fe = fs + numframes - 1;
    fe = min(fe, frames);
    I = mean(vol(:,:,fs:fe), 3);
     
    % difference between times
    if i > 1    
        d = snaps(:,:,i-1) - I;
        d = abs(d);
        % spatial bg substraction
        d = imtophat(d, se_bg);
        % contrast adjust
        d = mat2gray(d);
        MinMax = stretchlim(d, Tol);
        d = imadjust(d, MinMax);
        snaps_d = cat(3, snaps_d, d);
    end

    % spatial bg substraction
    I = imtophat(I, se_bg);
    
    % contrast adjust (high black saturation)
    I = mat2gray(I);
    MinMax = stretchlim(I, Tol);
    J = imadjust(I, MinMax);
    
    snaps = cat(3, snaps, J);
    
    % binary image to connected components
    sensitivity = 0.;
    P_connected = 11;
    
    bw = imbinarize(J, 'adaptive', 'Sensitivity', sensitivity);
%     if i>1
%         bw = imbinarize(d, 'adaptive', 'Sensitivity', sensitivity);
%     end
    disp('Mean projection was used for biniarized images.');
    bw = bwareaopen(bw, P_connected); % remove small area
    
    % flattened outline? dialate, then opening
%     se = strel('disk', 2);
%     bw = imdilate(bw, se);
%     bw = imopen(bw, strel('disk', 5));
%     
    % bw to connected components
    cc = bwconncomp(bw, 8);
    
    % merge bw
    bw_stack = cat(3, bw_stack, bw);
    
    % merge cc
    cc_cells = [cc_cells, {cc}];
        
%     if isempty(cc_cells)
%         cc_cells = cc;
%     else
%         cc_cells.PixelIdxList = [cc_cells.PixelIdxList, cc.PixelIdxList];
%         cc_cells.NumObjects = cc_cells.NumObjects + cc.NumObjects;
%     end
        
end

imvol(snaps);
imvol(snaps_d);

imvol(max(snaps, [], 3), 'title', 'snaps max projection');
imvol(max(snaps_d, [], 3), 'title', 'd-snaps max projection');

imvol(bw_stack);

disp('Combining of cc: see the function ''analysis_merging_multiple_cc_rois.m''');

end