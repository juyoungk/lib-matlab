function [data, time] = daq_conti_record(s, duration)
% Acquire and save the final data and timestamps at [data, time]
figure;
global acq_Data;
global acq_Time;
% global FramePeriod = 0.16;  % 60 Hz = 0.16 ms
acq_Data = []; acq_Time = [];

% sampling rate = 10K
s.Rate = 5000; 
s.DurationInSeconds = duration;
% Add listener (Real-time data plot)
lh = s.addlistener('DataAvailable', @plotData);
s.NotifyWhenDataAvailableExceeds = 10000;    % event call rate

s.startBackground;
wait(s);

data = acq_Data;
time = acq_Time;

acq_Data = []; acq_Time = [];

% delete listener;
delete (lh)

end

function plotData(src, event)
    persistent tempData;
    persistent tempTime;
    global acq_Data;
    global acq_Time;
    global FramePeriod;
    num_bin = 10;

    if(isempty(tempData))
         tempData = [];
    end
    
    h = [subplot(2,1,1), subplot(2,1,2)];
    plot(h(1), event.TimeStamps, event.Data(:,1)) % photodiode signal
    plot(h(2), event.TimeStamps, event.Data(:,2)) % voltage data
    
    %tempData = [tempData; event.Data];
    %tempTime = [tempTime; event.TimeStamps];
    %acq_Data = tempData;
    %acq_Time = tempTime;
    
    acq_Data = [acq_Data; event.Data];
    acq_Time = [acq_Time; event.TimeStamps];
   
    % onlineRF(data, num_bin, stim, frate)
    % RF = calculateRF(event.Data(:,2), event.TimeStamps, num_bin, stim, FramePeriod);
end
