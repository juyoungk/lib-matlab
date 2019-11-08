function plot_dtof(m)

p = m.dtof_param;

%numbins = size(m.dtof, 1);
%tau = (p.dtof_min:p.resolution:p.dtof_max) * 1e-3; % ns 

plot(m.tau, m.dtof);
xlabel('ns');
ylabel('counts');

ff;




end