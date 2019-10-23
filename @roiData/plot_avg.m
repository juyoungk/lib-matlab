function [trace, s] = plot_avg(r, id_roi, varargin)
% plot avg trace or RF (receptuve field)
%
% Output:
%           trace - averaged time-varying trace
%           s     - stat & line handle
%
% OPTION (varargin):
%       'PlotType' (options for multiple traces)
%           1. 'tiled' (default)
%           2. 'all'
%           3. 'mean'
%           4. 'overlaid' - individual traces overlaid with mean trace
%
%       'DrawPlot' - whether it acturally draws the plot. One can plot
%       afterward using output 'trace'.
%    
% varargin for traceType, not plot options

    p=ParseInput(varargin{:});
    traceType = p.Results.traceType;
    PlotType = p.Results.PlotType;
    NormByCol = p.Results.NormByCol;
    w_Line    = p.Results.LineWidth;
    lineColor = p.Results.Color;
    h_axes    = p.Results.axes;
    DrawPlot = p.Results.DrawPlot;
    Label    = p.Results.Label;
    Lines    = p.Results.Lines;
    Smooth_size = p.Results.Smooth;
    Name = p.Results.Name;
    
    argPlot = {};
    
    S = sprintf('ROI %d*', 1:r.numRoi); C = regexp(S, '*', 'split'); % C is cell array.
    
    if nargin < 2
        id_roi = 1:r.numRoi; % loop over all rois
    end
    
    if islogical(id_roi)
        ids = 1:r.numRoi;
        id_roi = ids(id_roi);
    end
    
    %if any([nargin>1 && numel(id_roi) == 1, avg_over_ROIs])
    if any([numel(id_roi) == 1, ~strcmp(PlotType,'tiled')])    
        % plot single roi avg trace
        if ~r.avg_FLAG
            
            % whitenoise rf
            if ~isempty(r.stim_fliptimes) && ~isempty(r.stim_movie)
                plot_rf(r, id_roi, traceType);
            end

        else 
            if isempty(r.avg_trace)
                error('No avg_trace in roiData object');
            end
            
            % trace type
            if strcmp(traceType, 'smoothed')
                y = r.avg_trace(:, id_roi);
                e = r.stat.smoothed.std(:, id_roi);
                p_corr = r.p_corr.smoothed;
            elseif strcmp(traceType, 'filtered')
                y = r.avg_trace_fil(:, id_roi);
                e = r.stat.filtered.std(:, id_roi);
                p_corr = r.p_corr.filtered;
            elseif strcmp(traceType, 'normalized') % default plotType
                %y = r.avg_trace_norm(:, id_roi);    
                y = r.avg_trace_smooth_norm(:, id_roi);
                e = r.stat.smoothed_norm.std(:, id_roi);
                p_corr = r.p_corr.smoothed_norm;
            elseif strcmp(traceType, 'smoothed_detrend_norm')
                y = r.avg_trace_smooth_detrend_norm(:, id_roi);
                e = r.stat.smoothed_detrend_norm.std(:, id_roi);
                p_corr = r.p_corr.smoothed_detrend_norm;
            elseif strcmp(traceType, 'smoothed_detrend_norm_repeat')
                y = r.avg_trace_smooth_detrend_norm_repeat(:, id_roi);
                e = r.stat.smoothed_detrend_norm_repeat.std(:, id_roi);
                p_corr = r.p_corr.smoothed_detrend_norm_repeat;
            elseif strcmp(traceType, 'smoothed_norm_repeat')
                y = r.avg_trace_smooth_norm_repeat(:, id_roi);
                e = r.stat.smoothed_norm_repeat.std(:, id_roi);
                p_corr = r.p_corr.smoothed_norm_repeat;
            else
                disp('trace Type should be one of ''normalized'', ''smoothed'' or ''filtered''. ''smoothed'' trace was used');
                y = r.avg_trace(:, id_roi);
                e = r.stat.smoothed(:, id_roi);
                p_corr = r.p_corr.smoothed;
            end
            
            if NormByCol  
                y = y - mean(y,1); % mean substraction.
                y = normc(y);      % scaling.
            end
            
            if contains(PlotType,'mean')
                y = mean(y, 2);
            end
            
            % smooth over averaged trace
            if Smooth_size > 1
                y = smoothdata(y, r.smoothing_method, Smooth_size);
            end
            
            % Output1 : trace
            trace = y;
            
            % Output2 : stat
            s.min = min(y, [], 1);
            s.max = max(y, [], 1);
            s.df_max = s.max - s.min;
            
            %% Plot
            if DrawPlot
                
                duration = r.avg_duration;
                
                % Adjust for plot (phase & cycles)
                %[y, times] = r.traceAvgPlot(y);
                %
                % 2019 0313 no more need for adjusting phase & cycle when
                % plotting since the avg data was collected accordingly in
                % advance.
                times = r.a_times;
                
                % Do you want to have more control on color? Use ColorOrderIndex.
                if contains(PlotType, 'tiled') || contains(PlotType, 'mean')
                    if ~isempty(lineColor)
                        argPlot = {'Color', lineColor};
                    end
                end
                
                if contains(PlotType,'overlaid') % output is the mean trace
                    y_mean = mean(y, 2);
                    argPlot = {'Color', 0.6*[1 1 1]};
                end
                
                % error plot
                if p.Results.Std
                    hold off
                    lo = y - e;
                    hi = y + e;
                    lo = lo(:);
                    hi = hi(:);
                    times = times(:);
                    hp = patch([times; times(end:-1:1); times(1)], [lo; hi(end:-1:1); lo(1)], 'r');
                    set(hp, 'facecolor', [1 0.8 0.8], 'edgecolor', 'none');
                    hold on
                end

                % Plot
                if isempty(h_axes)
                    s.h = plot(times, y, 'LineWidth', w_Line, argPlot{:}); 
                    hold on;
                else
                    s.h = plot(h_axes, times, y, 'LineWidth', w_Line, argPlot{:}); 
                    hold on;
                end 
                
                % Add mean trace for 'overlaid' case.
                if contains(PlotType,'overlaid')     
                    plot(times, y_mean, 'LineWidth', 2.0, 'Color', 'k')
                end
                
                % y-label
                if contains(traceType, 'normalized') && ~NormByCol
                    ylabel('dF/F');
                else
                    ylabel('a.u.');
                end
                
                ax = gca;
                y_line = ax.YLim;
                Fontsize = 15;
                ax.XAxis.FontSize = Fontsize; % This can change the range of plots
                ax.YAxis.FontSize = Fontsize;
                %ax.XLim = [x(1), max(x(end), r.avg_trigger_interval)]; % at least up to avg_trigger_interval
                ax.XLim = [times(1)-r.ifi/4., times(end)+r.ifi/4.];
                if Lines == true
                    ax.YLim = y_line;
                    s.YLim = y_line; % save current YLim
                end
                % XTick positions: independent of phase value
                ax.XTick = [r.avg_stim_times, r.avg_stim_times+r.avg_duration];
        %         ax.XTickLabel = linspace(- r.s_phase * duration, (r.n_cycle-r.s_phase)*duration, length(ax.XTick));  
                xtickformat('%.0f');
                
                if Lines == true
                    
                    y_line = ax.YLim;
                    
                    % Additional lines first
                    % event does not need to shift
                    % avg trigger events
                    tt = ((1:ceil(r.n_cycle))-1)*duration;
                    for n = 1:length(tt)
                        x0 = tt(n);
                        if x0 < r.t_range(1) && x0 > r.t_range(2)
                            continue;
                        end
                        % Lines for avg trigger times in average plot
                        % (probably, one or two lines.)
                        plot([x0 x0], y_line, ':', 'LineWidth', 1.1, 'Color', 0.5*[1 1 1]);
                        
                        if contains(r.ex_name, 'flash')
                            x0 = x0 + r.avg_duration/2.;
                            plot([x0 x0], y_line, '-.', 'LineWidth', 1, 'Color', 0.8*[1 1 1]);
                        end
                    
                        % within one repeat, stim trigger events
                        num_stims = length(r.avg_stim_times);
                        for k = 1:num_stims % measured by PD.
                            x = r.avg_stim_times(k) + x0;
                            if x < r.t_range(1) || x > r.t_range(2)
                                continue;
                            end
                            
                            if k < num_stims
                                next_stim = r.avg_stim_times(k+1) + x0;
                            else
                                next_stim = r.avg_duration + x0;
                            end
                            middleline = (x+next_stim)/2.;
                            
                            if middleline > r.a_times(end)
                                continue;
                            end
    
                            % Draw line except for the first stim.
                            if k ~= 1
                                plot([x x], y_line, ':', 'LineWidth', 1.1, 'Color', 0.5*[1 1 1]);
                            end

    %                         k = mod(k, r.avg_every); % kk-th stimulus within one repeat.
    %                         if k == 0; k = r.avg_every; end
                            
                            % tag
                            if ~isempty(r.avg_stim_plot(k).tag) && Label
                                text(middleline, ax.YLim(1), r.avg_stim_plot(k).tag, 'FontSize', 15, 'Color', 'k', ...
                                    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
                            end

                            % middle lines
                            if r.avg_stim_plot(k).middleline == true
                                x = x + 0.5*(next_stim-r.avg_stim_times(k));
                                plot([x x], y_line, '-.', 'LineWidth', 1.0, 'Color', 0.4*[1 1 1]);
                            end

                        end
                    end
                end
                
                if Label == true % many kinds of labels.    
                    % ROI id
                    if numel(id_roi) == 1 %&& strcmp(PlotType,'tiled')
                        if isempty(Name)
                            Name = C{id_roi};
                        end
                        text(ax.XLim(1), ax.YLim(end), Name, 'FontSize', 15, 'Color', 'k', ...
                                    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');                   
                    end
                    % cluster id
                    c_id = unique(r.c(id_roi));
                    if numel(c_id) == 1 && c_id~=0
                        text(ax.XLim(end), ax.YLim(end), ['C',num2str(c_id)], 'FontSize', 9, 'Color', 'k', ...
                                    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');                   
                    end
                end
                if p.Results.Corr
                    % Correlation between traces (always smoothed_normed)                   
                    str = sprintf('%.2f', p_corr(id_roi));
                    text(ax.XLim(end), ax.YLim(1), ['{\it r} = ',str], 'FontSize', 15, 'Color', 'k', ...
                                'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
                end

            end
            hold off;

        end

    else
    % No id for ROI: plot all trace
        
        roi_array = id_roi;     % loop over selected rois
        
        % ex info
        str_smooth_info = sprintf('smooth %d (~%.0f ms)', r.smoothing_size, r.ifi*r.smoothing_size*1000);
        str_events_info = sprintf('stim duration: %.1fs', r.stim_duration); 
        str_info = sprintf('%s\n%s', str_events_info, str_smooth_info);
                
        % subplot params
        n_row = 10;
        n_col = 9; % limit num of subplots by fixing n_col
        % Figure params
        n_cells_per_fig = 85;
        
        if contains(r.ex_name, 'typing')
            n_col = 3;
            n_cells_per_fig = 29;
        end
        
        k = 1; % index in selected roi group
        
        % Create multiple figures
        while (k <= numel(roi_array))
        %while (rr <= 30)
        
            % figure info
            pos_new = get(0, 'DefaultFigurePosition');
            figure('Position', [pos_new(1), 100, pos_new(3)*2.2, pos_new(4)*1.4]);
            axes('Position', [0  0  1  0.9524], 'Visible', 'off');
            title(r.ex_name);

            %for rr = 1:r.numRoi % loop over rois
            for i = 1:n_cells_per_fig % subplot index
                
                    if k > numel(roi_array); break; end;

                    subplot(n_row, n_col, i);
                    rr = roi_array(k);
                    % plot for roi# rr
                    r.plot_avg(rr, varargin{:});
                        
                    % bottom-most subplot: x label
                    if any(i == n_cells_per_fig)
                        xlabel('sec');
                    end
                    % increase roi id
                    k = k + 1;
            end
            
            % Text comment on final subplot
            subplot(n_row, n_col, n_row*n_col);
            ax = gca; axis off;
            text(ax.XLim(end), ax.YLim(1), str_info, 'FontSize', 11, 'Color', 'k', ...
                        'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
            text(ax.XLim(end), ax.YLim(1), ['exp: ', r.ex_name], 'FontSize', 11, 'Color', 'k', ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment','right');
            %
            %saveas(gcf, [r.ex_name,'_ROI_avg_trace__smoothging',num2str(r.smoothing_size),'_tiled.png']);
        end
    end
            
end

function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    p.addParameter('traceType', 'normalized', @(x) strcmp(x,'normalized') || ...
        strcmp(x,'filtered') || strcmp(x,'smoothed') || strcmp(x,'projected') || ...
        strcmp(x, 'smoothed_detrend_norm') || strcmp(x, 'smoothed_norm_repeat') || strcmp(x, 'smoothed_detrend_norm_repeat'));
    
    p.addParameter('PlotType', 'tiled', @(x) strcmp(x,'tiled') || ...
        strcmp(x,'all') || strcmp(x,'mean') || strcmp(x,'overlaid'));
    
    p.addParameter('NormByCol', false, @(x) islogical(x));
    p.addParameter('DrawPlot', true, @(x) islogical(x));
    p.addParameter('Label', true, @(x) islogical(x));
    p.addParameter('Lines', true, @(x) islogical(x));
    p.addParameter('Corr', true, @(x) islogical(x));
    p.addParameter('Std', false, @(x) islogical(x));
    p.addParameter('LineWidth', 1.6, @(x) x>0);
    p.addParameter('Color', [], @(x) isvector(x) || ischar(x) || isempty(x)); % [0 0.4470 0.7410]
    p.addParameter('axes', []);
    p.addParameter('Smooth', 1, @(x) x>0);
    p.addParameter('Name', [], @(x) ischar(x));
 
%     addParamValue(p,'verbose', true, @(x) islogical(x));
%     addParamValue(p,'png', false, @(x) islogical(x));
%     
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end