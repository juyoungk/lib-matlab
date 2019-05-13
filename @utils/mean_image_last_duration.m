function [image, time] = mean_image_last_duration(vol, f_times, duration)
% Intput :
%       vol           - raw image stack
%       f_times       - frame times for vol data
%       duration      - duration for mean image.  
%
% Output :
%       image
%       time
    
    if ndims(vol) ~= 3
        error('vol(image stack) is not 3D tensor.');
    end
            
    t_event = f_times(end) - duration;
    i_frame = find(f_times >= t_event, 1);

    % Last snap - last numAvgFrames
    image = mean(vol(:,:,(i_frame:end)), 3);
    time  = f_times(end) - duration/2.;

end