function [ev_secs, ev_interval] = pd_event_display(pd, min_ev_interval_secs, th_event, srate)

if nargin < 4
    srate = 10000;
end
if nargin < 3
    th_event = 0.7;
end
if nargin < 2
    min_ev_interval_secs = 0.5;
end

num = length(pd);
pdts = (1:num)/srate;

figure('position', [80 300 1250 600]);
%figure;
%
ax1 = subplot(4, 1, 1);
plot(pdts', pd); hold on;
xlim([0 50]);
xlabel(ax1, '[secs]');
%
ax2 = subplot(4, 1, 2);
plot(pdts', pd); hold on; 
xlim([pdts(end)-300, pdts(end)]);
xlabel(ax2, '[secs]');

% event
ev_idx = th_crossing(pd, th_event, min_ev_interval_secs*srate);
ev_secs = ev_idx/srate;
%
plot(ax1, pdts(ev_idx), pd(ev_idx), 'bo'); % converts to (real time, pd amp)
plot(ax2, pdts(ev_idx), pd(ev_idx), 'bo');

% event is regular?
ax3 = subplot(4, 1, 3);
ev_interval = ev_idx(2:end) - ev_idx(1:end-1);
ev_interval = ev_interval/srate;
plot(ax3, pdts(ev_idx(1:end-1)), ev_interval, '-o');
xlabel(ax3, '[secs]');
ylabel(ax3, 'duration [s]');
axis tight

ax4 = subplot(4, 1, 4);
plot(ax4, ev_interval, '-o');
xlabel(ax4, 'event id');
ylabel(ax4, 'event duration [s]');


end