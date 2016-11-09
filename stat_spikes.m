function firing_rate = stat_spikes(t_stamps, range_Secs, bintime_ms, pd, varargin)
    % spiking rate & inter-spike statistics
    % t_stamps: spikes time stamps. ASSUMPTION: 10K sampling rate.
    % pd : second timed data. usually photodiode siganl. 
    
    sampling_rate = 10000
    sampling_period = 1./sampling_rate;
    
    if nargin < 4
        pd = [];
    end 
    if nargin < 3
        bintime_ms = 0.5 % ms
    end
    if nargin <2
        range_Secs = [0, 10] %s
    end
    if isscalar(range_Secs)
        if range_Secs <= 0
            range_Secs = 10 %default time
        end
        range_Secs = [0, range_Secs] %s
    end
        
    % firing rate
    smoothing = false;
    rate = ts_rate(t_stamps/sampling_rate, range_Secs, 0.001*bintime_ms, smoothing);
    %   
    X_Tick = range_Secs(1):(range_Secs(2)-range_Secs(1))/20:range_Secs(2);
    figure('position', [5, 680, 1900, 420]);
    subplot(2,1,1);
    
    yyaxis left
    plot(X_time(1:end-1), rate(1:end-1), 'LineWidth', 2); hold on; pan xon; %ylim([0,1]);
    %
    ax = gca;  ax.LineWidth = 2.2;
    ax.XTick = X_Tick; %ax.XMinorTick = 'on';
    ax.XGrid = 'on';  ax.XMinorGrid = 'on';
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
        % range setting
        t_pd_end = length(pd)*sampling_period; % end time of the pd data (in secs)
        pd_timestamps = sampling_period:sampling_period:t_pd_end;
        [pd_range, t_stamps_range] = rangeSample(pd, pd_timestamps, range_Secs(1), range_Secs(2));
        plot(t_stamps_range, pd_range, 'LineWidth', 1.5); ylabel('pd'); ylim auto;
        
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
    
    %set(h, 'FontSize', 30) 
    %set(h,'FontWeight','bold')
    firing_rate = rate;
end