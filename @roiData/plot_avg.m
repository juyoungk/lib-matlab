function s = plot_avg(r, id_roi, varargin)
% plot avg trace or RF (receptuve field)
% varargin for traceType, not plot options

    p=ParseInput(varargin{:});
    traceType = p.Results.traceType;
    
    if nargin>1 && numel(id_roi) == 1
        
        % plot single roi avg trace
        if ~r.avg_FLAG
            % whitenoise rf
            
            plot_rf(r, id_roi, traceType);

        else 
            if isempty(r.avg_trace)
                ax = [];
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
            
            y = r.traceForAvgPlot(y);
            x = r.a_times;

            duration = r.avg_trigger_interval;

            %plot(x, y, 'LineWidth', 1.5, varargin{:}); hold on;
            plot(x, y, 'LineWidth', 1.5); hold on;
            ax = gca;  Fontsize = 10; 
            ax.XLim = [r.a_times(1), r.a_times(end)];
            ax.XAxis.FontSize = Fontsize;
            ax.YAxis.FontSize = Fontsize;
            % XTick positions: independent of phase value
            ax.XTick = (0:0.5:(r.n_cycle)) * duration;
    %         ax.XTickLabel = linspace(- r.s_phase * duration, (r.n_cycle-r.s_phase)*duration, length(ax.XTick));  
            xtickformat('%.1f');
            
            % y-label
            if contains(traceType, 'normalized')
                ylabel('dF/F');
            else
                ylabel('a.u.');
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
                for k = 1:(r.avg_every-1)
                    x = (n-1) * duration + k * r.stim_trigger_interval;
                    plot([x x], ax.YLim, '-.', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
                end

            end
            hold off;
            
            %statistics of avg responses
            s.min = min(y);
            s.max = max(y);
            s.df_max = max(y) - min(y);
            
        end

    else
    % No id for ROI: plot all trace
        
        % ex info
        S = sprintf('ROI %d*', 1:r.numRoi); C = regexp(S, '*', 'split'); % C is cell array.
        str_smooth_info = sprintf('smooth size %d (~%.0f ms bin)', r.smoothing_size, r.ifi*r.smoothing_size*1000);
        str_events_info = sprintf('stim duration: %.1fs', r.stim_duration); 
        str_info = sprintf('%s\n%s', str_events_info, str_smooth_info);
                
        % subplot params
        n_row = 8;
        n_col = 10; % limit num of subplots by fixing n_col
        % Figure params
        n_cells_per_fig = 75;
        
        %        
        if nargin < 2
            roi_array = 1:r.numRoi; % loop over all rois
        else
            roi_array = id_roi;     % loop over selected rois
        end
        
        k = 1; % index in selected roi group
        while (k <= numel(roi_array))
        %while (rr <= 30)
        
            % figure info
            pos_new = get(0, 'DefaultFigurePosition');
            figure('Position', [pos_new(1), 100, pos_new(3)*2.2, pos_new(4)*1.8]);
            axes('Position', [0  0  1  0.9524], 'Visible', 'off');
            title(r.ex_name);

            %for rr = 1:r.numRoi % loop over rois
            for i = 1:n_cells_per_fig % subplot index
                
                    if k > numel(roi_array); break; end;

                    subplot(n_row, n_col, i);
                    rr = roi_array(k);
                    % plot for roi# rr
                    r.plot_avg(rr, varargin{:});
                        ax = gca;
                        text(ax.XLim(end), ax.YLim(1), C{rr}, 'FontSize', 9, 'Color', 'k', ...
                            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');                   

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
        strcmp(x,'filtered') || strcmp(x,'smoothed'));
    
%     addParamValue(p,'verbose', true, @(x) islogical(x));
%     addParamValue(p,'png', false, @(x) islogical(x));
%     addParamValue(p,'ex_str', [], @(x) ischar(x));
%     addParamValue(p,'scanZoom', [], @(x) isnumeric(x));
%     
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end