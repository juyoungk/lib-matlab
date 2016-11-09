function a_spikes = after_sorting(g, pd, i_file)
% get the list of cells and align the spikes of i-th file.
% event : PD cross 70 % of maxmum.

if nargin < 3
    i_file = 1
end

srate = 10000;

% event timeedges
min_ev_interval_secs = 0.5;
ev_idx = th_crossing(pd, 0.7, min_ev_interval_secs*srate);

% cell list
s = list_sorted_cells(g);
num_cells = numel(s);

% align timestampes
a_spikes = cell(1, num_cells);
for i = 1:num_cells
    a_spikes{i} = align_to_event(s(i).times{i_file}/srate, ev_idx/srate);
end


end