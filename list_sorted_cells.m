function s = list_sorted_cells(g)

    files = g.ctfiles;
    num_files = numel(files);

    ch_idx = find(~cellfun(@isempty, g.chanclust));

    num_cells_per_ch = cellfun(@numel, g.chanclust) / num_files;
    num_cells = sum(num_cells_per_ch);

    s = struct('files', {files}, 'N_sorted_cells', num_cells, 'CHs', ch_idx, 'times', cell(1, num_cells), 'ch', cell(1, num_cells));
    
    % cell 1 's spikes timestamps.
    %     s.files = ['..' , '..', .. ] 
    %     s(1).times   % timestamp of spikes for the cell
    %     s(1).ch = 32 
    % s(1) : 1st cell
    % s(2) : 2nd cell

    cell_idx = 1;

    for i = ch_idx
        for c = 1:num_cells_per_ch(i)
  
            s(cell_idx).times = g.chanclust{i}(c, :); % : means all files
            s(cell_idx).ch   = i;
            cell_idx = cell_idx + 1;
        end
    end

end