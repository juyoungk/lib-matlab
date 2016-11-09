function daq_simple_background(s, duration)
s.DurationInSeconds = duration;
% Add listener (Real-time data plot)
lh = s.addlistener('DataAvailable', @(src, event) plot(event.TimeStamps,event.Data));
s.NotifyWhenDataAvailableExceeds = 5000;    % event call rate

s.startBackground;
wait(s);

% delete listener;
delete (lh)

end