    function [trace_mean, s] = stat_over_repeats(trace)
    % Avg trace. Scaling by its max. Statistics of noisy responses (Std)   
    %
    % input - 3D matrix [n_samples, n_cells, n_repeats]
    %
    % How reliablely is the response pattern over multiple repeats?    
    % Amplitude might be changing over time even though the cell is
    % well responding due to tissue or objective drift. 

        [n_samples, n_cells, n_repeats] = size(trace);

        % avg trace
        trace_mean = mean(trace, 3);
        
        s.trace_mean_level = mean(squeeze(trace_mean), 1);
        
        % sort by max-min differnece
        % max-min of each trace
        M = max(trace, [], 1);
        m = min(trace, [], 1);
        d = M-m;
        
        s.trace_std_avg = zeros(1, n_cells);
        
        for k=1:n_cells
            % sort repeat id by the response strength
            strength = d(1, k, :);
            strength = squeeze(strength);
            [~, id] = sort(strength);
             
            % sample noiser responses
            n_th = round(n_repeats/3);
            sampled = trace(:,k,id(1:n_th));
            sampled = squeeze(sampled);
            
            % std along repeats
            trace_std = std(sampled, 1, 2);
            s.trace_std_avg(k) = mean(trace_std, 1);   
        end

        % Scale individual traces by normc for each repeat
        % no unit.
        trace_col_norm = zeros(n_samples, n_cells, n_repeats);
        
        for k = 1:n_repeats
            trace_col_norm(:,:,k) = normc(trace(:,:,k));
        end
        
%         s_factor = max(abs(trace), [], 1);
%         s_factor = repmat(s_factor, n_samples, 1, 1);
%         trace_col_norm = trace./s_factor;

        
        %s.trace_std_avg = mean(trace_std, 1);
        s.trace_std_normc     = std(trace_col_norm, 1, 3); %2-D for each time point of a single roi. 
        s.trace_std_avg_normc = mean(s.trace_std_normc, 1);   % avg std of each (roi) trace over multiple repeats.
        %s.trace_normc = trace_col_norm;
    end