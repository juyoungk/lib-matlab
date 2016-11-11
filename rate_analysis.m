function [mean_r, peak_r, peak_t, first_t, h_title] = rate_analysis(r, bin_size, t_window, draw_graph, varargin)
% input:
%       r - [m X n] array. m-times experiment. n-bins
% output:
%       all 1-D array
%       first_t - timing of the first spike. It is defined as the first
%       non-zero value. Might not be appropriate.
%
if nargin < 4
    draw_graph =1;
end

if ~ismatrix(r)
    error('array r is not a matrix');
end

[n_exp, n_bin] = size(r);

% average over all bins (all times)
mean_r = mean(r, 2);

% peak of the rate & its latency
[peak_r, id_r] = max(r, [], 2);
peak_t = (id_r-0.5)*bin_size + t_window(1);

% latency of the first spike(?)
first_t = zeros(n_exp, 1);
for i = 1:n_exp
    id = find(r(i,:)); % non-zero value
    if isempty(id)
        first_t(i) = NaN;
    else
        first_t(i) = (id(1)-0.5)*bin_size  + t_window(1);
    end
end

h_title =[];

% display
if draw_graph
    figure; 
    n_plot = 3;
    exp_trials = 1:n_exp; % final variable of the condition (e.g. speed)

    subplot(2,n_plot,1); 
        imagesc(r); title('PSTH');
        t_last = n_bin * bin_size * 1000/100; % * 100 ms
        xtick_label = 1:2:t_last;
        xtick_pos = round((xtick_label/10/bin_size)+0.5);
        set(gca, 'XTick', xtick_pos, 'XTickLabel', xtick_label);
        xlabel('[x100 ms]');

    subplot(2,n_plot,2);             
             plot( mean_r, exp_trials, 'o-'); xlabel('Mean FR [Hz]');% Mean of FR
             ylabel('trials');
             set(gca,'Ydir','reverse'); grid on;
    subplot(2,n_plot,3);
             plot(peak_r, exp_trials, 'o-'); xlabel('Peak FR [Hz]');% Peak of FR
             ylabel('trials');
             set(gca,'Ydir','reverse'); grid on;
             h_title = gca;
    subplot(2,n_plot,[4,5]); 
            plot( peak_t, exp_trials, 'o-'); hold on;  % latency of the peak FR        
            plot(first_t, exp_trials, 'o-'); hold on;  % latency of the 1st spike
            legend({'peak', 'first'},'FontSize',8,'Location','southeast');
            legend('boxoff')
            xlabel('Latency [s]');
            set(gca,'Ydir','reverse'); grid on;
            t_end = min(0.8, t_last);
            xlim([0 t_end]);

    subplot(2, n_plot, [6]);
            [~, I] = sort(peak_r);
            scatter(peak_r(I),  peak_t(I)); hold on;
            scatter(peak_r(I), first_t(I)); hold on; 
            %legend({'peak', 'first'},'FontSize',8,'Location','northeast');
            %legend('boxoff')
            xlabel('Peak FR [Hz]'); ylabel('Latency [s]');
            ax = gca;
            ax.Position(3) = 0.9* ax.Position(3);  
end

end