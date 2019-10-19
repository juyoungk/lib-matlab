function [freq, power] = plot_fft(x, sampling_freq)
% fft power spectrum of raw trace
% You might want to substract mean first.
    
    if nargin < 2
        sampling_freq = 1;
        str_xlabel = 'Hz (norm.)';
    else
        str_xlabel = 'Hz';
    end

    %x = x - mean(x);

    y = fft(x);
    yshift = fftshift(y);

    n = length(x);
    power = abs(yshift).^2/n;

    fs = sampling_freq; % norm frequency
    
    freq = (-n/2:n/2-1)*(fs/n);

    %plot(fshift, power, '-o'); ylabel('FFT Power');
    semilogy(freq, power, '-o'); ylabel('FFT Power (log)');
    
    xlim([0 fs/2.]);
    xlabel(str_xlabel);
    
    ax = gca;
    Fontsize = 18;
    ax.XAxis.FontSize = Fontsize;
    ax.YAxis.FontSize = Fontsize;
    
    ax.YLim(1) = min(power(freq>0)) * 0.5;
    % min except freq zero power 
    % when mean subtraced and log plot, it would be very low in log unit.
    
    ff;
    
end