  close all
  %
  LineFormat = struct();
  LineFormat.Color = [0.1 0.1 0.1];
  LineFormat.LineWidth = 2.0;
  LineFormat.LineStyle = '-';
 
  % scatter plot
  MarkerFormat.MarkerSize = 10;
  MarkerFormat.Color = [0.1 0.1 0.1];
  MarkerFormat.LineStyle = 'none';
 
  %
  n_seq = 5;
  n_repeat = 4;
  H_lineevery = n_seq * n_repeat;
  %
  numLines = 200;
  spikes = spikes9(1:numLines);
  
  plotSpikeRaster(spikes, 'PlotType', 'vertline','LineFormat',LineFormat);
  %plotSpikeRaster(spikes, 'PlotType', 'scatter', 'MarkerFormat', MarkerFormat);

  %
  xlim([0 4.5]);
  ax = gca;
  %ax.XGrid = 'on';  
  ax.XMinorGrid = 'on';
  set(gcf, 'position', [510, 380, 1510, 720]);
  
  % vertical lines for sessions
  num_frames = 42;
  ifi = 0.03529477/3;
  num_sessions = 9;
  t_session = [0 2:num_sessions];
  t_session = t_session * num_frames * ifi;
  transition = [2 4 6 8];
  transition = transition * num_frames * ifi;
  hold on;
  for i = 1:length(t_session)
    plot([t_session(i) t_session(i)], [0, numLines], 'r');
  end
  for i = 1:length(transition)
    plot([transition(i) transition(i)], [0, numLines], 'b');
  end
  % Horizontal lines
  h_lines = 0.5:H_lineevery:numLines;
  for i = h_lines
      plot([0 t_session(end)], [i i], 'g');
  end
  %
  hold off