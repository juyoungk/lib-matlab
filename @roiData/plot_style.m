function plot_style(r, ax, plotType, varargin)

p=ParseInput(varargin{:});
%
% traceType = p.Results.traceType;
% PlotType = p.Results.PlotType;
w_Line    = p.Results.LineWidth;

if nargin < 3
    plotType = 'avg';
end

if nargin < 2
    ax = gca;
end

if contains(plotType, 'avg')
    
            Fontsize = p.Results.FontSize;
            duration = r.avg_trigger_interval;
            
            ax.XLim = [r.a_times(1), r.a_times(end)];
            ax.XAxis.FontSize = Fontsize;
            ax.YAxis.FontSize = Fontsize;
            
            % XTick positions: independent of phase value
            ax.XTick = (0:0.5:(r.n_cycle)) * duration;
    %         ax.XTickLabel = linspace(- r.s_phase * duration, (r.n_cycle-r.s_phase)*duration, length(ax.XTick));  
            xtickformat('%.1f');
            xlabel('sec');
            
            % Additional lines
            hold on
            for n = 1:r.n_cycle
                x = (n-1) * duration;
                plot([x x], ax.YLim, 'LineWidth', 0.8, 'Color', 0.35*[1 1 1]);
                
                % middle line
                if strfind(r.ex_name, 'flash')
                    x = (n-1) * duration + duration/2.;
                    plot([x x], ax.YLim, 'LineWidth', 0.8, 'Color', 0.35*[1 1 1]);
                end
                
                % stim trigger lines between avg triggers
                for k = 1:(r.avg_every-1)
                    x = (n-1) * duration + k * r.stim_trigger_interval;
                    plot([x x], ax.YLim, 'LineWidth', 0.8, 'Color', 0.35*[1 1 1]);
                end
            end
            hold off
            
%             % y-label
%             if contains(plotType, 'normalized')
%                 ylabel('dF/F');
%             else
%                 ylabel('a.u.');
%             end

end


end

function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
%     p.addParameter('traceType', 'normalized', @(x) strcmp(x,'normalized') || ...
%         strcmp(x,'filtered') || strcmp(x,'smoothed') || strcmp(x,'projected'));
%     
%     p.addParameter('PlotType', 'tiled', @(x) strcmp(x,'tiled') || ...
%         strcmp(x,'all') || strcmp(x,'mean'));
%     
    
%     p.addParameter('DrawPlot', true, @(x) islogical(x));
    p.addParameter('LineWidth', 1.5, @(x) x>0);
    p.addParameter('FontSize', 15, @(x) x>0);
 
%     addParamValue(p,'verbose', true, @(x) islogical(x));
%     addParamValue(p,'png', false, @(x) islogical(x));
%     
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end