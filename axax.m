function ax = axax(ax)
    
    if nargin < 2
        ax = gca;
    end

    Fontsize = 18;
    color = [0 0 0];
    axis_Linewidth = 2.4;
    
    ax.XAxis.FontSize = Fontsize;
    ax.YAxis.FontSize = Fontsize;
%     ax.XAxis.Color = color;
%     ax.YAxis.Color = color;
%     ax.XLabel.Color = color;
%     ax.YLabel.Color = color;
%     ax.GridColor = [0.1, 0.1, 0.1];

    text = ax.Title.String;
    % text can be cell array. text{1} might be needed.
    % disp(['(text of Title?) ', text{1}]);
    title(ax, text, 'Color', color, 'FontSize', Fontsize);

    ax.XAxis.LineWidth = axis_Linewidth;
    ax.YAxis.LineWidth = axis_Linewidth;

end 