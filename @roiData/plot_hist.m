function plot_hist(r, id, num_bin)
% Histogram of ROI trace. Output statistics.
% default trace type: Smoothed trace.

if nargin <3 
    num_bin = 25;
end

if nargin <2
    id = 1:r.numRoi;
end

N = numel(id);

if N > 1
    % multi cell plot
    
    figure('Name', 'Smoothed trace');
    
    num_col = ceil(sqrt(N));
    num_row = ceil(sqrt(N));
    
    for i = id
        
        subplot(num_row, num_col, i); 
        r.plot_hist(i, num_bin);
        
        if mod(i, num_col) ~= 1
            ylabel('');
        end
    end
    
    
else
    % single cell plot. No figure.
    
    % smoothed trace
    x = r.roi_smoothed(:, id);
    
    %
    myplot_hist(x, num_bin);
    title(['ROI ', num2str(id),''], 'FontSize', 16);
    hold on
    
    ax = gca;
    
    % Line plot: mean value of raw trace 
    m = r.stat.mean_f(id);
    plot([m m], ax.YLim, '-', 'LineWidth', 1, 'Color', 0.4*[1 1 1]);
    text( 1.1*m, 0.95*ax.YLim(end), sprintf('%.0f',m), 'FontSize', 12, 'Color', 'k', ...
                                'VerticalAlignment', 'top', 'HorizontalAlignment','left');
    
    
    hold off
end



end


function [N, EDGES] = myplot_hist(x, num_bin)
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
ylabel('Prob. (%)');
xlim(EDGES([1, end]));

%plot(xtick, N, 'kd', 'MarkerSize', 15, 'MarkerFaceColor', 'k')
plot(xtick, N, 'LineWidth', 2.5); 

hold off

ax = gca;

Fontsize = 16;
ax.XAxis.FontSize = Fontsize;
ax.YAxis.FontSize = Fontsize;

end