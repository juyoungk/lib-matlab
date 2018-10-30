%% struct 'r' and 'cc' should be defined.
% r should be defined

%% select ROIs according to its statistical properties 
%r.smoothing_size = 10;
%
I = 1:r.numRoi;

%x = r.stat.mean_f;
x = r.p_corr.smoothed_norm;
y = r.stat.smoothed_norm.trace_std_avg;
x_label = 'corr';
y_label = 'avg std to repeated stimulus';
%
figure; scatter(x, y);
xlabel(x_label); 
ylabel(y_label);

%% Clustered ROI only 
I = I(r.c~=0);
figure; scatter(x(I), y(I), [], r.c(I));
xlabel(x_label); 
ylabel(y_label);
set(gca, 'Color', [0 0 0])

%%
[xv, yv] = getPolygon;
in = inpolygon(x, y, xv, yv);
plot(xv,yv,x(in),y(in),'.r',x(~in),y(~in),'.b')
%
I = 1:r.numRoi;
%I = I(in);
%I = id_selected;
%% Cells with high reliability
I = find(r.p_corr.smoothed_norm > 0.2);

%% data X & smoothing
r.smoothing_size = 10;
X = r.avg_trace_smooth_norm(:,I);
times = r.avg_times;
% example avg traces
id = 1:5;
figure;
plot(X(:,id),  'LineWidth', 1.2)

%% column normalization (same as scaling)
X = normc(X);
plot(X(:,id),  'LineWidth', 1.2)

%% PCA: cells fitered by the reliability (P correlations)
r.smoothing_size = 7;
% condition here
I = find(r.p_corr.smoothed_norm > 0.2); % 2018 1027 on-off clustering
%
X = r.avg_trace_smooth_norm(:,I);
X = normc(X);
X_col_times = X.'; % times as variables
[coeff, score, latent, ts, explained] = pca(X_col_times);

% plot explained as PC order.
figure('Position', [2400 1350 560 420]);
semilogy(latent, '-o', 'LineWidth', 1.5, 'MarkerSize', 10)
    
    %% PCA works well? Check the projected trace into PCA low dim space.
    % projected (or filtered) X vs raw-trace X using low numbers (3~5) of PC. 
    numPC = 5;
    score_filtered = score;
    score_filtered(:, (numPC+1):end) = 0;
    Xprojected = score_filtered*coeff';
    Xprojected = Xprojected.';
    % sample id plot
    id = 1:5;
    figure;
    subplot(211); plot(X(:,id), 'LineWidth', 1.2);
    subplot(212); plot(Xprojected(:,id),  'LineWidth', 1.2);

    %% Check PCA basis vectors
    numPCto = 5;
    figure; plot(coeff(:,1:numPCto), 'LineWidth', 1.2);
    legend;

%% Score all cells w/ learned PCA basis
% define new (r > 0.1) set of cells
I = find(r.p_corr.smoothed_norm > 0.1);
X = r.avg_trace_smooth_norm(:,I);
X = normc(X);
% score (= X*coeff): Representation in PCA space
score = X.'*coeff; % times as variables in X.'
% PCA projected traces
    numPC = 5;
    score_filtered = score;
    score_filtered(:, (numPC+1):end) = 0;
    Xprojected = score_filtered*coeff';
    Xprojected = Xprojected.';

        %% K-means cluster using PCA scores
        % input data set: 'score'
        PCA_dim = 5;
        num_cluster = 2;
        
        sum_within_cluster = zeros(num_cluster, 1);
        silh_avg = zeros(num_cluster, 1);
        
        for k = 1:num_cluster
        
            fprintf('K-means analysis for Num of CLusters: %d\n', k);
            %[c_idx, cent, sumdist] = mykmeans(score(:, 1:PCA_dim), num_cluster, 'dist', 'cos');
            [c_idx, cent, sumdist, silh_avg(k)] = mykmeans(score(:, 1:PCA_dim), k);
            sum_within_cluster(k) = sum(sumdist);
            
        end
        
        figure; plot(sum_within_cluster, '-o', 'Linewidth', 2, 'MarkerSize', 10); title('Sum of within-cluster dist to centroids of clusters');
        figure; plot(silh_avg,  '-o', 'Linewidth', 2, 'MarkerSize', 10);          title('Average Silhouette Value');


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
I = 1:r.numRoi;
c_idx = r.c;
num_cluster = r.dispClusterNum;
%%
X_cluster = cell(1, num_cluster);
bw = zeros([r.roi_cc.ImageSize, num_cluster]);

% roi rgb image
labeled = labelmatrix(r.roi_cc);
RGB_label = label2rgb(labeled, @parula, 'k', 'shuffle');
mask = false(r.roi_cc.ImageSize);

% middle line
x_middle = r.avg_trigger_interval/2.;

figure('Position', [100, 150, 350*num_cluster, 1400]);

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
%         plot(times, Xprojected(:, c_idx == k) ); hold on
%         plot([x_middle, x_middle], ax.YLim, '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
%         title('PCA projected');
%         grid on
%         hold off
   
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