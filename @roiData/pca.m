function [coeff, score] = pca(r, I)    
% compute PCA basis for all (or clustered) roi traces (w/o normalization), then
% compute PCA scores for all 'normalized' avg traces.

    % all ROI traces
    if nargin < 2
        I = 1:r.numRoi;
    end
    
    % you can use only clustered traces for PCA basis compuataion.        
%     if max(r.c) > 0
%         I = I(r.c~=0);
%     end


    % At least 2 data points are needed for PCA analysis.
    if numel(I) < 2
        disp('PCA scores will be empty vectors because only one data is clustered.');
    end
    
    if r.avg_FLAG

        X = r.avg_trace_smooth_norm(:,I);
        %X = normc(X); 
        X_col_times = X.'; % times as variables

        % compute new PCA basis (coeff)
        % n traces -> (n-1) col vectors for coeff. 
        [coeff, score, latent, ts, explained] = pca(X_col_times);

        % compute scores for all ROIs (column normalized)
        X = r.avg_trace_smooth_norm;
        X = normc(X);
        
        score = X.' * coeff;
        %
        r.avg_pca_score = score;
    else
        disp('PCA score will be computed for avg traces (avg_FLAG on). ');
    end
    
end
            