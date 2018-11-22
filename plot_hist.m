function [N, EDGES] = plot_hist(x, num_bin)
% plot bar and line plot after calculating probability using histcounts.
% 2018 1121 Juyoung Kim

if nargin < 2
    num_bin =15;
end


[N, EDGES] = histcounts(x, num_bin, 'Normalization', 'probability'); % can be 'count'
% EDGES - boudaries of the histcounts. N+1 vector.
xtick = (EDGES(1:end-1) + EDGES(2:end))/2.;

% plot
N = N * 100;
bar(xtick, N, 1, 'LineStyle', 'none'); hold on
ylabel('Probability (%)');
xlim(EDGES([1, end]));

%plot(xtick, N, 'kd', 'MarkerSize', 15, 'MarkerFaceColor', 'k')
plot(xtick, N, 'LineWidth', 2.5); 

hold off

ax = gca;

Fontsize = 20;

ax.XAxis.FontSize = Fontsize;
ax.YAxis.FontSize = Fontsize;




end