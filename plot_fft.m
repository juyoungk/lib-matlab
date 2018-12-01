function plot_fft(x)
% fft power spectrum of raw trace

    x = x - mean(x);

    y = fft(x);
    yshift = fftshift(y);

    n = length(x);
    power = abs(yshift).^2/n;

    fs = 1; % norm frequency
    
    fshift = (-n/2:n/2-1)*(fs/n);

    plot(fshift, power);

    xlim([0 fs/2.]);
    xlabel('Hz (norm.)');
    ylabel('FFT Power');
    ax = gca;
    Fontsize = 18;
    ax.XAxis.FontSize = Fontsize;
    ax.YAxis.FontSize = Fontsize;
    
end