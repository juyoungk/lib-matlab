%% merging multiple cc (for continuous ROIs)

cc_cells = {cc7, cc17, cc68};
%% Image each rois
bw_stack = [];

for i=1:numel(cc_cells)

    [~, bw] = conn_to_bwmask(cc_cells{i});
    bw_stack = cat(3, bw_stack, bw);
   
end

imvol(bw_stack);

%% Combine rois

%cc_cells = {cc_f38, cc_f70};

%CC must contain the following fields: Connectivity, ImageSize, NumObjects, and PixelIdxList.
cc_tot = cc_cells{1};
cc_tot.PixelIdxList = [];
cc_tot.NumObjects = 0;

for i=1:numel(cc_cells)
    cc_tot.NumObjects = cc_tot.NumObjects + cc_cells{i}.NumObjects;
    cc_tot.PixelIdxList = [cc_tot.PixelIdxList, cc_cells{i}.PixelIdxList];
end
