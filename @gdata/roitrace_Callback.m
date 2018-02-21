function roitrace_Callback(obj, src, ~)
% src - event source handle

    data = guidata(src);

    % Main figure handle & gData object
      ch = data.ch;
    hfig = data.hfig;
    
    if ~isfield(hfig.UserData,'cc')
        disp('No ROI (cc) was selected');
        
    elseif isempty(hfig.UserData.cc)
        disp('No ROI (cc) was selected');
        
    elseif ~isempty(obj.cc) && (hfig.UserData.cc.NumObjects == obj.cc.NumObjects)
        % if cc is same as before, use same roiData
        for i=1:g.numStimulus
            plot_trace(obj.roiData(i))
        end
    else
        % assign new cc structure
        obj.cc = hfig.UserData.cc;
        
        % empty array of roiDATA
        r(1, obj.numStimulus) = roiData;

        % avg reponse traces according to stimulus id#
        for i=1:obj.numStimulus
            % construct roiData
            r(i) = roiData(obj.AI{ch}, obj.cc, [obj.ex_name,'_ch',num2str(ch)], obj.header.logFramePeriod, obj.stims{i});
            % plot avg
            r(i).plot_trace;
        end   
        obj.roiData = r;
    end
    
    %guidata(src, data);
end   