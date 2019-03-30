function plot_bg_pixels(g, ch, timeafter)
% background noise anlysis
% update bg_trace
% detect bg_event (from contrast level xx)
% plot after normalization with stim ev lines.

    if nargin < 3
        timeafter = 0;
    end

    if nargin < 2
        ch = g.roi_channel;
    end
    
    % reshaped vol
    vol_reshaped = reshape(g.AI{ch}, [], g.nframes);
    
    contrast = [0.5 1.0 2.0 4.0];
    g.bg_trace = zeros(g.nframes, length(contrast));
    
    snap1 = g.AI_snaps{ch}(:,:,1);
    snap2 = g.AI_snaps{ch}(:,:,2);
    
    for i = 1:length(contrast) % contrast values (%)
        c = contrast(i);
        bw1 = lowerpixels(snap1, c);
        bw2 = lowerpixels(snap2, c);
        bw = bw1 & bw2;
        g.bg_trace(:,i) = mean(vol_reshaped(bw,:), 1);
    end
    
    %figure; 
    %plot(g.f_times, g.bg_trace);
    
    % norm
    i_contrast = 2;
    bg = scaled(g.bg_trace(:,i_contrast)); % trace for evennt detection.
    
    % events only after the given timeafter
    i_timeafter = find(g.f_times > timeafter);
    i_timeafter = i_timeafter(1);
    
    % detect crosstalk events
    threshold = 0.45;
    ev_idx = th_crossing(bg(i_timeafter:end), threshold, g.min_interval_secs / g.ifi);
    g.bg_event_id = ev_idx + i_timeafter;
    ev = g.f_times(g.bg_event_id);
    g.bg_event = ev;
    fprintf('Background (cross-talk) events were identified with contrast level %.1f, threshold %.2f, timeafter = timeafter.\n',...
                                contrast(i_contrast), threshold, timeafter);
    
    % normalized plot
    figure;
    plot(g.f_times, bg); hold on
    plot(ev, threshold, 'o');
    xlim([timeafter, g.f_times(end)]);
    
    % pd event lines
    g.plot_pd_lines; % pd_events2 (minor) plot
    
    hold off

end

function bw = lowerpixels(I, c) % 2D matrix, percentage. Output is logical array.
    if nargin < 2
        c = 0.5;
    end
    [J, ~] = myadjust(I, c); % J is the clipped-image by the given contrast (%).
    bw = (J ==0);            % Pixel value is 0 if value was in the lowest value group clipped by the contrast. 
end

function [J, MinMax] = myadjust(I, c)
% Contrast-enhanced mapping to [0 1] of matrix I
% Input: contrast value (%)
    I = mat2gray(I); % Normalize to [0 1]. 
    Tol = [c*0.01 1-c*0.01];
    MinMax = stretchlim(I,Tol);
    J = imadjust(I, MinMax);
end