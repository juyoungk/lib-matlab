function ids = plot_repeat(r, I, varargin)
% PLOT version 'repeat'.
% Limited number of plots per figure. Keyboard navigation for next set of
% ROIs.
%
% input:
%           I - array of ROI index
%             - logic array
%             - If I < 1, lower bound for correlation between repeats.  
%
% output:
%           'ids' - array of ROI index (filtered by correlation)
%
% varargin:
%           'PlotType'
%               'overlaid' (Black mean + overlaid all traces except 1st one)
%               'tiled'
    
    p=ParseInput(varargin{:});
    PlotType = p.Results.PlotType;
    
    disp ('');
    n_plots_per_fig = 64;
    switch PlotType
        case 'overlaid'
            n_col=6;
            n_row=3;
            %hfig = figure('Position', [10 55 900 450]);
            n_col=4;
            n_row=5;
            %hfig = figure('Position', [10 55 550 750]);
            % Juyoung Demo
            n_col=8;
            n_row=8;
            hfig = figure('Position', [10 55 950 950]);
        case 'tiled'
            n_col=2;
            n_row=9;
            hfig = figure('Position', [10 55 1110 1050]);
        otherwise
    end
    
    % ROI ids? 1. direct input 2. filter by p value. 
    if nargin < 2
        % 12 cells having highest correlationns
        numCell = min(n_plots_per_fig, r.numRoi);
        [~, good_cells] = sort(r.p_corr.smoothed_norm, 'descend');
        I = good_cells(1:numCell);
        fprintf('%d ROIs having highest correlation are seleted. (plot_repeat)\n', numCell);
    end
    if length(I) == 1 && I < 1 % ROIs selected by correlation 
        p = I;
        I = 1:r.numRoi;    
        I = I(r.p_corr.smoothed_norm > p);
        fprintf('%d ROIs are seleted with a condition of p > %.2f. (plot_repeat)\n', numel(I), p);
    end
    ids = I;
    n_ROI = numel(I);
    if n_ROI == 0
        print('No ROI was selected or given');
        return;
    end
   
    % Special case. n=1
    if n_ROI == 1
        n_plots_per_fig = 1;
        n_col = 1;
        n_row = 1;
    end

    % Figure 
    %hfig = figure('Position', [10 55 1110 1050]);
    %hfig = figure('Position', [1780 1274 1079 442]); % 2019 Feb Steve Grant Fig
    
    % callback
    set(hfig, 'KeyPressFcn', @keypress)
    
    i_fig = 1;
    
     % axes dim for single ROI (cell)
        m = 0.1; % margin
        h_ax = (1-m)/n_row;
        w_ax = (1-m)/n_col;
        h_ax_mean   = 1/n_row * (1/6);
        h_ax_repeat = 1/n_row * (5/6) - m/2.;
        if contains(PlotType, 'overlaid')
            %n_row = n_col;
            %n_row = 2;
            h_ax = (1-m)/n_row;
            h_ax_mean   = 1/n_row * 0.9;
            h_ax_repeat = 0;
        end
        
    %
    n_plots_per_fig = n_col * n_row;
    [I_plot, J_plot] = ind2sub([n_row, n_col], 1:n_plots_per_fig);
    
    %
    n_figs = ceil(n_ROI/n_plots_per_fig);
    S = sprintf('ROI %d  *', I); C = regexp(S, '*', 'split'); % C is cell array.
    
    % cluster id & initialize projection vector
%     i_c = 1; % id in sorted cluster array
%     p = zeros(size(r.c_mean, 2));
%     i_sorted = zeros(1, 100);
%     % Color setting for clusters;
%     c_list = unique(r.c(r.c~=0)); 
%     c_list_num = numel(c_list);
%     color = jet(c_list_num); 
    
    
    % roi rgb image
    labeled = labelmatrix(r.roi_cc);
    RGB_label = label2rgb(labeled, @parula, 'k', 'shuffle');
        
    function redraw()   
        % delete all objects
        delete(hfig.Children);
               
        for i = 1:n_plots_per_fig % loop over axes position(~ cell id) in given single figure
            
            i_cell = (i_fig - 1) * n_plots_per_fig + i;
            if i_cell > n_ROI
                break;
            end
            k = I(i_cell); % real ROI index
            
            % x y position given cell id
            x_ax = m/2. + (J_plot(i)-1) * w_ax;
            y_ax = m/2. + (I_plot(i)-1) * h_ax;
             
            % Algin single cell trace. Which trace? smoothed norm
            if i == 1
                disp('Trace type: smoothed_norm.'); 
            end
            y = r.roi_smoothed_norm(:, k);
           
            %
            [y_aligned, ~] = align_rows_to_events(y, r.f_times_norm, r.avg_trigger_times, r.n_cycle*r.avg_trigger_interval);
            y_aligned = reshape(y_aligned, size(y_aligned, 1), []); % times (row) x repeats (cols) 
            %
            [y_aligned, x] = r.traceAvgPlot(y_aligned);
  
            % 2. Draw Mean (& std) trace
            axes('Position', [x_ax,  y_ax+h_ax-h_ax_mean  0.8*w_ax  0.9*h_ax_mean], 'Visible', 'off');
                
            if contains(PlotType, 'overlaid')
                
                % Individual traces
                
                % norm by col?
                %y_aligned = normc(y_aligned);
                
                % Draw mean and freeze axis?, then update..
                
                % Plot individual traces
                plot(x, y_aligned, 'Color', 0.6*[1 1 1], 'LineWidth', 0.7); hold on 
                % plot(x, y_aligned, 'LineWidth', 0.7); hold on
                xlim([ max(r.t_range(1), r.a_times(1)), min(r.t_range(end),r.a_times(end)) ]);
                
                % Plot avg trace
                color_line = 'k'; %color_line = [0 0.45 0.74];
                [~, s] = r.plot_avg(k, 'traceType', 'normalized',...
                                        'PlotType', PlotType,...
                                        'LineWidth', 2., 'Color', color_line,... 
                                        'Label', true, 'Lines', true);
                hold on % axis freeze
                
                %title('Mean response');
                
                %ylim(s.YLim);
                hold off;
                axis off
                ylabel ''; % or 'dF/F'

            else
                % Mean traces
                r.plot_avg(k, 'traceType', 'normalized');
                %axis off
                title('Mean response');
                
                n_repeats = size(y_aligned, 2);
                h_ax_one_trace = 0.90*(h_ax_repeat)/n_repeats;
                % individual traces
                for ii = 1:n_repeats
                    ax = axes('Position', [x_ax,  y_ax + (n_repeats-ii)*h_ax_one_trace,  0.8*w_ax,  h_ax_one_trace], 'Visible', 'off');
                    y_single = y_aligned(:,ii);
                    
                    plot(x, y_single, 'LineWidth', 1.2); hold on
                    xlim([ max(r.t_range(1),r.a_times(1)), min(r.t_range(end),r.a_times(end)) ]);
                    ylim([ min(y_single), max(y_single)]);

                    % (optional) stim trigger lines
                    for k = 1:length(r.avg_stim_times) % measured by PD.
                        x0 = r.avg_stim_times(k);
                        if x0 < r.t_range(1) || x0 > r.t_range(2)
                            continue;
                        end
                        plot([x0 x0], ax.YLim, '-', 'LineWidth', 1.0, 'Color', 0.7*[1 1 1]);

                    end
                    hold off

                    axis tight
                    axis off

                end
            end

            % Print correlation value (now in plot_avg)
            fprintf('ROI %d corr: %.2f\n', k, r.p_corr.smoothed_norm(k));

        end
    end
    
    redraw();
    
    function keypress(~, evnt)
        a = lower(evnt.Key);        
        %fprintf('key event is: %s\n', evnt.Key);
        switch a
            case 'rightarrow'
                i_fig = i_fig + 1;
                if i_fig > n_figs
                    i_fig = n_figs;
                end
                
            case 'leftarrow'
                i_fig = i_fig - 1;
                if i_fig < 1
                    i_fig = 1;
                end
       
            otherwise
                return;
        end
        figure(hfig);
        redraw();
    end

end

function aa = vec(a)
aa = a(:);
end

function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    p.addParameter('PlotType', 'overlaid', @(x) strcmp(x,'tiled') || ...
        strcmp(x,'overlaid'));
    
    p.addParameter('Label', true, @(x) islogical(x));
      
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end

function [bw_selected, bw_array] = cc_to_bwmask(cc, id_selected)
% convert cc to bwmask array and totla bw for selected IDs.

    if nargin < 2
        id_selected = 1:cc.NumObjects;
    end

    bw_array = false([cc.ImageSize, cc.NumObjects]);

    for i = 1:cc.NumObjects
        grain = false(cc.ImageSize);
        grain(cc.PixelIdxList{i}) = true;
        bw_array(:,:,i) = grain;
    end
    % Total bw for selected IDs
    bw_selected = max( bw_array(:,:,id_selected), [], 3);
end