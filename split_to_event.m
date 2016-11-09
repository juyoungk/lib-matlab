function spikes_session = split_to_event(spikes, ev)
%
% spikes_session = split_to_event(spikes, ev)
%
% Input:
%   spikes - N X 1 cell array. Each cell contains an array of time stamps.
%   ev     - time stamps of events.
% 
% Output: 
%   spikes_session - { {N X 1}, {N X 1}, .. ,{N X 1} } divided by the
%   events.
%
% s{i} will give you the array of spikes in i-th session.
%
% 2016 1103 Juyoung Kim 

if nargin < 2
    numframes_session = 75;
    ifi = 0.01176470588;
    n_session = 8;
    duration = numframes_session * ifi;
    ev = 0:duration:duration*(n_session-1);
end

if ~iscell(spikes)
    error('spikes should be a cell or an array of cells');
end

%
n_session = numel(ev);
n_repeat = numel(spikes);

% initialize
spikes_session = cell(1, n_session);
for j = 1:n_session
    spikes_session{j} = cell(n_repeat, 1);
end

% 
for i = 1:n_repeat
    spikes_divided = align_to_event(spikes{i}, ev);
    
    % stampes_divided = [ ], [ ], [ ], .. , [ ]
    for j = 1:n_session
        spikes_session{j}(i) = spikes_divided(j);
    end
end
        

end