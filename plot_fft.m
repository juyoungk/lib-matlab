function plot_fft(x, sampling_freq)
% fft power spectrum of raw trace
    
    if nargin < 2
        sampling_freq = 1;
    end

    %x = x - mean(x);

    y = fft(x);
    yshift = fftshift(y);

    n = length(x);
    power = abs(yshift).^2/n;
    
    %power = log10(power);

    fs = sampling_freq; % norm frequency
    
    fshift = (-n/2:n/2-1)*(fs/n);

    plot(fshift, power, '-o');

    xlim([0 fs/2.]);
    xlabel('Hz (norm.)');
    ylabel('FFT Power');
    ax = gca;
    Fontsize = 18;
    ax.XAxis.FontSize = Fontsize;
    ax.YAxis.FontSize = Fontsize;
    
    ff;
    
end