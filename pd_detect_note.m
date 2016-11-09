function pd = getpd(filename)
% set of commands to get PD signal from H5 data file.

%
srate = 10000;

% extract PD signal
aaa = h5read(filename,'/data');
pd = aaa(:,1);
pd = scaled(pd);

%
t_pd_end = length(pd)/srate % print
pdts = (1/srate):(1/srate):t_pd_end;

%
figure;
plot(pdts, pd);
xlim([0 100]);
min_ev_interval_secs = 0.5;

%
ev_idx = th_crossing(pd, 0.7, min_ev_interval_secs*srate);
hold on; plot(pdts(ev_idx),pd(ev_idx),'bo');

% visual angle for salamander 50 um / degree

end
