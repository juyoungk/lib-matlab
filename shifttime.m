function spikes = shifttime(spikes, id_events, t_shift)
% input
%       spikes - (1xN) cell array. Each cell contains many lines of spikes
%       as a cell array.
%       id_events - an array of id (or line) numbers which you want to
%       shift timestamps.

if isempty(id_events)
    disp('No events to shift time');
    return;
end

num_cell = numel(spikes);
num_ev = length(id_events);
    
for i = 1:num_cell
    for k = 1:num_ev
        spikes{i}{id_events(k)} = spikes{i}{id_events(k)} + t_shift(k); 
    end
end

end