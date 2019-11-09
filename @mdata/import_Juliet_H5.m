function import_Juliet_H5(m, filename)

CountRate = h5read(filename, '/CountRate');
h = h5read(filename, '/CountRate_headers');

m.count = double(CountRate.count);
m.period = double(CountRate.period(1)) * 1e-9;
m.t = convertTimestamp(h.timestamp) + m.period/2.;
m.exp_id = h.experiment_id(1);

%%
cri = h5read(filename, '/Cri');
h = h5read(filename, '/Cri_headers');
m.cri = double(cri.count);
m.cri_onset_ps = double(cri.utime_from_ps(1));
m.cri_until_ps = double(cri.utime_until_ps(1));
m.cri_param.t = convertTimestamp(h.timestamp) + m.period/2.;
m.cri_param.exp_id = h.experiment_id;

%%
dtof = h5read(filename, '/Dtof');
h = h5read(filename, '/Dtof_headers');

m.dtof = dtof.counts;
m.dtof_param.dtof_min = dtof.range_min(1); % same over one experiment 
m.dtof_param.dtof_max = dtof.range_max(1); % same over one experiment
m.dtof_param.resolution = dtof.resolution(1); % ps
m.dtof_param.t = convertTimestamp(h.timestamp) + m.period/2.;
m.dtof_param.exp_id = h.experiment_id(1);

p = m.dtof_param;
m.tau = double(p.dtof_min:p.resolution:p.dtof_max) * 1e-3; % ns 

end

function time_in_sec = convertTimestamp(timestamp)

timestamp = timestamp - timestamp(1); % ns precision
time_in_sec = double(timestamp) * 1e-9; % sec

end