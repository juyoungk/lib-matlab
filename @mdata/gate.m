function count_gated = gate(m, ti, window_size)
% gate the counts over a certain time window in DTOF
% window_size in nano-second unit.

if nargin < 3
    window_size = 1; %ns
end

% struct input
if isstruct(ti) 
    s = ti;
    if isfield(s, 'ti')
        ti = s.ti;
    end
    if isfield(s, 'tf') 
        tf = s.tf;
        window_size = tf - ti;
    else
        error('no field ''tf''');
    end
end

% array input
if length(ti) == 2
    interval = ti;
    ti = interval(1);
    tf = interval(2);
    window_size = tf - ti;
end
    


i = find(m.tau > ti, 1);
numBins = window_size * 1000 / m.dtof_param.resolution;
fprintf('numBins for time gating : %d\n', numBins);

dtof_gated  = m.dtof(i:i+numBins-1, :, :);
count_gated = sum(dtof_gated, 1);
count_gated = squeeze(count_gated); % timestamps x ch

end