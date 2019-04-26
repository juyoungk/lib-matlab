function plot_bg(g)

    % Normalized the bg trace
    i_contrast = 2;
    bg = scaled(g.bg_trace(:,i_contrast)); % trace for evennt detection.
    
    % Normalized plot
    figure;
    plot(g.f_times, bg); hold on
    title('Background pixel avg trace.');
    
    % pd event lines
    g.plot_pd_events2_lines; % pd_events2 (minor) plot
    
    hold off
end