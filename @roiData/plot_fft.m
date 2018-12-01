function plot_fft(r, id)
% fft power spectrum of raw trace

if nargin <2
    id = 1:r.numRoi;
end

    x = r.roi_trace(:, id); % signal
    x = x - mean(x);

    y = fft(x);
    yshift = fftshift(y);

    n = length(x);
    power = abs(yshift).^2/n;

    fs = 1; % norm frequency
    fs = 1./r.ifi;
    
    fshift = (-n/2:n/2-1)*(fs/n);

    plot(fshift, power);

    xlim([0 fs/2.]);
    xlabel('Hz');
    ylabel('FFT Power');
    ax = gca;
    Fontsize = 18;
    ax.XAxis.FontSize = Fontsize;
    ax.YAxis.FontSize = Fontsize;
    
end