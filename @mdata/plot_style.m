function plot_style(m, str)

if nargin < 2
    str = 'dtof';
end


switch str
    case 'dtof'
        xlabel('ns');
        ylabel('counts');
        grid on
        ff(0.8);

    otherwise
        
end


end