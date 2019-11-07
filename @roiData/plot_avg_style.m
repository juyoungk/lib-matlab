function s = plot_avg_style(r, varargin)
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
    
    % Adjust for plot (phase & cycles)
    %[y, times] = r.traceAvgPlot(y);
    %
    % 2019 0313 no more need for adjusting phase & cycle when
    % plotting since the avg data was collected accordingly in
    % advance.
    duration = r.avg_duration;
    times = r.a_times;

    %error plot
%     if p.Results.Std
%         hold off
%         lo = y - e;
%         hi = y + e;
%         lo = lo(:);
%         hi = hi(:);
%         times = times(:);
%         hp = patch([times; times(end:-1:1); times(1)], [lo; hi(end:-1:1); lo(1)], 'r');
%         set(hp, 'facecolor', [1 0.8 0.8], 'edgecolor', 'none');
%         hold on
%     end

    ax = gca;
    y_line = ax.YLim;
    
    % change font size
    Fontsize = 15;
    ax.XAxis.FontSize = Fontsize; % This can change the range of plots
    ax.YAxis.FontSize = Fontsize;
    ax.XLim = [times(1)-r.ifi/4., times(end)+r.ifi/4.];
    
    % back to the original scale
    ax.YLim = y_line;
    
    % XTick positions: independent of phase value
    ax.XTick = [r.avg_stim_times, r.avg_stim_times+r.avg_duration];
%   ax.XTickLabel = linspace(- r.s_phase * duration, (r.n_cycle-r.s_phase)*duration, length(ax.XTick));  
    xtickformat('%.0f');

    if Lines == true
        hold on
        
        s.YLim = y_line; % save current YLim

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
        hold off
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