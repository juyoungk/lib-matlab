function roi_array = conn_to_bwmask(cc)
% convert cc to bwmask

roi_array = false([cc.ImageSize, cc.NumObjects]);

for i = 1:cc.NumObjects
    grain = false(cc.ImageSize);
    grain(cc.PixelIdxList{i}) = true;
    roi_array(:,:,i) = grain;
end

end