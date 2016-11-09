function [pd, ev_idx, srate] = getpd(filename)
% set of commands to get PD signal from H5 data file.
% # of data = fileinfo.GroupHierarchy.Datasets.Dims
% Assume ch-1 is Photodiode signal.

% info 
fileinfo = hdf5info(filename);
%
srate = 10000;
srate = fileinfo.GroupHierarchy.Datasets.Attributes(1).Value; % sample-rate
num = fileinfo.GroupHierarchy.Datasets.Dims(1);
% Ch # for PD
ch = 1;

% extract PD signal
pdraw = h5read(filename, '/data', [1 ch], [num ch]);
pd = scaled(pdraw);

%
min_ev_interval_secs = 0.5;
th_level = 0.7;
ev_idx = pd_event_display(pd, min_ev_interval_secs, th_level, srate);
%
% pdts = (1:num)/srate;
% 
% figure('position', [680 620 1250 500]);
% %
% ax1 = subplot(3, 1, 1);
% plot(pdts', pd); hold on;
% xlim([0 50]);
% xlabel(ax1, '[secs]');
% %
% ax2 = subplot(3, 1, 2);
% plot(pdts', pd); hold on; 
% xlim([pdts(end)-300 pdts(end)]);
% xlabel(ax2, '[secs]');
% 
% % event
% min_ev_interval_secs = 0.5;
% ev_idx = th_crossing(pd, 0.7, min_ev_interval_secs*srate);
% plot(ax1, pdts(ev_idx), pd(ev_idx), 'bo');
% plot(ax2, pdts(ev_idx), pd(ev_idx), 'bo');
% 
% % event is regular?
% inter_event_interval = ev_idx(2:end) - ev_idx(1:end-1);
% ax3 = subplot(3, 1, 3);
% plot(inter_event_interval/srate, '-o');
% xlabel(ax3, 'event id');
% ylabel(ax3, 'Interevent duration [s]');
% ylim(ax3, [0 inf]);

end
