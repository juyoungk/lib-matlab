function plot_cluster_spatial_corr(r, k, varargin)
% Spatial auto-correlation and cross-correlation between clusters
% Single plot for given cluster k

M = 30; % n_bins
L_pixel = size(r.image, 1);
edges = linspace(0, L_pixel, M);

%I = 1:r.numRoi;
id_clustered = (r.c ~= 0);
        id_k = (r.c == k);
       id_kn = id_clustered & ~id_k;  
       
% x,y locations
centroids = getCentroid(r.roi_cc);
centroids_k = centroids(id_k, :);

% cross-correlation (edge define)
centroids_kn = centroids(~id_k, :);
d = cdist(centroids_k, centroids_kn);
[N, ~] = histcounts(d, edges); %'BinWidth',BW or M for bin numbers
H_cross = N/norm(N);

% pdist of ROIs in cluster k
d = pdist(centroids_k);
[N, ~] = histcounts(d, edges); %'BinWidth',BW or M for bin numbers
H_auto = N/norm(N);

% graph

if isfield(r.header, 'scanZoomFactor')
    L_um = get_FOV_size_x25_Leica(r.header.scanZoomFactor);
else
    z = input('Zoom factor for imaging?');
    L_um = get_FOV_size_x25_Leica(z);
end
um_per_px = L_um/L_pixel;
X = (edges(1:end-1) + edges(2)/2.) * um_per_px; 

bar(X, H_auto); hold on
%bar(X, H_cross); hold off
plot(X, H_cross, '.-', 'Linewidth', 8); hold off
ax = gca;
ax.XLim = [10, 150]; % um
Fontsize = 16;
ax.XAxis.FontSize = Fontsize;
ax.YAxis.FontSize = Fontsize;
xlabel('[um]');
ylabel('Correlation');
            
end

function d = cdist(a, b)
% a, b should be a matrix of [n_exp, n_variables].
% output d - all distances between elements in a and elements in b

if size(a, 2) ~= size(b, 2)
    error('Variable [observation] numbers (dim 2) of inputs mismatch.');
end

d = zeros(size(a,1)*size(b,1),1);
n_a = size(a, 1);
n_b = size(b, 1);

for i = 1:n_a
    dd = b - a(i, :);
    dd = dd.*dd; % dx^2, dy^2
    dd = sqrt(sum(dd, 2));
    
    % id
    init = (i-1)*n_b + 1;
    d(init:init+n_b-1) = dd;
end

end


function centroid_list = getCentroid(cc)
% input:  cc sturuct
% output: 
%         ct_list - [n x 2] matrix
%
s = regionprops(cc, 'centroid');
a = [s.Centroid];
a = reshape(a, 2, []);
centroid_list = a.';
% 
% % pairwise distance % histgram
% d = pdist(ct_list);
% [N, edges] = histcounts(d);
% 
end