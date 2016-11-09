function myraster(spikes, H_line_every, V_lines)
    
    if nargin <3
        n_session = 16;
        numframes = 120;
        ifi = 0.03529477/3;
        s_duration = numframes * ifi;
        V_lines = (0:n_session) * s_duration;
    end

    if nargin < 2 
        n_seq = 4;
        n_repeat = 4;
        n_speed = 10;
        H_line_every = n_seq * n_repeat* n_speed;
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

    hold on;
    % Vertical lines
    for i = 1:length(V_lines)
        plot([V_lines(i), V_lines(i)], [0, numLines], 'r');
    end
    
    % Horizontal lines
    h_lines = 1:H_line_every:numLines;
    for i = h_lines
      plot([0 V_lines(end)], [i i], 'g');
    end
    %
    hold(ax, 'off');
    
    % xlim
    nonempty_id = ~cellfun(@isempty, spikes);
    spikes_nonempty = spikes(nonempty_id);
    max_array = cellfun(@max, spikes_nonempty);
    max_ts = max(max_array);
    x_end = min(max_ts, V_lines(end));
    xlim([0 x_end]);

end