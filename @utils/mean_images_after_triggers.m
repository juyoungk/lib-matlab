function [snaps, times] = mean_images_after_triggers(vol, f_times, trigger_times, duration)
% Intput :
%       vol           - raw image stack
%       f_times       - frame times for vol data
%       trigger_times - times after which you want to compute avg snap images over numAvgFrames
%
% Output :
%       snaps - n images as 3D tensor
%       times - n timestamps for the snaps.
    
    if ndims(vol) ~= 3
        error('vol(image stack) is not 3D tensor.');
    end

    [rows, cols, ~] = size(vol);
    numTriggers = length(trigger_times);
    
    %
    numSnaps = numTriggers; % + last snap
    snaps = zeros(rows, cols, numSnaps); 
    times = zeros(1, numSnaps);
    
    %
    for i = 1:numTriggers
        
        t_event = trigger_times(i);
        i_frame = find(f_times >= t_event, 1);
        e_frame = find(f_times > t_event+duration, 1);
        
        if isempty(e_frame)
            fprintf('mean snap images : %d trigger + duration goes beyond the recorded time. Break.\n', i);
            snaps = snaps(:,:,1:i-1);
            times = times(:,1:i-1);
            break;
        end
        
        % estimate ifi and time interval between i_frame and e_frame
        ifi = f_times(i_frame+1) - f_times(i_frame);
        time_for_avg = (e_frame - i_frame) * ifi;
        
        % duration for each snap
        % n = min(numAvgFrames, nframes-i_frame); % 20 Hz save --> 50s
        % duration = r.ifi * n;
        
        %
        snaps(:,:,i) = mean(vol(:,:,i_frame:e_frame-1), 3);
        times(i) = t_event + time_for_avg/2.;
    end
    
    % Last snap - last numAvgFrames
%     snaps(:,:,end) = mean(vol(:,:,(end-n+1:end)), 3);
%     times(end) = f_times(end) - duration/2.;

end