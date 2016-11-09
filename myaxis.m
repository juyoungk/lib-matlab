function myaxis(varargin)
% for black background!
% setting values
%
Fontsize = 18;
color = [0.9 0.9 0.1];
axis_Linewidth = 1.5;
%

% figure handle for current figure
hfig = get(groot,'CurrentFigure');
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

    text = ax.Title.String;
    % text can be cell array. text{1} might be needed.
    % disp(['(text of Title?) ', text{1}]);
    title(ax, text, 'Color', color, 'FontSize', Fontsize);

    ax.XAxis.LineWidth = axis_Linewidth;
    ax.YAxis.LineWidth = axis_Linewidth;
end


editmenufcn(hfig, 'EditCopyFigure');


end
