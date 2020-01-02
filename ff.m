function ff(line_Linewidth)
% Figure Font update

%color = [1 1 1];
color = [0 0 0]; % black
%disp('Current axis/label color is black');

Fontsize = 24;
axis_Linewidth = 1.5;
if nargin < 1
    line_Linewidth = 1.5;
end

hfig = get(groot,'CurrentFigure');

% axes
hd = findall(hfig, 'type', 'axes');
for i = 1:numel(hd)
    ax = hd(i);
    %
    ax.XAxis.FontSize = Fontsize;
    ax.XAxis.Color = color;
    ax.XAxis.LineWidth = axis_Linewidth;
    
    for j=1:numel(ax.YAxis)
        ax.YAxis(j).FontSize = Fontsize;
        %ax.YAxis(j).Color = color;
        ax.YAxis(j).LineWidth = axis_Linewidth;
    end
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
    title(ax, text, 'Color', color, 'FontSize', Fontsize-4);

    
    
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