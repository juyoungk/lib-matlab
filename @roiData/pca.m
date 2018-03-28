function [coeff, score] = pca(r, I)    
    % compute PCA basis for seleted group of cells (or ROIs), then
    % compute PCA scores for all avg traces.
    if nargin < 2
        I = 1:r.numRoi;    
    end
    
    if r.avg_FLAG

        X = r.avg_trace_smooth_norm(:,I);
        %X = normc(X);
        X_col_times = X.'; % times as variables

        % compute new PCA scores 
        [coeff, score, latent, ts, explained] = pca(X_col_times);

        % compute scores for all ROIs (column normalized)
        X = normc(r.avg_trace_smooth_norm);
        score = X.' * coeff;
        %
        r.avg_pca_score = score;
        
    end
    
end
            