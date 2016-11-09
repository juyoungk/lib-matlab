function a_spikes = align_sorted_cells(s, ev_secs, i_file, srate)
%
% get the list of cells and align the spikes of i-th file.
% struct s should contain a field 'times'

if nargin < 4
    srate = 10000;
end

if nargin < 3
    i_file = 1;
end

num_cells = numel(s);

% align timestampes
a_spikes = cell(1, num_cells);
for i = 1:num_cells
    a_spikes{i} = align_to_event(s(i).times{i_file}/srate, ev_secs);
end


end