function [s] = daq_single_ch_recording(ch, varargin)
%
% daq_single_ch_recording(ch)
% daq_single_ch_recording(ch, duration)
%
devices = daq.getDevices
s = daq.createSession('ni'); % adptor (vendor) 

% input channels
s.addAnalogInputChannel('Dev2', ch, 'Voltage');

% sampling rate = 10K
s.Rate = 10000; 

% duration
global duration;
duration = 1000;
s.DurationInSeconds = duration;
s.NotifyWhenDataAvailableExceeds = 0.05*s.Rate;    % every 1s event call

% Add listener (Real-time data plot)
% figure; ylim auto;
% lh = s.addlistener('DataAvailable', @(src,event) plot(event.TimeStamps, event.Data));
lh = s.addlistener('DataAvailable', @plotData);

%
shg;
s.startBackground;
wait(s);

% delete listener;
delete (lh)
clear duration;

end

function plotData(src,event)
    persistent tempData;
    persistent tempTimeStamps;
    persistent initTime;
    global duration;
    
    sampleRate = 10000;
    displayInterval = 5; % in seconds
    if(isempty(initTime))% at the beginning,
         tempData = [];
         tempTimeStamps = [];
         initTime = 0;
    end
    tempData = [tempData;event.Data];
    tempTimeStamps = [tempTimeStamps; event.TimeStamps];
    ylim auto; 
    plot(tempTimeStamps,tempData)
    xlim([initTime initTime+displayInterval]);
    if numel(tempData)>=displayInterval*sampleRate
        tempData = [];
        tempTimeStamps = [];
        initTime = initTime + displayInterval;
    end
    if initTime >= duration
        clear initTime;
    end
end