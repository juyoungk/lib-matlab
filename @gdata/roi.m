function [hfig, hfig2] = roi(obj, channel)
% Method of class 'gdata'
% data viewer: roi select and average over repeats.

    if nargin <2
        if obj.header.n_channelSave == 1
            channel = obj.header.channelSave(1);
        else    
            channel = input('Imaging PMT channel # ? (1-4) ');
        end
    end

    % snapshot for given ch
    hfig = imvol(obj.AI_mean{channel}, 'title', obj.ex_name);
     pos = hfig.Position;
     
    % figure for analysis buttons
    hfig2 = figure('Position', [pos(1)+pos(3)+10, pos(2), 180, 400]);
     
    % data struct for guidata
    %   ch #
    %   main fig handle
    data = struct('ch', channel, 'hfig', hfig);

    % guidata in fig2 
    guidata(hfig2, data)
    
    % Analysis buttons in Figure 2
    % roi trace
    pushbutton1 = uicontrol('Style', 'pushbutton',...
           'String', 'ROI trace',...
           'Position', [20 300 100 50],...
           'Callback', @obj.roitrace_Callback);   
    
    pushbutton2 = uicontrol('Style', 'pushbutton',...
           'String', 'ROI trace avg',...
           'Position', [20 240 100 50],...
           'Callback', @obj.roiavg_Callback);   
    
    pushbutton3 = uicontrol('Style', 'pushbutton',...
           'String', 'ROI single viewer',...
           'Position', [20 180 100 50],...
           'Callback', @obj.roiplot_Callback);   
    
       
    % refocus
    figure(hfig);  
    
end


