function [density, radius] = plot_cluster_density_profile(r, k, varargin)

figure('Name', ['Cluster ', num2str(k)]);

[row col] = size(r.image);

%I = 1:r.numRoi;
id_clustered = (r.c ~= 0);
        id_k = (r.c == k);
       id_kn = id_clustered & ~id_k;  
       
% x,y locations
centroids = getCentroid(r.roi_cc);
centroids_k = centroids(id_k, :);

% pixel size for spacing
px_per_um = double(row) / get_FOV_size_x25_Leica(r.header.scanZoomFactor); 
mm2_per_px2 = 1./(px_per_um * px_per_um) * 1e-6;
spacing_um = 20;
spacing_px = spacing_um * px_per_um;

% auto-correlation
[hist_cell, hist_area, radius] = hist_radius(size(r.image), centroids_k, spacing_px);
% density
density = hist_cell ./ (hist_area * mm2_per_px2);
radius  = radius * (1/px_per_um);

bar(radius, density); hold on
plot(radius, density, 'ko', 'LineWidth', 3)
xlabel('radius (um)');
ylabel('Density (cells / mm2)');
ax = gca;
ax.YTick = 0:50:ax.YTick(end);
if length(ax.YTick) > 6
    ax.YTick = 0:100:ax.YTick(end);
end
%xlim([0 400]);
hold off

% cross-cluster correlation 
[hist_cell, hist_area, radius] = hist_radius(size(r.image), centroids(id_kn, :), spacing_px);
% density
density = hist_cell ./ (hist_area * mm2_per_px2);
radius  = radius * (1/px_per_um);


% random distribution of same numbers of cells?
% locations = rand(500, 2) * row;
% [hist_cell, hist_area, radius] = hist_radius(size(r.image), locations, spacing_px);
% % density
% density = hist_cell ./ (hist_area * mm2_per_px2);
% radius  = radius * (1/px_per_um);


yyaxis right
plot(radius, density, 'd-.', 'LineWidth', 3, 'MarkerSize', 10);
ax = gca;
ax.XLim = [0, 220]; % um
ax.YLim(1) = 0;
ax.YLim(2) = ax.YLim(2) * 1.;
ax.YTick = ax.YTick(end);
Fontsize = 32;
ax.XAxis.FontSize = Fontsize;
ax.YAxis(1).FontSize = Fontsize;
ax.YAxis(2).FontSize = Fontsize;

%ylabel('Density (cells / mm2)');

hold off

end


function [hist_cell, hist_area, radius] = hist_radius(image_size, cell_locations, r_spacing)
% image size = [row col]
% cell location = [numcell 2]
% Output variables: area in terms of pixel number. 

if nargin < 3
    r_spacing = 5; % pixel
end

row = image_size(1);
col = image_size(2);
numcell = length(cell_locations);

% output 
radius = r_spacing:r_spacing:row;
hist_cell = zeros(numel(radius), 1);
hist_area = zeros(numel(radius), 1);

% accumulation profile versus radius
for i = 1:numcell

    % k-cell location 
    x0 = cell_locations(i, 1);
    y0 = cell_locations(i, 2);

    % px distance matrix from x0, y0
    distX = (1:col) - x0;
    distY = (1:row) - y0;
    [x, y] = meshgrid(distX, distY);

    % cell distance matrix
    dist_to_cells_XY     = cell_locations - repmat([x0 y0], [numcell, 1]);
    dist_to_cells_square = sum(dist_to_cells_XY .* dist_to_cells_XY, 2);
    dist_to_cells_square = dist_to_cells_square(dist_to_cells_square>0); % exclude dist = 0 case (self)

    for ri = 1:length(radius) % radius, not diameter
        
        r = radius(ri);
        
        % num of pixels/cells inside a radius r
        in_pixels = ((x/r).^2+(y/r).^2) <= 1;
        in_cells  = (dist_to_cells_square - r*r) <= 0;

        hist_area(ri) = hist_area(ri) + sum(vec(in_pixels));
        hist_cell(ri) = hist_cell(ri) + sum(vec(in_cells)); 
    end
    
end

% histogram
hist_cell(2:end) = hist_cell(2:end) - hist_cell(1:end-1);
hist_area(2:end) = hist_area(2:end) - hist_area(1:end-1);

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