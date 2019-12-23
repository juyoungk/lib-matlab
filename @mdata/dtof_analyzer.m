function dtof_analyzer(m)
% peak find
% dtof mean histogram over time
% dtof max count number
% more statistics in dtof_stat_compute

if ndims(m.dtof) == 3
    [numBin, numExp, numCh] = size(m.dtof);
else
    fprintf('ndim of the DTOF is %d\n', ndims(m.dtof));
    numCh = 0;
    fprintf('numch was initialized as %d\n', numCh);
end
m.numch = numCh;


m.dtof = double(m.dtof);

% Peak finder? simply max
[m.dtof_max, I] = max(m.dtof, [], 1);
m.dtof_mean = mean(m.dtof, 2);
m.dtof_tot = sum(m.dtof, 1);

if numCh > 1
    m.dtof_mean = squeeze(m.dtof_mean);
    m.dtof_max = squeeze(m.dtof_max);
    m.dtof_tot = squeeze(m.dtof_tot);
end

% dtof stat

end


