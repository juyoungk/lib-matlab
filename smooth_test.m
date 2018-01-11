% Smoothing test:

smoothing_size = 5;
smoothing_method = 'movmean'; % or 'sgolay'
ch = 1;
    

% Smoothing over time for all channels.
        roi_smoothed = cell(1, n_ch);
        for ch = 1:n_ch
            roi_smoothed{ch} = zeros(n_roi, h.n_frames_ch);
            for i = 1:n_roi        
                if ~isempty(roi_mean{i,ch})
                    %roi_smoothed{ch}(i,:) = smoothdata(roi_mean{i,ch}, 'sgolay', smoothing_size);
                    roi_smoothed{ch}(i,:) = smoothdata(roi_mean{i,ch}, smoothing_method, smoothing_size);
                end
            end
        end
          
        
 id_roi = 9;
 [roi_aligned, s_times] = align_analog_signal_to_events(roi_smoothed{ch}, f_times, ev, interval);
 avg_response = mean(roi_aligned, 3);
 avg_response = avg_response.';
 y = avg_response(:,id_roi);
 
 %
 figure;
 axes('Position', [0  0  1  0.9524], 'Visible', 'off');
 %
 
plot(s_times, y, 'LineWidth', 1.5); hold on
    xlabel('sec'); ylabel('a.u.');
    axis off;
    ax = gca; Fontsize = 12;
    ax.XAxis.FontSize = Fontsize;
    ax.YAxis.FontSize = Fontsize;
    ax.XLim = [0 interval];
    
    text(ax.XLim(end), ax.YLim(1), C{rr}, 'FontSize', 12, 'Color', 'k', ...
        'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
    plot([interval/2 interval/2], ax.YLim, '--', 'LineWidth', 1.2, 'Color',0.6*[1 1 1]); hold off


                

      ax.XTickLabel = linspace(ax.XTick(1),ax.XTick(end),numel(ax.XTick));
      xlabel('sec');