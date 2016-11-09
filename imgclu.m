function img = imgclu(idx, xdim, ydim)
% Form 2-D color-coded image according to its clustered index.
% idx : indexed array (1-D)
% xdim & ydim = pixel numbers for each dimension.

maxidx = max(idx);
minidx = min(idx);
disp(['max idx = ',num2str(maxidx)]);
disp(['min idx = ',num2str(minidx)]);
color = jet(maxidx);

im = reshape(idx, xdim, ydim);

figure('position', [850, 685, 560, 420]);
imagesc(im, [min(idx) max(idx)]); axis off;
%imagesc(im, [min(idx) max(idx)]); axis off;
colormap(color);

end
