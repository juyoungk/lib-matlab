function [N, EDGES] = plot_hist(x, num_bin, BAR_GRAPH)
% plot bar and line plot after calculating probability using histcounts.
% roiDATA class has its own hist plot function inside plot_hist.
% num_bin can be EDGES!
% 2018 1121 Juyoung Kim

if nargin < 3
    BAR_GRAPH = true;
end

if nargin < 2
    num_bin =15;
end

[N, EDGES] = histcounts(x, num_bin, 'Normalization', 'probability'); % can be 'count'
% EDGES - boudaries of the histcounts. N+1 vector.
xtick = (EDGES(1:end-1) + EDGES(2:end))/2.;

% plot
N = N * 100;

if BAR_GRAPH
    bar(xtick, N, 1, 'LineStyle', 'none'); hold on
end

ylabel('Prob. (%)');
xlim(EDGES([1, end]));

%plot(xtick, N, 'kd', 'MarkerSize', 15, 'MarkerFaceColor', 'k')
plot(xtick, N, 'LineWidth', 2.5); 

ax = gca;

Fontsize = 20;

ax.XAxis.FontSize = Fontsize;
ax.YAxis.FontSize = Fontsize;




end