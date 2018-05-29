function roiscan(obj, idx)
% Inspect roi responses under the same FOV
% Navigate rois in the selected group (j index)
    
   
    if nargin < 2
        idx = obj.roi_selected;
    end

    % interactive plot over selected roi ids
    h = figure('Position', [100 230 1300 1040]);
    axes('Position', [0  0  1  0.9524], 'Visible', 'off');
    
    % callback
    set(h, 'KeyPressFcn', @keypress)

    % j - roi index in selected group
    j = 1;
    jmax = length(idx);
    
    %
    plot(obj, idx(j));

    
    function keypress(src, evnt)
    % increase / decrease roi index in selected group
    % should control two indice.

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
 
        %
        plot(obj, idx(j));
    end
    
end


        
