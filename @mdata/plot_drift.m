function plot_drift(m, ch, laser_ch)

if nargin < 3
    laser_ch = m.numch; % last channel
end

if nargin < 2
    ch = 1;
end

figure;
t = m.t;
semilogy(t, m.dtof_tot(:, ch));
hold on
semilogy(t, m.dtof_tot(:, end)); % laser channel
yyaxis right
semilogy(t, m.dtof_stat.tof_mean(:,ch));
ff    
grid on    
    
end

