%% What is the right level of filtering? 
%% 
id = 57;
r.plot_rf(id);

%% Power spectrum of raw trace

ids = [9, 10, 14, 20, 21];
%ids = [9, 10];
    
for id = ids
    
    r.plot_fft(id);
    
    hold on
    
end

hold off

%% Trace comparisons as varying filter frequencies
id = 57;

r.w_filter_low_pass = 0.4;
r.w_filter_low_stop = 0.6;

x_raw = r.roi_trace(:,id);
x_raw = x_raw(r.f_times > r.ignore_sec);

x_filtered = r.roi_filtered(:, id);
x_smoothed = r.roi_smoothed(:, id); x_smoothed = x_smoothed(r.f_times > r.ignore_sec);

power_max = 250;
Fontsize = 18;

subplot(3, 1, 1)
    
    plot_fft(x_raw);
    title('Raw trace spectrum', 'FontSize', Fontsize);
    ylim([0 power_max])

subplot(3, 1, 2)

    
    plot_fft(x_filtered); hold on
    %plot_fft(x_smoothed); hold on
    ylim([0 power_max])
    
    hold off

subplot(3, 1, 3)
% trace compare
    
    
    linewidth = 1.5;

    plot(r.f_times_fil, x_raw, 'Color', [0.7 0.7 0.7], 'LineWidth', 1.2*linewidth); hold on
    plot(r.f_times_fil, x_smoothed,     'LineWidth', linewidth);
    plot(r.f_times_fil, x_filtered,     'LineWidth', linewidth);

    xlim([100 120])
    
    xlabel('sec');
    ylabel('PMT output');
    ax = gca;
    
    ax.XAxis.FontSize = Fontsize;
    ax.YAxis.FontSize = Fontsize;

    hold off

%% Real frequency axis?
r.plot_fft(id);

%% histogram of filtered trace