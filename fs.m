function fs(varargin)
% My figure style

grid on;
xlabel('second'); ylabel('Voltage (mV)');
ax = gca; Fontsize = 18;
ax.XAxis.FontSize = Fontsize;
ax.YAxis.FontSize = Fontsize;

% title('KCl application', 'FontSize', 20, 'FontName', 'Helvetica');

end
