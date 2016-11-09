function mysmoothing(x, para, varargin)
% smooth(pd, 7, 'moving') gives good smoothing

close all; 
figure('position', [10,540,1900,420]);

yyaxis left;
plot(x); hold on; 

yyaxis right; 
%plot(smoothts(x, 'b', para)); hold off;
plot(smooth(x, para, 'moving')); hold off;

end