function plot_scatter(r, dim)
% default: PCA space

if nargin <2 
    dim = 4;
end

% if nargin <2
%     c_list = unique(r.c(r.c~=0));
% end

% ROIs for PCA basis
idx = 1:r.numRoi;

if max(r.c) == 0
   I = idx;                 % ROI id
   idx = ones(1, r.numRoi); % cluster id
else
   I = idx(r.c~=0); % clustered ROI only
   idx = r.c(r.c~=0);
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
mycluscatter(score(:, 1:dim), idx, []);




end