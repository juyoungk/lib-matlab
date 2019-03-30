function hfig = makeFigBlack(hfig, color)
%
% Copy Figure to clipboard for black background
% See also the function 'ccc' for just copying the figure to the clipboard
% 
% 2019 0315 color can be given by input argument.

if nargin < 2
    color = [0.9 0.9 0.1];
    color = [1 1 1];
    %color = [0.1 0.1 0.1];
end

Fontsize = 22;
axis_Linewidth = 2.4;
%

% figure handle for current figure
if nargin <1
    hfig = get(groot,'CurrentFigure');
end

% Transparent background for figure
% fig = gcf;
hfig.Color = 'none';
hfig.PaperPositionMode = 'auto';
hfig.InvertHardcopy = 'off';
% 'on' : automatically changes the background to white for hard copy

% handles for all the axes in the figure
hd = findall(hfig, 'type', 'axes');
%ax = gca;
%ax_prev = ax; % save for recover

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
