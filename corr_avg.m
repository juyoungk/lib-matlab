function r_avg = corr_avg(y)
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
            
            % correlation to mean 0314 2019
%             m = mean(y, 2);
%             y = [y m]; % mean vector as last column
%             R = corrcoef(y);
%             % Correlation of individual col vector to mean vector (last),
%             % then mean over correalations.
%             r_avg = mean(R(:,end));

            % Correlation between all possible pairs.
            A = corrcoef(y);
            A = (A-eye(n_trace));
            r_avg = sum(A(:))/( n_trace*(n_trace-1));
            
        elseif n == 3
            
            [ n_variables, n_cells, n_repeats ] = size(y);
            
%             if FIRST_EXCLUDE && n_repeats > 1
%                 y = y(:,:,2:end);
%                 n_repeats = n_repeats - 1;
%             end
%             
            r_avg = zeros(1, n_cells);
            
            for i=1:n_cells
                
                yy = reshape( y(:,i,:), n_variables, n_repeats);
                r_avg(i) = corr_avg(yy);
                
            end
            
        else

            disp('[corr_avg] Input Dim seems not correct. No output.');
            
        end

end