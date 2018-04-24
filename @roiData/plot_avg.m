function [trace, s] = plot_avg(r, id_roi, varargin)
% plot avg trace or RF (receptuve field)
%
% OPTION (varargin):
%       'PlotType' (options for multiple traces)
%           1. as 'tiled' (default)
%           2. as 'all'
%           3. as 'mean'
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
    h_axes    = p.Results.axes;
    DrawPlot = p.Results.DrawPlot;
    
    % data index inside a time range
    idx = (r.a_times > r.t_range(1)) & (r.a_times < r.t_range(2));
    
    S = sprintf('ROI %d*', 1:r.numRoi); C = regexp(S, '*', 'split'); % C is cell array.
    
    if nargin < 2
        id_roi = 1:r.numRoi; % loop over all rois
    end
    
    %if any([nargin>1 && numel(id_roi) == 1, avg_over_ROIs])
    if any([numel(id_roi) == 1, ~strcmp(PlotType,'tiled')])    
        % plot single roi avg trace
        if ~r.avg_FLAG
            % whitenoise rf
            
            plot_rf(r, id_roi, traceType);

        else 
            if isempty(r.avg_trace)
                error('No avg_trace in roiData object');
            end
            
            % trace type
            if contains(traceType, 'smoothed')
                y = r.avg_trace(:, id_roi);
            elseif contains(traceType, 'filtered')
                y = r.avg_trace_fil(:, id_roi);
            elseif contains(traceType, 'normalized')
                %y = r.avg_trace_norm(:, id_roi);    
                y = r.avg_trace_smooth_norm(:, id_roi);
            else
                disp('trace Type should be one of ''normalized'', ''smoothed'' or ''filtered''. ''smoothed'' trace was used');
                y = r.avg_trace(:, id_roi);
            end
            
            if NormByCol
                y = normc(y);
            end
            
            if strcmp(PlotType,'mean')
                y = mean(y, 2);
            end
            
            % Output1 : trace
            trace = y;
            % Output2 : stat
            s.min = min(y, [], 1);
            s.max = max(y, [], 1);
            s.df_max = s.max - s.min;
            
            %% Plot
            if DrawPlot
                % Adjust for plot (phase & cycles)
                y = r.traceForAvgPlot(y);
                y = y(idx);
                x = r.a_times(idx);
                
                duration = r.avg_trigger_interval;

                %
                if isempty(h_axes)
                    plot(x, y, 'LineWidth', w_Line); hold on;
                else
                    plot(h_axes, x, y, 'LineWidth', w_Line); hold on;
                end

                ax = gca;  Fontsize = 10;
                ax.XLim = [x(1), x(end)];
                ax.XAxis.FontSize = Fontsize;
                ax.YAxis.FontSize = Fontsize;
                % XTick positions: independent of phase value
                ax.XTick = (0:0.5:(r.n_cycle)) * duration;
        %         ax.XTickLabel = linspace(- r.s_phase * duration, (r.n_cycle-r.s_phase)*duration, length(ax.XTick));  
                xtickformat('%.1f');

                % y-label
                if contains(traceType, 'normalized') && ~NormByCol
                    ylabel('dF/F');
                else
                    ylabel('a.u.');
                end

                % ROI id
                if numel(id_roi) == 1 && strcmp(PlotType,'tiled')
                 text(ax.XLim(end), ax.YLim(1), C{id_roi}, 'FontSize', 9, 'Color', 'k', ...
                                'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');                   
                end
                % cluster id
                c_id = unique(r.c(id_roi));
                if c_id~=0
                    text(ax.XLim(end), ax.YLim(end), ['C',num2str(c_id)], 'FontSize', 9, 'Color', 'k', ...
                                'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');                   
                end

                % additional lines
                for n = 1:r.n_cycle
                    x = (n-1) * duration;
                    plot([x x], ax.YLim, 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
                    % middle line
                    if strfind(r.ex_name, 'flash')
                        x = (n-1) * duration + duration/2.;
                        plot([x x], ax.YLim, '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
                    end
                    % stim trigger lines between avg triggers
                    for k = 1:(r.avg_every)
                        if k ~= 1
                            x = (n-1) * duration + r.avg_stim_times(k);
                            plot([x x], ax.YLim, '-', 'LineWidth', 1.0, 'Color', 0.4*[1 1 1]);
                        end
                        % middle lines between stim triggers
                        if strfind(r.ex_name, 'typing')
                            x = (n-1) * duration + r.avg_stim_times(k) + 0.5*(r.avg_stim_times(k+1)-r.avg_stim_times(k));
                            plot([x x], ax.YLim, '-.', 'LineWidth', 1.0, 'Color', 0.4*[1 1 1]);
                        end
                    end  
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
        n_row = 5;
        n_col = 3; % limit num of subplots by fixing n_col
        % Figure params
        n_cells_per_fig = 60;
        
        k = 1; % index in selected roi group
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
        strcmp(x,'all') || strcmp(x,'mean'));
    
    p.addParameter('NormByCol', false, @(x) islogical(x));
    p.addParameter('DrawPlot', true, @(x) islogical(x));
    p.addParameter('LineWidth', 1.5, @(x) x>0);
    p.addParameter('axes', []);
 
%     addParamValue(p,'verbose', true, @(x) islogical(x));
%     addParamValue(p,'png', false, @(x) islogical(x));
%     
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end