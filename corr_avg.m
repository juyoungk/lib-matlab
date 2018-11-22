function p_corr = corr_avg(y)
% P correlation coefficient between col vectors in y. Average it. 
% inputs:
%       if y is 2-D, y is ( random variable or time(row) x observation(col)
%       ) matrix
%       if y is 3-D, y is ( random variable or time(row) x ROI or
%       cells(col) x repeats ) matrix. Correlation between 3 dims (repeats).
        
        n = ndims(y);

        if n > 3
            
            disp('[corr_avg] Dims should be 2-D or 3-D. You may need to reshape the input.');
            
        elseif n <= 2
            
            [~, n_trace] = size(y);
            A = corrcoef(y);
            A = (A-eye(n_trace));
            p_corr = sum(A(:))/( n_trace*(n_trace-1));
            
        elseif n == 3
            
            [ n_signal, n_cells, n_repeats ] = size(y);
            p_corr = zeros(1, n_cells);
            
            for i=1:n_cells
                
                yy = reshape( y(:,i,:), n_signal, n_repeats);
                p_corr(i) = corr_avg(yy);
                
            end
            
        else
            
            disp('[corr_avg] Input Dim seems not correct. No output.');
            
        end

end