function v = score2raw(X, pcacoeff, varargin)
% X is data in PCA space (e.g. centroids of k-means clustering)
% pcacoeff: coeff (n-by-p) matrix of pca. Projected vectors for PCA scores.
% v : vector in raw data space. p (variables)-by-n (data points) matrix.
% varargin : specific PC components

rot = pcacoeff';    % inverse of coeff mat.
PCs = varargin{1};
if size(X,2) ~= length(PCs)
    disp(['Number of dimentions between score vectors and PCs are not matching']);
    v = [];
    return;
end
vv = X * rot(PCs,:);
v = vv'; % p (variables)-by-n (data points) matrix

figure; plot(v, 'o')
%legend('sin(x)','cos(x)');

end