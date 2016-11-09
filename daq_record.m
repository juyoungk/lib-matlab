function [data, time] = daq_record(s, duration)

s.DurationInSeconds = duration;
% Add listener (Real-time data plot)
% lh = s.addlistener('DataAvailable', @plotData);
%s.NotifyWhenDataAvailableExceeds = 5000;    % event call rate

% Record start
[data, time] = s.startForeground;

plot_recdata(data, time);
% delete listener;
% delete (lh)

end


