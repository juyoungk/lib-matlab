%% merging multiple cc (for continuous ROIs)
% cc_cells % output of g.get_cc_from_avg_vol_frames;
ids = [10:13, 16]; 
ids = [1,10,11];
cc_selected = cc_cells(ids);

%% Image each rois
bw_stack = [];

for i=ids

    [~, bw] = conn_to_bwmask(cc_cells{i});
    bw_stack = cat(3, bw_stack, bw);
   
end

imvol(bw_stack);
imvol(max(bw_stack, [], 3), 'title', 'Merged bw image');

%% Combine rois

%cc_cells = {cc_f38, cc_f70};

%CC must contain the following fields: Connectivity, ImageSize, NumObjects, and PixelIdxList.
cc_tot = cc_selected{1};
cc_tot.PixelIdxList = [];
cc_tot.NumObjects = 0;

for i=ids
    cc_tot.NumObjects = cc_tot.NumObjects + cc_cells{i}.NumObjects;
    cc_tot.PixelIdxList = [cc_tot.PixelIdxList, cc_cells{i}.PixelIdxList];
end
