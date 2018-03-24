%% struct 'r' and 'cc' should be defined.
r = g.rr;
I = 1:r.numRoi;
%% select ROIs according to its statistical properties 
r.smoothing_size = 7;
%
x = r.stat.mean_f;
y = r.stat.smoothed_norm.trace_std_avg;
%
figure; scatter(x, y);
xlabel('mean'); ylabel('avg std to repeated stimulus');
[xv, yv] = getPolygon;
in = inpolygon(x, y, xv, yv);
plot(xv,yv,x(in),y(in),'.r',x(~in),y(~in),'.b')
%
I = 1:r.numRoi;
I = I(in);
%I = id_selected;
%% data X & smoothing
r.smoothing_size = 10;

X = r.avg_trace_smooth_norm(:,I);
times = r.avg_times;
%X = r.avg_trace_norm(:,I);

% example avg traces
id = 1:5;
figure;
plot(X(:,id),  'LineWidth', 1.2)

%% column normalization (same as scaling)
X = normc(X);
plot(X(:,id),  'LineWidth', 1.2)

%% PCA (and filtered trace)
X = r.c_mean(:,1:10);
X_col_times = X.'; % times as variables
[coeff, score, latent, ts, explained] = pca(X_col_times);

%% PCA filtered X
score_filtered = score;
score_filtered(:,5:end) = 0;
Xprojected = score_filtered*coeff';
Xprojected = Xprojected.';
plot(Xprojected(:,id),  'LineWidth', 1.2)

%%
% PCA basis vectors
figure; plot(coeff(:,1:5), 'LineWidth', 1.2);

%% score for all ROI trace


%% K-means cluster
num_cluster = 8;
PCA_dim = 5;

% Projected traces onto the fist few PCA dimensions.
score_filtered = score;
score_filtered(:,PCA_dim:end) = 0;
Xprojected = score_filtered*coeff';
Xprojected = Xprojected.';

% K-means cluster for selected ids

% X = X(:, I);
% Xprojected = Xprojected(:, I); 
% [idx, cent, sumdist] = mykmeans(score(I, 1:PCA_dim), num_cluster);

%[c_idx, cent, sumdist] = mykmeans(score(:, 1:PCA_dim), num_cluster, 'dist', 'cos');
[c_idx, cent, sumdist] = mykmeans(score(:, 1:PCA_dim), num_cluster);

        %% H-cluster
        % 1. distant metric
        % 2. linkage method is important - 'average', 'single', 'centroid', ..
        PCA_dim = 7;
        D = pdist(score(:, 1:PCA_dim),'euclidean'); % 'euclidean', ..
        clustTree = linkage(D,'average');
        cophenet(clustTree, D)
        %
        % Tree visualize
        P = 12;
        [h,nodes] = dendrogram(clustTree, P); % no more than P nodes
        h_gca = gca;
        h_gca.TickDir = 'out';
        h_gca.TickLength = [.002 0];
        h_gca.XTickLabel = [];

        %% Partition into groups from tree
        cutoff_tree = 0.88; % check in the tree diagram
        c_idx = cluster(clustTree,'criterion','distance','cutoff', cutoff_tree);
        num_cluster = numel(unique(c_idx))

%%
X_cluster = cell(1, num_cluster);
bw = zeros([r.roi_cc.ImageSize, num_cluster]);

% roi rgb image
labeled = labelmatrix(r.roi_cc);
RGB_label = label2rgb(labeled, @parula, 'k', 'shuffle');
mask = false(r.roi_cc.ImageSize);

% middle line
x_middle = r.avg_trigger_interval/2.;

figure('Position', [100, 150, 1800, 1350]);

for k = 1:num_cluster
   X_cluster{k} = X(:, c_idx == k);
     id_cluster = I(c_idx == k);
   
   ax = subplot(4, num_cluster, k);
   % raw (or smoothed) trace
        plot(times, X_cluster{k} ); hold on
        plot([x_middle, x_middle], ax.YLim, '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
        title('All traces');
        grid on
        hold off
        
   ax = subplot(4, num_cluster, k + num_cluster);
   % PCA projected trace
        plot(times, Xprojected(:, c_idx == k) ); hold on
        plot([x_middle, x_middle], ax.YLim, '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
        title('PCA projected');
        grid on
        hold off
   
   ax = subplot(4, num_cluster, k + 2*num_cluster);
   % mean trace in same classification
        plot(times, mean( X_cluster{k}, 2), 'LineWidth', 1.2); hold on
        plot([x_middle, x_middle], ax.YLim, '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
        title('Mean trace');
        grid on
        hold off
        
   subplot(4, num_cluster, k + 3*num_cluster);
   % cells locations
        
        % BW mask for clustered (selected) ROIs
        bwmask = cc_to_bwmask(r.roi_cc, id_cluster);
        
        %myshow(r.image); 
        %imshow(bwmask);
        colormap gray; imagesc(bwmask, [0 1]);
        hold on
        
        % Contour
        visboundaries(bwmask,'Color','r','LineWidth', 0.7); 

        % ROI number display
        s = regionprops(r.roi_cc, 'extrema');
        for ii = 1:numel(s)
           if ismember(ii, id_cluster)
               e = s(ii).Extrema;
               text(e(4,1), e(4,2), sprintf('%d', ii), 'Color', 'r', ... %5th comp: 'bottom-right'
                   'VerticalAlignment', 'bottom', 'HorizontalAlignment','left', 'FontSize',10); 
           end
        end
        hold off
        
        bw(:,:,k) = bwmask;
end

%% color coding of clusters
% What I need: cluster result =  bw(row, col, n_cluster)
bw_labeled = false(r.roi_cc.ImageSize);

% 1. Tiled plots of each clusters
figure('Position', [500, 200, 2400, 300]);
axes('Position', [0  0  1  0.9524], 'Visible', 'off');

for k = 1:num_cluster
    % plot the dist. of the given cluster
    subplot(1, num_cluster, k);
    imshow(bw(:,:,k));
    title(['Cluster ',num2str(k)]);
    
    % bw to labeled matrix
    bw_k_labeled = k * bw(:,:,k);
    bw_labeled = bw_labeled + bw_k_labeled; 
    
end

% 2. RGB labeled image for all clusters
hfig = figure;
    hfig.Color = 'none';
    hfig.PaperPositionMode = 'auto';
    hfig.InvertHardcopy = 'off';   
    
%cluster_RGB_label = label2rgb(labeled, @parula, 'k', 'shuffle');
cluster_RGB_label = label2rgb(bw_labeled, @jet, 'k');
cluster_colorbar = label2rgb(1:num_cluster, @jet, 'k');
        
axes('Position', [0  0.1  1  0.8524], 'Visible', 'off');
imshow(cluster_RGB_label);
axes('Position', [0  0  1  0.05], 'Visible', 'off');
imshow(cluster_colorbar);

% 2. imvol
imvol(bw);


%%
function [bw_selected, bw_array] = cc_to_bwmask(cc, id_selected)
% convert cc to bwmask array and totla bw for selected IDs.

    if nargin < 2
        id_selected = 1:cc.NumObjects;
    end

    bw_array = false([cc.ImageSize, cc.NumObjects]);

    for i = 1:cc.NumObjects
        grain = false(cc.ImageSize);
        grain(cc.PixelIdxList{i}) = true;
        bw_array(:,:,i) = grain;
    end
    % Total bw for selected IDs
    bw_selected = max( bw_array(:,:,id_selected), [], 3);
end