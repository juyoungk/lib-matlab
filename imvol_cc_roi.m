function imvol_cc_roi(y, cc, times)
% imvol for cc-(roi bw mask)-based analysis.
% ROI-averaged time-varying signal (or stack)
% inspection tool. ROI scan by arrow keys.
%
% subplot 1 - ROI-averged whole trace (exp 1, 2 or n)
% subplot 2 - ROI or computed filter
% subplot 3 - exp 1: (events-aligned or averaged) time-varying profile
% subplot 4 - exp 2: (events-aligned or averaged) time-varying profile
%          ...
% input: 
%        data (structure): time-varying siganl y or 
%                          ex struct 'g':
%                                       g.exp1,
%                                       g.exp2 {stim1, stim2, ..}
%                                       g.exp3,
%                                       ...
%        cc: roi structure (conn bwmask)
%
%        times: times for aligning or averging {stim1, stim2}
%        ex_str: name string for experiment.

% figure 
h = figure;

% save inputs to gcf UserData 
h.UserData.cc = cc;
h.UserData.ex_str = ex_str; % fieldname of the exp struct 'g'

% current roi id
h.UserData.i = 1;

% stim (or ex) numbers for given roi
n_totStim = 0;

% 'g' struct interpretation
if isstruct(y)
    g = y;
    
    ex_list = fieldnames(g);
    if isempty(ex_list)
        error('No exp list in ''g''');
    end
    n_ex = numel(exp_list);
    
    % total stimulus numbers (~ # of subplots)
    for i = 1:n_ex 
        % # of data files in struct 'g'
        nStim = g.(ex_list{i}).stimulus.numStimulus;
        n_totStim = n_totStim + nStim;  
    end 
else
    % y is a single trace
    y_list = {y};
    n_totStim = 1;
end



% 
% 1. raw traces with events 



% When exp struct 'g' exists in workspace: Create pop-up
if exist('g','var') == 1
    
    ex_list = fieldnames(g);
    if isempty(ex_list)
        ex_list = 'No exp list in ''g''';
    end
    
    % create pop-up menu
    popup = uicontrol('Style', 'popup',...
           'String', ex_list,...
           'Position', [20 340 100 50],...
           'Callback', @setmap);   
else
    disp('no exp struct ''g'' in workspace');
end

% callback of pop-up menu

% draw function 







end