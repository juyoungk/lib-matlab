function plot(r)
% Method of class 'roiData'
% Create new figure with interactive keyboard navigation over roi#

    hfig = figure('Position', [100 230 1300 840]);
    axes('Position', [0  0  1  0.9524], 'Visible', 'off');
    
    cc = r.roi_cc;
    ev = r.stim_times;
    interval = r.stim_duration;
    % setting for figure
%     hfig.Color = 'none';
%     hfig.PaperPositionMode = 'auto';
%     hfig.InvertHardcopy = 'off';
    % callback
    set(hfig, 'KeyPressFcn', @keypress)
    
    % roi # and max #
    i_roi = 1;
    imax = r.numRoi;
    S = sprintf('ROI %d  *', 1:imax); C = regexp(S, '*', 'split'); % C is cell array.
    
    % roi rgb image
    labeled = labelmatrix(cc);
    RGB_label = label2rgb(labeled, @parula, 'k', 'shuffle');
    
    %
    n_col_subplot = 3;
    
    function redraw()
        mask = false(cc.ImageSize);
        
        % 1. whole trace
        subplot(2, n_col_subplot, [1, n_col_subplot]);
            plot_trace(r, i_roi);
            % event lines
            hold on
            ylabel('a.u.');
            axis auto;
            ax = gca; Fontsize = 15;
            ax.XAxis.FontSize = Fontsize;
            ax.YAxis.FontSize = Fontsize;
            ax.XLim = [0 r.f_times(end)];
            text(ax.XLim(end), ax.YLim(end), C{i_roi}, 'FontSize', 15, 'Color', 'k', ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
            for i=1:length(ev)
                plot([ev(i) ev(i)], ax.YLim, '--', 'LineWidth', 1.1, 'Color',0.6*[1 1 1]);
                %plot([ev(i)+interval/2, ev(i)+interval/2], ax.YLim, ':', 'LineWidth', 1.0, 'Color',0.5*[1 1 1]);
            end   
            hold off
            
            
        subplot(2, n_col_subplot, n_col_subplot+1);
            %axes('Position', [0  0  1  1], 'Visible', 'off');
            mask(cc.PixelIdxList{i_roi}) = true;
            h = imshow(RGB_label);
            set(h, 'AlphaData', 0.9*mask+0.1);
            
            ax = gca;
            str1 = sprintf('%d/%d ROI', i_roi, imax);
            text(ax.XLim(end), ax.YLim(1), str1, 'FontSize', 12, 'Color', 'k', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
            
        % 3. roi avg over multiple repeats
        subplot(2, n_col_subplot, n_col_subplot+2);
            plot_avg(r, i_roi);
                ax = findobj(gca, 'Type', 'Line');
                ax.LineWidth = 1.5;
                ax = gca; 
                Fontsize = 14;
                ax.XAxis.FontSize = Fontsize;
                ax.YAxis.FontSize = Fontsize;
                
                axis on;
                
                if strfind(r.ex_name, 'flash')
%                     ax.XLim = [0 2*interval];
%                     ax.XTick = 0:(interval/2):(2*interval);                  
%                     % Additional line for On-Off transition.
%                     plot([0 0], ax.YLim, 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
%                     plot([interval, interval], ax.YLim, 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
%                     plot([interval*0.5, interval*0.5], ax.YLim, '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
%                     plot([interval*1.5, interval*1.5], ax.YLim, '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]); 

                else
                    % moving bar or etc.
                    ax.XLim = [0 interval];
                    ax.XTick = [];
                end
                hold off
                xtickformat('%.0f');
    end

    redraw();
    
    function keypress(~, evnt)
        
        switch lower(evnt.Key)
            case 'rightarrow'
                i_roi = min(i_roi + 1, imax); 
            case 'leftarrow'
                i_roi = max(1, i_roi - 1);
                
            otherwise
                return;
        end
        redraw();
    end

end