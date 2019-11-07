%%
%N = [1, 10, 1E2, 1E3, 1E4, 1E5, 1E6, 1E7];
N = logspace(0, 7, 50);

%%
shotnoise = sqrt(N);
signal_contrast = 0.01;
signal = signal_contrast * N;
snr_shotnoise = signal ./ shotnoise;

%%
figure;
loglog(N, snr_shotnoise, 'o-'); 
grid on;
title('shot noise SNR to 1% contrast');
xlabel('Photon number');
ylabel('SNR');
ff;

%% Nonlinear factor for contrast vs photon N
laser = [
0.002
0.005
0.01
0.02
0.04
0.08
0.12
0.16
0.2
0.3
0.4
0.5
0.6
0.7
0.8
1
1.48
2.04
3
4.05
6];
spad_fr = [
1.90E+04
3.60E+04
7.90E+04
1.50E+05
2.90E+05
5.70E+05
8.40E+05
1.08E+06
1.34E+06
1.90E+06
2.40E+06
2.83E+06
3.23E+06
3.59E+06
3.83E+06
4.38E+06
5.33E+06
5.90E+06
6.40E+06
6.61E+06
6.59E+06];
%%
figure;
plot(laser, spad_fr, 'o-'); 
grid on
title('SPAD (free-running)');
ylabel('Count rate');
xlabel('Light input [a.u.]');
ff;
% linear fit
id = 2:5;
p = polyfit(laser(id), spad_fr(id), 1);
% fit line: larger range than the fit data 
x = laser;
l = polyval(p, x);
% plot
ax = gca;
bk_ylim = ax.YLim;
hold on;
plot(x, l);
ax.YLim = bk_ylim;
hold off;

%% slope contrast relative to linear fit
%
d_laser = laser(2:end)-laser(1:end-1);
m_laser = 0.5*(laser(1:end-1) + laser(2:end));
slope = (spad_fr(2:end) - spad_fr(1:end-1))./d_laser;

figure;
plot(m_laser, slope, 'o-');
grid on
title('Sensitivity: SPAD (free-running)');
ylabel('slope');
xlabel('Light input [a.u.]');
ff;
legend
%% fit
% poly fit
p = polyfit(m_laser, slope, 7);
% exp fit
f = fit(m_laser, slope, 'exp1');
x = linspace(0, m_laser(end), 100);
l = polyval(p, x);

hold on
%plot(x, l);
plot(f)
ylabel('slope');
xlabel('Light input [a.u.]');
hold off

%% slope contrast 
slope_contrast = f(x)/f(0);

% count rate at x
cr = interp1(laser, spad_fr, x, 'PCHIP');

%
figure;
plot(cr, slope_contrast, 'o');
ylabel('Slope contrast');
xlabel('Count rate');
title('');
grid on
ff;

% resample at N
slope_contrast = interp1(cr, slope_contrast, N, 'linear');
hold on
plot(N, slope_contrast, '-');
hold off

%% combined plot
figure;

loglog(N, snr_shotnoise, '-'); 

hold on;
loglog(N, snr_shotnoise .* slope_contrast, 'o-');  

grid on;
title('Shot noise SNR to 1% contrast signal x SPAD nonlinearity');
xlabel('Photon number');
ylabel('SNR');
ff;

hold off





