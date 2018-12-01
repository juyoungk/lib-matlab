function [avg_trace, s] = stat_over_repeats(trace)
% Avg trace. Statistics of noisy responses (Std). Pattern Reliability.   
%
% input - 3D matrix [n_samples, n_cells, n_repeats]
%
% output - s.avg_mean         : Mean of avg response over time ~ Trend center or mean fluorecence level  
%          s.avg_amp          : Amplitude (responsivity) of avg traces
%          s.trace_std_avg        : Fluctuation level?   Std of repeated trace along the 3rd dimension (only for noiser half of total)
%          s.trace_normc_std_avg  : Pattern reliability? After col norm, std of repeated traces. Averaged over time points. 
%
% Fluctuaion level (of measurement) - Fluctuaion level over the noiser half of the
% traces with a hope that fluctuaion by drifiting of obj lens or tissue
% might be excluded, which can be a huge factor for fluctuation. 

    [n_samples, n_cells, n_repeats] = size(trace);

    % avg trace
    avg_trace = mean(trace, 3);
    % var
    noise = trace - avg_trace; % fluctuation from mean
    var_noise = var(noise, 0, 3); % W=0 means default normalization (N-1). Along dim 3.

    % stat of avg trace
    s.avg_mean = mean(squeeze(avg_trace), 1);
    s.avg_amp = max(squeeze(avg_trace), [], 1) - min(squeeze(avg_trace), [], 1);
    s.avg_var = mean(var_noise, 1);
    s.var = var_noise;
    
    % sort repeated traces by max-min (amplitude) differnece
    % max-min of each repeat of each ROI
    M = max(trace, [], 1);
    m = min(trace, [], 1);
    d = M-m;

    s.trace_std_avg = zeros(1, n_cells);
    % Fluctuation (noise) level of each cell (or ROI) over repeats
    % Drifting of obj or tissue would cause large amp change over
    % repeats. One would like to isolate noise fluctuation of detection
    % , possibly by laser intensity or PMT gain fluctuation or 
    % fluorescnce reporter diffusion/bleaching and ultimately
    % by photon shot noise.
    
    for k=1:n_cells
        % sort repeat id by the response strength (max-min)
        strength = d(1, k, :);
        strength = squeeze(strength);
        [~, id] = sort(strength);

        % Sample 'noiser half' of responses.
        n_th = round(n_repeats/2);
        sampled = trace(:,k,id(1:n_th));
        sampled = squeeze(sampled);

        % data centering
        sampled = sampled - mean(sampled, 1);

        % std along repeats
        trace_std = std(sampled, 1, 2);
        s.trace_std_avg(k) = mean(trace_std, 1); % over time
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
    s.trace_normc_std     = std(trace_col_norm, 1, 3);   % 2-D for each time point of a single roi. 
    s.trace_normc_std_avg = mean(s.trace_normc_std, 1);  % avg std of each (roi) trace over multiple repeats.
    %s.trace_normc = trace_col_norm;
    
end