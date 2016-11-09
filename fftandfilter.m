function [x_filtered, init_id] = fftandfilter(x)

% 10K sampling. Norm freq 1 = 5K (Hz). 1e-4 = 0.5 Hz
% 10K sampling. Norm freq 1 = 5K (Hz). 0.2 = 1K Hz
% x = cos(2*pi*1*[0:0.0001:300]);
figure_id = 11; %close figure_id;
id1 = 100;
id2 = 10000;
init_id = id1 + id2;
%plot magnitude spectrum of the signal
X_mags = abs(fft(x));
%plot first half of DFT (normalised frequency)
num_bins = length(X_mags);
NormFreqRange = 0:1/(num_bins/2 -1):1;
figure(figure_id)
plot([NormFreqRange], X_mags(1:num_bins/2))
xlabel('Normalised frequency (\pi rads/sample)')
ylabel('Magnitude')

% filter parameters
[b2 a2] = butter(17, 0.24, 'low');   % 1.2K Passband
[b3 a3] = butter(4, 0.0004, 'high');
[b4 a4] = butter(4, 0.0004, 'low');
% Lowpass filter
H2 = freqz(b2,a2, floor(num_bins/2));
%plotyy(NormFreqRange, X_mags(1:num_bins/2), NormFreqRange, abs(H2));
% Highpass filter
H3 = freqz(b3,a3, floor(num_bins/2));
% Plot the magnitude spectrum and compare with lower order filter
%figure; plot(NormFreqRange, abs(H3)); set(gca,'xscale','log'); set(gca,'fontsize',20)
%
x_lowpassed = filter(b2,a2,x); 
figure;
plot(x_lowpassed(init_id:end));
title(['Lowpass filtered Signal '])
% 100 points (~ 10 ms data) should be omitted.

% Highpass filter
x_filtered = filter(b3,a3,x_lowpassed(id1:end)); 
hold on;
plot(x_filtered(id2+1:end));
title(['Low and high pass filtered Signal '])
xlabel('Samples');
ylabel('Amplitude')
x_filtered = x_filtered(id2+1:end);
end