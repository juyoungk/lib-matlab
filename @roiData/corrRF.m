function rf = corrRF(r, i_roi, stim, fliptimes)

    maxlag = 1.0; %sec
    upsampling = 1;

    if nargin > 1

        y = r.roi_smoothed(:, i_roi);
        % data certering

        if nargin < 3
            rf = corrRF3(y, r.f_times, r.stim_whitenoise, r.stim_times, upsampling, maxlag);
        else
            %rf = corrRF3(rdata, rtime, stim, fliptimes, upsampling, maxlag, varargin)
            rf = corrRF3(y, r.f_times, stim, fliptimes, upsampling, maxlag);
        end
        rf = squeeze(rf);
        %imshow(scaled(rf));
    
    else
        % compute rf for all rois

    end

end 