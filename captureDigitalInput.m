function captureDigitalInput(tf)
% example code for synchronizing DAQmx recording with FPGA (by Scanimage
% team)


    persistent hTask
    
    if nargin < 1
        tf = true;
    end
    
    if tf
        deviceName = 'PXI1Slot4';
        line = 'port0/line0';
        sampleRate = 1000; % Hz

        if ~isempty(hTask) && isvalid(hTask)
            hTask.delete();
        end
        
        hTask = most.util.safeCreateTask('My digital input Task');
        hTask.createDIChan('PXI1Slot4',line);
        hTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_ContSamps');
        sampleRate = hTask.sampClkRate;
        fprintf('Actual sample rate: %f\n',sampleRate);
        
        % synchronize to scanimage
        set(hTask,'sampClkTimebaseRate',10e6);
        set(hTask,'sampClkTimebaseSrc',['/' deviceName '/PXI_Clk10']);
        
        % set up trigger
        hTask.cfgDigEdgeStartTrig('PXI_Trig1'); % frame clock is exported to PXI_Trig6 on the back plane
        
        % setup callback
        everyNSamples = 1000;
        hTask.registerEveryNSamplesEvent(@everyNSamplesCallback,everyNSamples,true);
        hTask.start();
    else
        hTask.clear();
    end
    
end

function everyNSamplesCallback(obj, src, evt)
    persistent hPlot
    
    if isempty(hPlot) || ~isvalid(hPlot)
        hFig = figure;
        hAx = axes();
        hPlot = plot(hAx,src.data);
    else        
        hPlot.XData = 1:length(src.data);
        hPlot.YData = src.data;
    end
 
end