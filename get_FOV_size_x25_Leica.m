function fov = get_FOV_size_x25_Leica(zoom)
% Field-Of-View of x25 Leica lens in upright scope in Baccus lab running SI 5. 
% [um]
    
    if nargin < 1
        zoom = 0;
    end
    
    % data
    scanZoom =  [1,       2,        3,        4,        5,        6,        7];
    um_per_px = [150/114, 150/227., 150/339., 150/452., 120/453., 90/408., 60/317.];
    fovSize  = 512 * um_per_px;
    
    % interporlate
    if zoom > 0 
        fov = interp1(scanZoom, fovSize, zoom, 'spline'); 
    else
        fov = 0;
    end
    
end
