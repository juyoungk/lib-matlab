function myraster(spikes, H_lineevery)
    
    if nargin < 2 
        n_seq = 4;
        n_repeat = 4;
        n_speed = 10;
        H_lineevery = n_seq * n_repeat* n_speed;
    end
 
    numLines = numel(spikes);

    %
    LineFormat = struct();
    LineFormat.Color = [0.1 0.1 0.1];
    LineFormat.LineWidth = 3.0;
    LineFormat.LineStyle = '-';

    % scatter plot
    MarkerFormat.MarkerSize = 10;
    MarkerFormat.Color = [0.1 0.1 0.1];
    MarkerFormat.LineStyle = 'none';

    %figure;
    cla(gca, 'reset');
    plotSpikeRaster(spikes, 'PlotType', 'vertline','LineFormat',LineFormat);
    %plotSpikeRaster(spikes, 'PlotType', 'scatter', 'MarkerFormat', MarkerFormat);

    %
    ax = gca;
    %ax.XGrid = 'on';  
    ax.XMinorGrid = 'on';
    set(gcf, 'position', [100, 550, 1510, 720]);

    % vertical lines for sessions
    num_frames = 75;
    ifi = 0.03529477/3;
    num_sessions = 8;
    t_session = 0:num_sessions;
    t_session = t_session * num_frames * ifi;
    transition = [1 3 5 7];
    transition = transition * num_frames * ifi;

    hold on;
    for i = 1:length(t_session)
    plot([t_session(i) t_session(i)], [0, numLines], 'r');
    end
    for i = 1:length(transition)
    plot([transition(i) transition(i)], [0, numLines], 'b');
    end
    % Horizontal lines
    h_lines = 1:H_lineevery:numLines;
    for i = h_lines
      plot([0 t_session(end)], [i i], 'g');
    end
    %
    hold(ax, 'off');
    
    % xlim
    nonempty_id = ~cellfun(@isempty, spikes);
    spikes_nonempty = spikes(nonempty_id);
    max_array = cellfun(@max, spikes_nonempty);
    max_ts = max(max_array);
    x_end = min(max_ts, t_session(end));
    xlim([0 x_end]);

end