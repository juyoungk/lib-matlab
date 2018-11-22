function [coeff, score, latent, ts, explained] = pca(r, I)    
% compute PCA basis for selected set of traces (w/o normalization ?), then
% compute PCA scores for all 'normalized' avg traces.

    % all ROI traces
    if nargin < 2
        I = find(r.p_corr.smoothed_norm > 0.1);
    end
    
    % At least 2 data points are needed for PCA analysis.
    if numel(I) < 2
        disp('PCA scores will be empty vectors because only one data is clustered.');
    end
    
    if r.avg_FLAG

        X = r.avg_trace_smooth_norm(:,I);
        
        % normalization
        X = normc(X);
        disp('PCA basis is computed for normalized traces.');
        
        
        X_col_times = X.'; % times as variables

        % compute new PCA basis (coeff)
        % n traces -> (n-1) col vectors for coeff. 
        [coeff, score, latent, ts, explained] = pca(X_col_times);

        % compute scores for ALL ROIs (column normalized)
        X = r.avg_trace_smooth_norm;
        X = normc(X);
        disp('The computed PCA score are scores for their normalized traces.');
        score = X.' * coeff;
        
        %
        r.avg_pca_score = score;
    else
        disp('PCA score will be computed only for avg traces (avg_FLAG on). ');
    end
    
end
            