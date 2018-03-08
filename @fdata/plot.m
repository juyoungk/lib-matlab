function plot(obj, i)
    % plot1: smoothed roi trace of 1st imaging session
    % plot2: 
    
    % i_roi input
        % 1. integer input
        % 2. figure handle: .UserData.i
        % 3. no input: all roi plot ?
    if nargin > 1 
        if isnumeric(i)
            i_roi = i;
%         elseif ishandle(i)
%             hfig = i;
%             i_roi = hfig.UserData.i;
        else
            error('ROI index was not given properly. Not integer or figure handle');
        end    
    end
    
    % col # = img session # + ROI portrait
    n_col_subplot = obj.numImaging + 1;
    n_row_subplot = obj.numImaging + 2;
    tot_subplot = n_col_subplot * n_row_subplot;
    %
     imax = numel(obj.numRoi);
       cc = obj.cc;
    %
    str1 = sprintf('ROI %d', i_roi);
    str2 = sprintf('%d/%d ROI', i_roi, imax);
   
        % 1. whole trace
        for k = 1:obj.numImaging
            subplot(n_row_subplot, n_col_subplot, (k-1)*n_col_subplot+[1, n_col_subplot]);

                i_imaging_session = k;
                ax = plot_trace_raw(obj.g(i_imaging_session).rr, i_roi);
                text(ax.XLim(end), ax.YLim(end), str1, 'FontSize', 15, 'Color', 'k', ...
                        'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
        end

        % 2. Portrait of ROI    
        subplot(n_row_subplot, n_col_subplot, tot_subplot - 2*n_col_subplot+1);
            mask = false(cc.ImageSize);
            mask(cc.PixelIdxList{i_roi}) = true;
            h = imshow(obj.roi_rgb);
            set(h, 'AlphaData', 0.9*mask+0.1);
            
            ax = gca;
            text(ax.XLim(end), ax.YLim(1), str2, 'FontSize', 12, 'Color', 'k', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
            
        % 3. avg trace over multiple imaging sessions
        for k = 1:obj.numImaging
            subplot(n_row_subplot, n_col_subplot, tot_subplot - 2*n_col_subplot+1+k);
            ax = plot_avg(obj.g(k).rr, i_roi);
%                     ax = findobj(gca, 'Type', 'Line');
%                     ax.LineWidth = 2.5;
            str_session = strsplit(obj.g(k).ex_name, obj.FOV_name);
            str_session = str_session{end};
            title(str_session, 'FontSize', 16);
            
            subplot(n_row_subplot, n_col_subplot, tot_subplot - n_col_subplot+1+k);
            ax = plot_avg_fil(obj.g(k).rr, i_roi);
%                     ax = findobj(gca, 'Type', 'Line');
%                     ax.LineWidth = 2.5;
            
            
        end
end

function str_ex_name = get_ex_name(tif_filename)
    s_filename = strrep(tif_filename, '_', '  ');    
    s_filename = strrep(s_filename, '00', '');
    loc_name = strfind(s_filename, '.');
    str_ex_name = s_filename(1:loc_name-1);
end