function plot_corr(r)
% compare correlations of various types of traces 

X = zeros(r.numRoi, 4);

X(:,1) = r.p_corr.smoothed;
X(:,2) = r.p_corr.smoothed_norm;
X(:,3) = r.p_corr.filtered;
X(:,4) = r.p_corr.filtered_norm;

mycluscatter(X)

% histogram 
%histcounts

end