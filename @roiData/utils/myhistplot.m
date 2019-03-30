function [N, EDGES] = myhistplot(x, num_bin)
% plot bar and line plot after calculating probability using histcounts.
% 2018 1121 Juyoung Kim

if nargin < 2
    num_bin =20;
end


%[N, EDGES] = histcounts(x, num_bin, 'Normalization', 'probability'); % can be 'count'
%N = N * 100;

% EDGES - boudaries of the histcounts. N+1 vector.

[N, EDGES] = histcounts(x, num_bin, 'Normalization', 'count'); % can be 'count'
xtick = (EDGES(1:end-1) + EDGES(2:end))/2.;

bar(xtick, N, 1, 'LineStyle', 'none'); hold on
%ylabel('Prob. (%)');
xlim(EDGES([1, end]));

% Line plot 
%plot(xtick, N, 'kd', 'MarkerSize', 15, 'MarkerFaceColor', 'k')
%plot(xtick, N, 'LineWidth', 2.5); 

hold off

% figure setting

ax = gca;
Fontsize = 22;
ax.XAxis.FontSize = Fontsize;
ax.YAxis.FontSize = Fontsize;





end