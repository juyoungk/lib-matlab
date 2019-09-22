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
            if contains(traceType, 'smoothed')
                y = r.avg_trace(:, id_roi);
            elseif contains(traceType, 'filtered')
                y = r.avg_trace_fil(:, id_roi);
            elseif contains(traceType, 'normalized') % default plotType
                %y = r.avg_trace_norm(:, id_roi);    
                y = r.avg_trace_smooth_norm(:, id_roi);
            else
                disp('trace Type should be one of ''normalized'', ''smoothed'' or ''filtered''. ''smoothed'' trace was used');
                y = r.avg_trace(:, id_roi);
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

                % Plot
                if isempty(h_axes)
                    s.h = plot(times, y, 'LineWidth', w_Line, argPlot{:}); hold on;
                else
                    s.h = plot(h_axes, times, y, 'LineWidth', w_Line, argPlot{:}); hold on;
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
                
                ax = gca;  Fontsize = 10;
                
                
                if Label == true % many kinds of labels.    
                    % ROI id
                    if numel(id_roi) == 1 %&& strcmp(PlotType,'tiled')
                        text(ax.XLim(1), ax.YLim(end), C{id_roi}, 'FontSize', 10, 'Color', 'k', ...
                                    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');                   
                    end
                    % cluster id
                    c_id = unique(r.c(id_roi));
                    if numel(c_id) == 1 && c_id~=0
                        text(ax.XLim(end), ax.YLim(end), ['C',num2str(c_id)], 'FontSize', 9, 'Color', 'k', ...
                                    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');                   
                    end
                    % Correlation between traces                    
                    str = sprintf('r = %.2f ', r.p_corr.smoothed_norm(id_roi));
                    text(ax.XLim(end), ax.YLim(1), str, 'FontSize', 10, 'Color', 'k', ...
                                'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
                end
                
                
                if Lines == true
                    
                    y_line = ax.YLim;
                    
                    % Additional lines first
                    % event does not need to shift
                    % avg trigger events
                    tt = ((1:ceil(r.n_cycle))-1)*duration;
                    for n = 1:length(tt)
                        x = tt(n);
                        if x < r.t_range(1) && x > r.t_range(2)
                            continue;
                        end
                        % Lines for avg trigger times
                        plot([x x], y_line, 'LineWidth', 1, 'Color', 0.4*[1 1 1]); hold on
                        
                        if contains(r.ex_name, 'flash')
                            x = x + r.avg_duration/2.;
                            plot([x x], y_line, '-.', 'LineWidth', 1, 'Color', 0.8*[1 1 1]); hold on
                        end
                    end

                    % within one repeat, stim trigger events
                    for k = 1:length(r.avg_stim_times) % measured by PD.
                        x = r.avg_stim_times(k);
                        if x < r.t_range(1) || x > r.t_range(2)
                            continue;
                        end
                        if k ~= 1
                            plot([x x], y_line, '-', 'LineWidth', 1, 'Color', 0.4*[1 1 1]);
                        end

                        kk = mod(k, r.avg_every); % kk-th stimulus within one repeat.
                        if kk == 0; kk = r.avg_every; end

                        % tag
                        if ~isempty(r.avg_stim_plot(kk).tag) && Label
                            text(x, ax.YLim(1), r.avg_stim_plot(kk).tag, 'FontSize', 15, 'Color', 'k', ...
                                'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');
                        end

                        % middle lines
                        if r.avg_stim_plot(kk).middleline == true
                            if kk == r.avg_every
                                next_stim = r.avg_duration;
                            else
                                next_stim = r.avg_stim_times(kk+1);
                            end
                            x = x + 0.5*(next_stim-r.avg_stim_times(kk));
                            plot([x x], y_line, '-.', 'LineWidth', 1.0, 'Color', 0.4*[1 1 1]);
                        end

                    end
                end
                
                %ax.XLim = [x(1), max(x(end), r.avg_trigger_interval)]; % at least up to avg_trigger_interval
                ax.XLim = [times(1), times(end)];
                ax.XAxis.FontSize = Fontsize;
                ax.YAxis.FontSize = Fontsize;
                % XTick positions: independent of phase value
                ax.XTick = [r.avg_stim_times, r.avg_stim_times+r.avg_duration];
        %         ax.XTickLabel = linspace(- r.s_phase * duration, (r.n_cycle-r.s_phase)*duration, length(ax.XTick));  
                xtickformat('%.0f');
                if Lines == true
                    s.YLim = y_line; % save current YLim
                end

                hold off;
            end

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
        strcmp(x,'filtered') || strcmp(x,'smoothed') || strcmp(x,'projected'));
    
    p.addParameter('PlotType', 'tiled', @(x) strcmp(x,'tiled') || ...
        strcmp(x,'all') || strcmp(x,'mean') || strcmp(x,'overlaid'));
    
    p.addParameter('NormByCol', false, @(x) islogical(x));
    p.addParameter('DrawPlot', true, @(x) islogical(x));
    p.addParameter('Label', true, @(x) islogical(x));
    p.addParameter('Lines', true, @(x) islogical(x));
    p.addParameter('LineWidth', 1.5, @(x) x>0);
    p.addParameter('Color', [], @(x) isvector(x) || ischar(x) || isempty(x)); % [0 0.4470 0.7410]
    p.addParameter('axes', []);
    p.addParameter('Smooth', 1, @(x) x>0);
 
%     addParamValue(p,'verbose', true, @(x) islogical(x));
%     addParamValue(p,'png', false, @(x) islogical(x));
%     
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end