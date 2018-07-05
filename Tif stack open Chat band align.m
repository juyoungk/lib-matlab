% Open (ImageJ-saved) Tif file, Align Chat bands.

%%
vol_td   = getTifStack('tdTomato.tif');
vol_chat = getTifStack('Chat.tif');

%% [Z-stack num X observations]
N = 20; % sampling numbers per axis
z_chat = getZprofile(vol_chat, N);
z_td   = getZprofile(vol_td, N);
%% smoothing
z_chat_smoo = smoothdata(z_chat, 'movmean', 5);
z_td_smoo   = smoothdata(z_td, 'movmean', 5);
%
figure; plot(z_chat_smoo);
figure; plot(z_td_smoo);

%% exclude bad frames
ids = 1:size(z_chat_smoo, 2);
z_chat_smoo = z_chat_smoo(:, ids~=350);
  z_td_smoo =   z_td_smoo(:, ids~=350);

%% Find Chat Band locations
% output: locs_peak
% z-profile matrix (zhist X observations)
    zm = z_chat_smoo;

    %
    NumExpectedPeak = 2;
    FrameRange = 20:60;
    MinProms = 60;
    MinPeakDist = 14;
    
    %
    [frames, n_observation] = size(zm);
    locs_peak = zeros(NumExpectedPeak, n_observation);
    
    figure;
    for i=1:n_observation
    %for i=[7,8,18]
        v = zm(FrameRange,i); % veector to analyize
        plot(v);
        [pks,locs,widths,proms] = findpeaks(v, 'MinPeakProminence', MinProms, 'MinPeakDistance', MinPeakDist);
        if length(locs) ~= NumExpectedPeak
            meg = sprintf('(Frame %d) Peak Numbers: %d (Expected Peak Num: %d) \n', i, length(locs), NumExpectedPeak);
            figure; plot(v); title(['Frame ', num2str(i)]);
            error(meg);
        else
            locs_peak(:, i) = locs; 
        end

        % find local maxima
        findpeaks(v, 'MinPeakProminence', MinProms, 'MinPeakDistance', MinPeakDist);
        hold on;
%         if mod(i, 10) == 0
%           figure;
%         end
    end
    hold off;

% Location in the Z-stack
locs_peak = locs_peak + FrameRange(1) - 1;   
% Distance between chat bands
dist_peaks = locs_peak(2,:) - locs_peak(1,:);
% Scalining for Chat band dist = 1
scaling = ones(1, length(dist_peaks)) ./ dist_peaks;
%% Align 2 Chat bands at 0 and 1
% Coordinate matrix
z_new = zeros(size(zm, 1), length(dist_peaks));

for i=1:length(dist_peaks)
    
    % Z coordinate scaling
    z = (1:frames) * scaling(i);
    
    % peak position scaling
    peaks_scaled = locs_peak(:,i) * scaling(i); % new peak positions after scaling.
    
    % Translate z coordinate such that the 1st Chat band is positioned at 0.
    z_new(:,i) = z - peaks_scaled(1);
    
    % Check the CHAT patterns
    plot(z_new(:,i), zm(:,i)); hold on
    title('Chat bands');
end
hold off

%% Align tdTomato & Chat stack and create new aligned stacks.
figure;
newz_locs = linspace(-1, 2, size(z_td_smoo, 1));
  td_aligned = alignColumn(  z_td_smoo, z_new, newz_locs); title('tdTomato (CRH-Cre+)');
chat_aligned = alignColumn(z_chat_smoo, z_new, newz_locs); title('Chat');
%

%% Overlaied Image
figure;
prof_chat = scaled(mean(chat_aligned, 2));
prof_td   = 0.8*scaled(mean(td_aligned, 2));
plot(newz_locs, prof_chat, 'LineWidth', 1.5); hold on
plot(newz_locs, prof_td, 'LineWidth', 1.5);
ax = gca;
plot([0 0], [ax.YLim(1) ax.YLim(end)], '--', 'LineWidth', 1.5, 'Color', [0.5 0.5 0.5]);
plot([1 1], [ax.YLim(1) ax.YLim(end)], '--', 'LineWidth', 1.5, 'Color', [0.5 0.5 0.5]);
hold off
axax
%%
A = scaled(chat_aligned); 
B = myshow(td_aligned, 0.3); 
make_im_figure;
imshowpair(A, B);

%% filtering data for clustering 
threshold = 1200;
I = td_aligned(:, max(td_aligned, [], 1) < threshold);
figure; plot(I)

%% PCA 
% data centering?
% I = I - mean(I(:));
%
X_col_times = I'; % times as variables
[coeff, score, latent, ts, explained] = pca(X_col_times);
% score (= X*coeff): Representation in PCA space

mycluscatter(score(:, 1:4))

%% PCA filtered X and plot examples
score_filtered = score;
score_filtered(:,5:end) = 0;
Xprojected = score_filtered*coeff';
Xprojected = Xprojected.';
plot(Xprojected(:, 1:10),  'LineWidth', 1.2)

%%
% PCA basis vectors
figure; plot(coeff(:,1:5), 'LineWidth', 1.2);

        %% K-means cluster
        num_cluster = 3;
        PCA_dim = 5;

        % Projected traces onto the fist few PCA dimensions.
        score_filtered = score;
        score_filtered(:,(PCA_dim+1):end) = 0;
        Xprojected = score_filtered*coeff';
        Xprojected = Xprojected.';

        [c_idx, cent, sumdist] = mykmeans(score(:, 1:PCA_dim), num_cluster);
        %[c_idx, cent, sumdist] = mykmeans(I, num_cluster);

        
% Display Clusters
X_cluster = cell(1, num_cluster);
X  = I; % original data set.

figure('Position', [100, 150, 1800, 950]);

for k = 1:num_cluster
   X_cluster{k} = X(:, c_idx == k);
     id_cluster = I(c_idx == k);
   
   ax = subplot(3, num_cluster, k);
   % raw (or smoothed) trace
        plot(newz_locs, X_cluster{k} ); hold on
        title('All traces');
        grid on
        hold off
        yticks([])
        axax;
   ax = subplot(3, num_cluster, k + num_cluster);
   % mean trace in same classification
        plot(newz_locs, mean( X_cluster{k}, 2), 'LineWidth', 1.8); hold on
        title('Mean trace');
        grid on
            ax = gca;
            plot([0 0], [ax.YLim(1) ax.YLim(end)], '--', 'LineWidth', 1.5, 'Color', [0.5 0.5 0.5]);
            plot([1 1], [ax.YLim(1) ax.YLim(end)], '--', 'LineWidth', 1.5, 'Color', [0.5 0.5 0.5]);
        hold off
        yticks([])
        axax(ax);
        
%    ax = subplot(3, num_cluster, k + num_cluster);
%    % PCA projected trace
%         plot(newz_locs, Xprojected(:, c_idx == k) ); hold on
%         title('PCA projected');
%         grid on
%         hold off
%    
   
end        
        
%% H-cluster
        % 1. distant metric
        % 2. linkage method is important - 'average', 'single', 'centroid', ..
        PCA_dim = 5;
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
function zm_new = alignColumn(zm, z, zrange)
% Align and resample column vectors according to z coordinate vector.
%
% zm = Z stack matrix. row vector is the profile
% z  = Coordinate for each col.
% zpoints: new sampling points
    
    [numz, n_observations] = size(zm);
    
    if nargin < 3 
        zrange = linspace(-1, 2, numz);
    end
    
    if size(z, 2) ~= size(zm, 2) 
        error('Col# of z (coordination) should be same for input matrix');
    end
    
    % New Z stack 
    zm_new = zeros(numz, n_observations);
    
    figure;
    for i=1:n_observations
    
        plot(z(:,i), zm(:,i)); hold on
        
        % resample at [-1, 2]
        zm_new(:, i)  = interp1(z(:,i), zm(:,i), zrange, 'linear', 'extrap');
    end
    hold off
    
    % visualization as image
    imvol(zm_new);
end


%% 
function zhist = getZprofile(vol, N)
% N = num of patches per XY image 
% output:
%        zhist - (Z-profile X observations)   
     
    if nargin < 2
        N = 10;
    end
    
    [row, col, nZ] = size(vol);
    zhist = zeros(N, N, nZ); % later, reshape into (N*N, nZ)
    
    %
    L_px = floor(row/N);

    %
    for i=1:N
    for j=1:N

        x0 = (i-1)*L_px + 1;
        y0 = (j-1)*L_px + 1;
        xid = x0:(x0+L_px-1);
        yid = y0:(y0+L_px-1);

        vv = vol(yid, xid, :);
        zhist(i,j,:) = squeeze( mean( max(vv, [], 1), 2 ) ); % max over dim 2, mean over 1
        
    end
    end

    zhist = reshape(zhist, [], nZ);
    zhist = zhist.';
end


%%
function vol = getTifStack(fname)
    % open Tif file saved in ImageJ, FIJI
    info = imfinfo(fname);
    vol = [];
    numberOfImages = length(info);
    for k = 1:numberOfImages
        currentImage = imread(fname, k, 'Info', info);
        vol(:,:,k) = currentImage;
    end 
end