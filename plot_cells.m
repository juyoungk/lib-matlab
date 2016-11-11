function [ax, h_legend] = plot_cells(data, xdata, label_txt, legend_txt)

% data - cell array. 
% xdata - 

if nargin < 4
    legend_txt = [];
end
if nargin < 3
    label_txt = {[], []};
end

num = numel(data);

hold on;
for i = 1:num
    if isempty(xdata)
        h = plot(data{i}, 'o-'); grid on;
    else
        h = plot(xdata, data{i}, 'o-'); grid on;
        set(gca, 'XTick', xdata);
    end
    h.LineWidth = 1.2;
end

ax = gca;
ax.LineWidth = 1;


xlabel(label_txt{1});
ylabel(label_txt{2});

if ~isempty(legend_txt)
    S = sprintf([legend_txt, ' %d*'], 1:num); D = regexp(S, '*', 'split');
    h_legend = legend(D{1:(end-1)}, 'Location', 'northeast');
    h_legend.FontSize = 5;
    %h.position(4)=0.5;
end

end