    function [mean_trace, s] = stat_over_repeats(trace)
    % Avg trace. Scaling by its max. Statistics (Std)   
    %
    % input - 3D matrix [n_samples, n_cells, n_repeats]
    %
    % How reliablely is the response pattern over multiple repeats?    
    % Amplitude might be changing over time even though the cell is
    % well responding due to tissue or objective drift. 

        [n_samples, n_cells, n_repeats] = size(trace);

        % avg trace
        mean_trace = mean(trace, 3);

        % Scale individual traces by its max(abs): Extract Pattern
        trace_col_norm = zeros(n_samples, n_cells, n_repeats);
        
        for k = 1:n_repeats
            trace_col_norm(:,:,k) = normc(trace(:,:,k));
        end    
        
%         s_factor = max(abs(trace), [], 1);
%         s_factor = repmat(s_factor, n_samples, 1, 1);
%         trace_col_norm = trace./s_factor;
        % 
        s.std_scaled     = std(trace_col_norm, 1, 3); %2-D for each time point of a single roi. 
        s.std_scaled_avg = mean(s.std_scaled, 1);   % avg std of each (roi) trace over multiple repeats.
        s.trace_scaled = trace_col_norm;
    end