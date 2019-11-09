function plot_count_gated(m, ti, window_size)

if nargin < 3 
    window_size = 1; %ns
end

count = m.gate(ti, window_size);

plot(m.t, count);

ylabel('Gated counts');
xlabel('sec');

ff;


end