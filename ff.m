function ff(line_Linewidth)
% Figure font control

color = [1 1 1];
color = [0 0 0]; % black
disp('Current color is black');

Fontsize = 24;
axis_Linewidth = 1.2;
if nargin < 1
    line_Linewidth = 1.2;
end

hfig = get(groot,'CurrentFigure');

% axes
hd = findall(hfig, 'type', 'axes');
for i = 1:numel(hd)
    ax = hd(i);
    %
    ax.XAxis.FontSize = Fontsize;
    ax.YAxis.FontSize = Fontsize;
    ax.XAxis.Color = color;
    ax.YAxis.Color = color;
    
    ax.XLabel.Color = color;
    ax.YLabel.Color = color;
    
    % Grid
    ax.GridColor = [0.1, 0.1, 0.1];
    
    % Z-axis
    ax.ZAxis.FontSize = Fontsize;
    ax.ZAxis.Color = color;
    ax.ZLabel.Color = color;
    ax.ZAxis.LineWidth = axis_Linewidth;
    
    % Title
    text = ax.Title.String;
    % text can be cell array. text{1} might be needed.
    % disp(['(text of Title?) ', text{1}]);
    title(ax, text, 'Color', color, 'FontSize', Fontsize);

    ax.XAxis.LineWidth = axis_Linewidth;
    ax.YAxis.LineWidth = axis_Linewidth;
end

% Line
hd = findall(hfig, 'type', 'Line');
for i = 1:numel(hd)
    ax = hd(i);
    ax.LineWidth = line_Linewidth;
end

% colorbar
hd = findall(hfig, 'type', 'colorbar');
for i = 1:numel(hd)
    ax = hd(i);
    %
    ax.FontSize = Fontsize*0.8;
    ax.Color = color;
    ax.LineWidth = axis_Linewidth;
    ax.Box = 'off';
end

end