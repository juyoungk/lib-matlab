function printScimHeader(header)

zoom = header.acq.zoomFactor;
FOV = FOV_scim(zoom);
linesPerFrame = header.acq.linesPerFrame;
pixelsPerLine = header.acq.pixelsPerLine;
V_PixelRes = FOV/linesPerFrame;
H_PixelRes = FOV/pixelsPerLine;

% Print acq properties
disp(['Zoom factor = ', num2str(zoom), '   (FOV = ', num2str(round(FOV_scim(zoom))), ' um)']);
disp(['Lines/frame = ', num2str(linesPerFrame), ' (1 Pixel (Verti)= ',num2str(V_PixelRes),' um)']);
disp(['Pixels/line = ', num2str(pixelsPerLine), ' (1 Pixel (Horiz)= ',num2str(H_PixelRes),' um)']);
disp(['  msPerLine = ', num2str(header.acq.msPerLine)]);
disp(['  pixelTime = ', num2str((header.acq.pixelTime)*1000), ' ms']);


end