function idx_ev = th_crossing(data, threshold, min_interval)
%%
% returns the "indexes" of the data whenever it crosses the threshold
% 2 conditions:
%       (a) previous 2 points are less than threshold
%       (b) previous event is away from the crossing event at least by
%       min_interval (3rd argument)
%
% display: hold on; plot(idx,data(idx),'bo');

if nargin < 3
    min_interval = 2;
end

%% All points which crossed the threshold.
idx = find(data>threshold); % index array. timestamps.
idx = idx(idx>3);           % excludes the first two elements.

if isempty(idx)
    idx_ev = idx;
    return;
end

%% 1. is it rising?
% condition? previous 2 points should be less than threshold
% access 'data' using idx
rise1 = data(idx-1) < threshold; % rise1 is index array. length(rise1) = length(idx) 
rise2 = data(idx-2) < threshold; 
rise = rise1 & rise2;

%% pick ids of events every after min_interval
% index (timestamps) of the events which go across the threshold
idx = idx(rise);

% Goal: make a final logical array. idx_ev = find(id_final);
    ev_logical = zeros(1, length(data)); % initialize the logical array [ 0 0 .. 0 ]
after_interval = idx;
    
        while ~isempty(after_interval)
 
            lastevent = after_interval(1); % 1st data id (or ts) after interval
            ev_logical(lastevent) = 1;
            % index (or timestamps) after min_interval 
            after_interval = idx( (idx - lastevent) > min_interval );
        end
 
% Find non-zero index (location) of the data timestamp (or id) array
idx_ev = find(ev_logical); 

end
