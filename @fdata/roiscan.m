function roiscan(obj)
% Inspect roi responses under the same FOV
% Navigate rois in the selected group (j index)
    
    % interactive plot over selected roi ids
    h = figure('Position', [100 230 1300 1040]);
    axes('Position', [0  0  1  0.9524], 'Visible', 'off');
    
    % callback
    set(h, 'KeyPressFcn', @keypress)

    % j - roi index in selected group
    j = 1;
    h.UserData.j = j;
    h.UserData.roi_selected = obj.roi_selected;
    
    %
    plot(obj, obj.roi_selected(j));

    
    function keypress(src, evnt)
    % increase / decrease roi index in selected group
    % should control two indice.

        roi_selected = src.UserData.roi_selected;
        j = src.UserData.j;  % roi index in selected  
        jmax = length(roi_selected);

        switch lower(evnt.Key)
            case 'rightarrow'
                % next roi in selected group
                j = min(j + 1, jmax); 
            case 'leftarrow'
                % previous roi in selected group
                j = max(1, j - 1);
            otherwise
                return;
        end

        src.UserData.j = j;
        %
        plot(obj, roi_selected(j));
    end
    
    
end


        
