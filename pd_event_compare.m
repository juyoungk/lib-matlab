function [ev_secs, ev_interval] = pd_event_compare(pd, ev_secs, srate)

if nargin < 3
    srate = 10000;
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

%
plot(ax1, ev_secs, 0.7, 'bo'); % converts to (real time, pd amp)
plot(ax2, ev_secs, 0.7, 'bo');

% event is regular?
ax3 = subplot(4, 1, 3);
ev_interval = ev_secs(2:end) - ev_secs(1:end-1);
plot(ax3, ev_secs(1:end-1), ev_interval, '-o');
xlabel(ax3, '[secs]');
ylabel(ax3, 'duration [s]');
axis tight

ax4 = subplot(4, 1, 4);
plot(ax4, ev_interval, '-o');
xlabel(ax4, 'event id');
ylabel(ax4, 'event duration [s]');


end