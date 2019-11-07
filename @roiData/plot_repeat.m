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
    TraceType = p.Results.TraceType;
    Normalization = p.Results.Norm;
    MeanPlot = p.Results.MeanPlot;
    
    disp ('');
    n_plots_per_fig = 64;
    switch PlotType
        case 'overlaid' % default mode
            n_col=6;
            n_row=3;
            %hfig = figure('Position', [10 55 900 450]);
            
            n_plots_per_fig = 15;
            n_col=5;
            n_row=3;
            hfig = figure('Position', [10 55 235*n_col 200*n_row]);
            
            % Juyoung Demo
%             n_plots_per_fig = 64;
%             n_col=8;
%             n_row=8;
%             hfig = figure('Position', [10 55 950 950]);
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
        m = 0.0; % margin
        h_ax = (1-m)/n_row;
        w_ax = (1-m)/n_col;
        h_ax_mean   = 1/n_row * (1/6);
        h_ax_repeat = 1/n_row * (5/6) - m/2.;
        if contains(PlotType, 'overlaid')
            %n_row = n_col;
            %n_row = 2;
            h_ax = (1-m)/n_row;
            h_ax_mean   = 1/n_row * 0.99;
            h_ax_repeat = 0;
        end
        
    %
    n_plots_per_fig = n_col * n_row;
    
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
    
    % All repaets for all ROIs
    [y_aligned, x] = r.align_trace_to_avg_triggers(TraceType);
    disp(['Trace type: ',TraceType]);
    
    % Exclude 1st response.
    %y_aligned = y_aligned(:,:,2:end);
    %disp('First response was ignored.');
            
    function redraw()   
        % delete all objects
        delete(hfig.Children);
        
        % loop over cell (ROI) id: i
        for i = 1:n_plots_per_fig 
            % i : index for axes position in the figure. --> i_cell --> ROI id (k), axis position (p, q) 
            
            i_cell = (i_fig - 1) * n_plots_per_fig + i;
            if i_cell > n_ROI
                break;
            end
            k = I(i_cell); % real ROI index
            
            % i (roi id) --> (p, q) position
            p = rem(i-1, n_col); % i = 1 should be p = 0.
            q = ceil(i/n_col);
            %
            x_ax = m/2. + p * w_ax;
            y_ax = 1 - m/2. - q * h_ax;

            % Individual traces for single cell or ROI id.
            y = y_aligned(:,k,:);
            y = squeeze(y);
            
            % Normalization
            % norm by col: mean substraction and normalization
            % (only for plotting)
            if strcmp(Normalization, 'column')
                y = y - mean(y, 1);
                y = normc(y); % should norm the avg trace too. 
            elseif strcmp(Normalization, 'repeat_baseline')
                % y = times x repeats (single cell)
                % baseline
                duration_baseline = 5; % sec
                ti = max(r.avg_stim_times(2) - duration_baseline, 0); % ti should be larger than time 0
                i_baseline = find(r.a_times > ti, 1);
                f_baseline = i_baseline + round(duration_baseline/r.ifi);
                % normalization by baseline between i and f
                y = normc_baseline(y, i_baseline, f_baseline);
            end
            y_mean = mean(y, 1);
                
            % 2. Draw Mean (& std) trace
            ax = axes('Parent', hfig, 'OuterPosition', [x_ax,  y_ax+h_ax-h_ax_mean  w_ax  h_ax_mean], 'Visible', 'off');
                
            if contains(PlotType, 'overlaid')
                
                % Draw mean and freeze axis?, then update..
                
                % Plot individual traces
                plot(x, y, 'Color', 0.60*[1 1 1], 'LineWidth', 0.8);
                axis off
                hold on
                xlim( [r.a_times(1), r.a_times(end)] );
%                 if i == 1
%                     yrange = ax.YLim; % apply same range for all ROIs since all has been centered & normalized. 
%                 end
                
                r.plot_avg_style;
                
                % Plot avg trace
                if MeanPlot
                    color_line = 'k'; %color_line = [0 0.45 0.74];
                    [~, s] = r.plot_avg(k, 'traceType', 'normalized',...
                                            'PlotType', PlotType,... % 'overliad' means drawing all traces + mean.
                                            'LineWidth', 2., 'Color', color_line,... 
                                            'Label', true, 'Lines', true, 'NormByCol', true);
                end
                %ylim(yrange);
                hold off;
                ylabel ''; % or 'dF/F'

            else
                % Mean traces
                r.plot_avg(k, 'traceType', 'normalized');
                %axis off
                title('Mean response');
                
                n_repeats = size(y, 2);
                h_ax_one_trace = 0.90*(h_ax_repeat)/n_repeats;
                
                % individual traces
                for ii = 1:n_repeats
                    ax = axes('Parent', hfig, 'OuterPosition', [x_ax,  y_ax + (n_repeats-ii)*h_ax_one_trace, w_ax,  h_ax_one_trace], 'Visible', 'off');
                    y_single = y(:,ii);
                    
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
    p.addParameter('TraceType', 'smoothed_norm', @(x) strcmp(x,'raw') || ...
        strcmp(x,'smoothed') || strcmp(x,'smoothed_norm') || strcmp(x,'smoothed_detrend_norm') || ...
        strcmp(x, 'filtered') || strcmp(x, 'filtered_norm'));
    p.addParameter('Norm', 'column', @(x) strcmp(x, 'column') || strcmp(x, 'repeat_baseline'));
    p.addParameter('MeanPlot', true, @(x) islogical(x));
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