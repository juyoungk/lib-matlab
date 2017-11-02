function [A, times, header] = load_analogscan_WaveSufer_h5(h5_filename)
% Input  - loaded h5 recorded in WaveSurfer [output of ws.loadDataFile(filenames)]
% Output - 
%    i) if there is only one sweep, 2-D matrix [Sampling points -by- n]. 
%           'n' is number of analog channels (e.g. voltage, current, and photodiode) 
%   ii) More than 2 sweeps? Cell array. 
%
%      times - samples times

h5_data = ws.loadDataFile(h5_filename);

% Contents of h5
% - header
% - sweep_001
% - sweep_002
% - ...
% - times

field_names = fieldnames(h5_data);

% hedaer 
header = h5_data.header; 
        %fprintf("           header.SweepDuration: %.2f (s)\n", header.SweepDuration);
        %fprintf("    header.Acquisition.Duration: %.2f (s)\n", header.Acquisition.Duration);

% struct field names for sweeps only
is_sweep = contains(field_names, 'sweep');
fields_for_sweeps = field_names(is_sweep); % cell array
n_sweep = numel(fields_for_sweeps);


% get the data
if n_sweep > 1
    A = cell(n_sweep, 1);
    
    for i = 1:n_sweep
        A{i} = getfield(h5_data, fields_for_sweeps{i}, 'analogScans');
    end
    [n_sampling, n_ch] = size(A{1});
    
elseif n_sweep == 1
    A = getfield(h5_data, fields_for_sweeps{1}, 'analogScans');
    [n_sampling, n_ch] = size(A);
else 
    error('No analoscans data in WaveSurfer h5 file');
end

r_sampling = header.Acquisition.SampleRate;
times = (1:n_sampling)*(1/r_sampling);
header.n_sweep = n_sweep;

end