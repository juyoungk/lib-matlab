function rate_hist = spikes_hist(t_stamps, pd, time_edges, varargin)
    %    
    % spiking rate & inter-spike statistics
    % t_stamps: spikes time stamps. ASSUMPTION: 10K sampling rate.
    % time_edges: provides the start, end, and the time duration of each
    % experiment

    % pd : another timed data. usually photodiode siganl. 
    
    % ASSUMPTION about the time stamps of spikes
    sampling_rate = 10000
    sampling_period = 1./sampling_rate;
    t_stamps = t_stamps/sampling_rate;
    
    % default bin time
    bintime_ms = 0.5; % ms
    
    if nargin < 3
        time_edges = 0:9.96:1020 - 0.005;
    end
    if nargin < 2
        pd = [];
    end
    
    % 1. histogram of spikes over given timeedges (one experimental
    % condition)
    rate_hist = histc(t_stamps, time_edges);
    
    % 2. rate of spikes (default bin = 0.5 ms) & location of time edges
    X_time = time_edges(1):(bintime_ms*0.001):time_edges(end);
    X_Tick = time_edges(1):10:time_edges(end);
    r_spikes = histc(t_stamps, X_time);
    r_edges = histc(time_edges, X_time);
    
    %
    figure('position', [5, 680, 1900, 420]);
    subplot(2,1,1);
    
    yyaxis left
    plot(X_time(1:end-1), r_spikes(1:end-1), 'LineWidth', 2); hold on; pan xon;
    plot(X_time(1:end-1), r_edges(1:end-1), 'LineWidth', 2); hold on; pan xon;
    %
    ax = gca;
    ax.XGrid = 'on';  ax.LineWidth = 2.2; ax.XTick = X_Tick; 
    ax.XMinorGrid = 'on';
    ax.YGrid = 'on';
    set(gca,'FontSize',16);
    %
    %str = ['bin size = ', num2str(bintime_ms),' ms']; dim = [.85 .75 .3 .24]; %[x y w h]
    %annotation('textbox',dim,'String',str,'FitBoxToText','on');
    xlabel('Time [s]', 'FontSize', 17); % 
    %ylabel(['Spikes over bin', '[',num2str(bintime_ms),' ms]'], 'FontSize', 17); % 
    text = ['[bin = ',num2str(bintime_ms),' ms]'];
    ylabel({'Spikes'; text}, 'FontSize', 17); % 
    
    % photodiode (pd) plot
    if ~isempty(pd)
        % smoothing
        pd = double(pd);
        pd = smooth(pd, 7, 'moving');
        if iscolumn(pd)
            pd = pd';
        end
        
        yyaxis right
        % pd signal
        t_pd_end = length(pd)*sampling_period;  % end time of the pd data (in secs)
        pd_timestamps = sampling_period:sampling_period:t_pd_end;
        [pd_range, t_stamps_range] = rangeSample(pd, pd_timestamps, time_edges(1), time_edges(end));
        plot(t_stamps_range, pd_range, 'LineWidth', 0.1); ylabel('pd'); ylim auto;

        % graph setting
        ax = gca;
        ax.XGrid = 'on'; ax.XTick = X_Tick; ax.LineWidth = 2.2; ax.YTick = []; 
        ax.XMinorGrid = 'on';
    end  
    hold off
    % 

    % interspike interval
    s_interval = t_stamps(2:end)-t_stamps(1:end-1);
    
    X_interval = (0:0.5:1200)*0.001; % x axis of interval: 0.5-ms resolution
    h_interval = histc(s_interval, X_interval);
    %subplot(3,1,2); plot(X_interval*1000, h_interval, 'LineWidth', 2); xlim([0 20]); set(gca,'FontSize',16);
    subplot(2,1,2); semilogx(X_interval*1000, h_interval, 'LineWidth', 2); 
    xlim([0.5 inf]); ylim([0.5 inf]); ax = gca; ax.XTick = [0,1,2,3,5,10,20,50,100,200,1000]; 
    set(gca,'FontSize',16);
    %subplot(3,1,3); plot(X_interval*1000, h_interval, 'LineWidth', 2); xlim([-inf inf]);% x unit: ms
    %
    set(gca,'FontSize',16);
    axis([-inf,inf,-3,50])
    xlabel('Interspike interval [ms]', 'FontSize', 20) % x-axis label
    ylabel('Occurrence', 'FontSize', 20) % y-axis label

end