function rf = corrRF(r, id_roi, traceType, maxlag, upsampling)
% traceType = 'normalized', 'raw', 'smoothed'
% upsampling = 1 (default) or 2
    
    if nargin < 5
        upsampling = 1;
    end
    
    if nargin < 4
        maxlag = 1.8; %sec
    end
    

    if nargin>1 && numel(id_roi) == 1 && isnumeric(id_roi)

        % trace type & convert f_times to f_times_norm
        if nargin < 3
            % trace = normalized
            y = r.roi_normalized(:, id_roi);
            
        elseif contains(traceType, 'normalized')
            y = r.roi_normalized(:, id_roi);
            
        elseif contains(traceType, 'raw')
            y = r.roi_trace(:, id_roi);
            y = y(r.f_times>r.ignore_sec) %- r.roi_trend;
            
        elseif contains(traceType, 'smoothed')
            y = r.roi_smoothed(:, id_roi);
            %y = y(r.f_times>r.ignore_sec) - r.roi_trend;
            y = y(r.f_times>r.ignore_sec);
        else
            disp('trace Type should be one of ''normalized'', ''raw'', ''smoothed''. ''Normalized'' trace was used');
            y = r.roi_normalized(:, id_roi);
        end
                    
        % reverse correlation (after data centering)
        rf = corrRF4(y, r.f_times_norm, r.stim_whitenoise, r.stim_fliptimes + r.stim_trigger_times(1), upsampling, maxlag);
        
        % display
        imshow(scaled(rf), 'Colormap', parula); % jet, parula, winter ..
                
    else
    % compute rf for all rois
        
        if nargin > 1 && ischar(id_roi)
            traceType = id_roi;
        else
            traceType = 'normalized';
        end

        % ex info
        S = sprintf('ROI %d*', 1:r.numRoi); C = regexp(S, '*', 'split'); % C is cell array.
        str_smooth_info = sprintf('smooth size %d (~%.0f ms bin)', r.smoothing_size, r.ifi*r.smoothing_size*1000);
        %str_events_info = sprintf('stim duration: %.1fs', r.stim_duration); 
        str_events_info = [];
        str_info = sprintf('%s\n%s', str_events_info, str_smooth_info);
        
        % subplot params
        n_row =  8;
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
            
            % figure creation
            make_figure(500);
            title([r.ex_name, ': reverse correlation']);

            %for rr = 1:r.numRoi % loop over rois
            for i = 1:n_cells_per_fig % subplot index
                
                    if k > numel(roi_array); break; end;

                    subplot(n_row, n_col, i);
                    rr = roi_array(k);
                    
                    % plot for roi# rr
                    rf = corrRF(r, rr, traceType);
                    
                    %
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
            saveas(gcf, [r.ex_name,'_ROI_whitenoise_corrRF.png']);
        end
        
    end

end 

function make_figure(x_shift, y_shift)
    
    if nargin < 2
        y_shift = 0;
    elseif nargin < 1
        x_shift = 0;
    end
    
    pos_new = get(0, 'DefaultFigurePosition');
    figure('Position', [pos_new(1) + x_shift, 100 + y_shift, pos_new(3)*2.4, pos_new(4)*2]);
    axes('Position', [0  0  1  0.9524], 'Visible', 'off');
end