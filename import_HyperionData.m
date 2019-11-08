function m = import_HyperionData(filename)

CountRate = h5read(filename, '/CountRate');
h = h5read(filename, '/CountRate_headers');

m.count = CountRate.count;
m.period = double(CountRate.period(1)) * 1e-9;
m.timestamp = convertTimestamp(h.timestamp) + m.period/2.;
m.exp_id = h.experiment_id(1);

%%
cri = h5read(filename, '/Cri');
h = h5read(filename, '/Cri_headers');
m.cri = cri.count;
m.cri_onset_ps = cri.utime_from_ps(1);
m.cri_until_ps = cri.utime_until_ps(1);
m.cri_timestamp = convertTimestamp(h.timestamp) + m.period/2.;
m.cri_exp_id = h.experiment_id;

%%
dtof = h5read(filename, '/Dtof');
h = h5read(filename, '/Dtof_headers');

m.dtof = dtof.counts;
m.dtof_range_min = dtof.range_min(1); % same over one experiment 
m.dtof_range_max = dtof.range_max(1); % same over one experiment 
m.dtof_resolution = dtof.resolution(1); % ps
m.dtof_timestamp = convertTimestamp(h.timestamp) + m.period/2.;
m.dtof_exp_id = h.experiment_id(1);

end

function time_in_sec = convertTimestamp(timestamp)

timestamp = timestamp - timestamp(1); % ns precision
time_in_sec = double(timestamp) * 1e-9; % sec

end