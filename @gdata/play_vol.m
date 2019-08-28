function play_vol(g)

% smooth if the smoothing was not performed.
if isempty(g.vol_smoothed)
    g.smoothVolOverTime;
end

imvol(g.vol_smoothed, 'title', [g.ex_name, ' - smoothed vol'], 't_step', g.ifi);

end