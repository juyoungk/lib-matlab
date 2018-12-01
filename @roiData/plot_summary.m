function hp = plot_summary(r, id)
% 
% Input:
%       
%       id - array of ROI id numbers. can be logical. 
%
% Output:
%       hp - handle of uipanel container of single cell's summary

if nargin <2
    id = 1:r.numRoi;
end

if islogical(id)
    if numel(id) ~= r.numRoi
        disp('logical array should have same length as number of ROIs.');
        return;
    end
    a = 1:r.numRoi;
    id = a(id);
end
    
N = numel(id);

if N > 1
    % multi cell plot
    
    num_col = 1;
    num_row = ceil(N/num_col);
    
    hf_main = figure('Name', 'Summary');
    hf_main.Position(1) = 250;
    hf_main.Position(2) = 250;
    hf_main.Position(3) = 700*num_col;
    hf_main.Position(4) = 150*num_row;
    
    for i = 1:N
        
        id_cell = id(i);
        
        hp = r.plot_summary(id_cell);
        
        hf_single = hp.Parent; % save the original figure handle for delete.
        
        % copy uipanel to main figure? Takes very long time.
        %hp_sub = copyobj(hp, hf_main);
        
        % simply reparent! 
        hp_sub = hp;
        hp_sub.Parent = hf_main;
        
        % delete previous figure?
        close(hf_single);
        
        % adjust Position of each uipanel.
        [I, J] = ind2sub([num_row, num_col], i);
        % J goes to x, I goes to y.
        set(hp_sub, 'Position', [(J-1)/num_col, (num_row-I)/num_row, 1/num_col, 1/num_row]); 
        
%         if mod(i, num_col) ~= 1
%             ylabel('');
%         end
    end
    
    
else
    % Plots for Single cell : uipanel.
    % Output is uipanel object.
    
    % Creat an uipanel in invisible figure
    hf = figure('Visible', 'off');
    hp = uipanel('Parent', hf, 'Position', [0 0 1 1]);
    
    % create axes directly or indireectly using subplot.
    
    % Summary:
    % ROI - histogram - Rf or avg response 
    
    % ROI snapshot
    %subplot(1, 2, 1, 'Parent', hp);
    
    % histogram
    subplot(1, 2, 1, 'Parent', hp);
    %r.plot_hist(id);
    r.plot_hist_normed(id);
    
    % Representative response
    subplot(1, 2, 2, 'Parent', hp);
    r.plot_avg(id);
    
end


end