function [s] = Init_DAQ()
devices = daq.getDevices
s = daq.createSession('ni'); % adptor (vendor) 

% input channels
s.addAnalogInputChannel('Dev2', 0, 'Voltage');
s.addAnalogInputChannel('Dev2', 1, 'Voltage');

% output channles
%s.addAnalogOutputChannel('Dev2', 1, 'Voltage');

% queueOutputData(s, [siganl1, ..]);
%s.startForeground;

% trigger setting
% arg1 - source 'external': trigger by external events
% s.addTriggerConnection('external','Dev2/PFI0','StartTrigger');
% s.addTriggerConnection('Dev2/PFI1','external','StartTrigger');
% s.Connections(1).TriggerCondition='RisingEdge';
s.ExternalTriggerTimeout = 20;

% sampling rate = 10K
s.Rate = 10000; 

% default acquisition duration
s.DurationInSeconds = 5;

end