function plot_scatter(r, dim)
% Scatter plot in PCA space and more statistics plots

if nargin <2 
    dim = 4;
end

% if nargin <2
%     c_list = unique(r.c(r.c~=0));
% end

% ROIs for PCA basis
I = 1:r.numRoi;

if max(r.c) == 0
   idx = ones(1, r.numRoi); % cluster id: all same as 1
else
%    I = idx(r.c~=0); % clustered ROI only
%    idx = r.c(r.c~=0);
   idx = r.c;
end

% 
% % traces
% X = r.avg_trace_smooth_norm(:,I);
% X = normc(X);
% X_col_times = X.'; % times as variables
% 
% 
% % PCA analysis
% [coeff, score, latent, ts, explained] = pca(X_col_times);
% %score = r.avg_pca_score(r.c~=0, :);
% % 
% X = r.avg_trace_smooth_norm(:,I);
% score = X.' * coeff;
% 

%
r.pca;
score = r.avg_pca_score(I, :);

% scatter plot in PCA space
mycluscatter(score(:, 1:dim), 'Cluster', idx);

% scatter plot for stat.
s = zeros(length(I), 5);
s_label ={  'mean fluorescence',...
            'dF/F amplitude [%]',...
            'std of norm responses (avg)',...
            '',...
            ''};
        
s(:, 1) = r.stat.mean_f(I);
s(:, 2) = r.stat.smoothed_norm.avg_amp(I);
s(:, 3) = r.stat.smoothed_norm.trace_std_avg_normc(I);

%
mycluscatter(s(:, 1:3), 'Cluster', idx, 'Label', s_label);

% Any cluster bias in expression level or responsiveness (~spiking)
% mean_f :: amplitude :: std of repeats ??

end