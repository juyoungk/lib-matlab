function pplot(x, y1, y2)
    % h is a handle, a return object of plot.
    % For example, h = plot(x1,y1,x2,y2);
    
    %figure;
    h = plot(x, y1, '*-' x, y2, 'o-');
    set(h(1),'linewidth',2);
    set(h(2),'linewidth',2);
    
end
