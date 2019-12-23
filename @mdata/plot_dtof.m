function plot_dtof(m, ch)

if nargin < 2
    ch = m.header.channels;
end

if numel(ch) > 1
    figure;
    
    numplots = numel(ch);
    
    for c = 1:numplots
        subplot(1, numplots, c); 
        m.plot_dtof(c);
    end
else
    % single channel plot
    
    dtof = m.dtof(:,:,ch);
    
    % substract baseline (ASE)
        % peak location
   
    semilogy(m.tau, dtof);
    xlabel('ns');
    ylabel('counts');
    grid on

    ff(0.8);
    
    %
    %yyaxis right
    
    
end











end