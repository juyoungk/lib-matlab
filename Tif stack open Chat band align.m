% Open (ImageJ-saved) Tif file, Align Chat bands.

%% Tif to 3-D matrix
vol_td   = getTifStack('tdTomato.tif');
vol_chat = getTifStack('Chat.tif');

%% Z-profile of patches [Z-stack frames X observations]
N = 15; % sampling numbers per axis
[zProfile_chat, X, Y] = getZprofile( vol_chat, N);
[zProfile_td,   ~, ~] = getZprofile( vol_td,   N);

%% Find Chat Band locations (Peak findings)
    % smoothing Z-profile after reshaping
    zhist_chat = myProfileReshaped(zProfile_chat, 9); % 2nd param: smoothing size
    zhist_td   = myProfileReshaped(zProfile_td,   5);
    
    % Plot the all smoothed profiles
    figure; plot(zhist_chat);
    figure; plot(zhist_td);
        
    %%
    % Peak finding over dim 1.
    % output: locs_peak
    zm = zhist_chat;
    %
    FrameRange = 20:64;
    NumExpectedPeak = 2;
    MinProms = 10;
    MinPeakDist = 14;
    %
    locs_peak = myPeakFinder( zm(FrameRange, :), NumExpectedPeak, MinProms, MinPeakDist ); % along Dim 1. 
    
    % Location offset in the Z-stack
    locs_peak = locs_peak + FrameRange(1) - 1;   

    % Peak as 2-D matrix
    peak1 = reshape(locs_peak(1, :), N, N);
    peak2 = reshape(locs_peak(2, :), N, N);
    
    % 
    figure;
    surf(peak1); hold on
    surf(peak2); hold off
    
%% Interpolate peak locations over entire X Y pixels.    
% New sampling X, Y
[numPixelRow, numPixelCol, numFramesZ] = size(vol_chat);
[Xq, Yq] = meshgrid(1:numPixelCol, 1:numPixelRow);
% !!!!!!! inputs to interp2 is matrix (not vector)
peak1_interp = interp2(X, Y, peak1, Xq, Yq, 'cubic'); % outside is NaN. It can be 0.
peak2_interp = interp2(X, Y, peak2, Xq, Yq, 'cubic'); % outside is 0.
% 
figure;
surf(peak1_interp, 'EdgeColor', 'none', 'FaceAlpha', 0.8); hold on
surf(peak2_interp, 'EdgeColor', 'none', 'FaceAlpha', 0.8); hold off
% surf(peak1_interp, 'EdgeColor', 'none'); hold on
% surf(peak2_interp, 'EdgeColor', 'none'); hold off

%%
z_new = alignPeaksGetZmatrix(peak1_interp, peak2_interp, numFramesZ);


%% Convert Peak positions to new Z coordinate vector 
z_new = getAlignedZvector(peak1_interp, peak2_interp, numFramesZ);

%% New Z coordinate vector by Aligning 2 Chat bands at 0 and 1. 

% Distance between chat bands
dist_peaks = locs_peak(2,:) - locs_peak(1,:);
% Scalining for Chat band dist = 1
scaling = ones(1, length(dist_peaks)) ./ dist_peaks;

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
    title('Chat Bands Aligned.');
end
hold off

%% Aligned stacks by resampling at [-1, 2].
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
function zhist = myProfileReshaped( zProfile, smoothing_size )
% reshape and smooth
    
    if nargin < 2
        smoothing_size = 9;
        fprintf('smoothing size %d is set.\n', smoothing_size);
    end
    
    [~, ~, nZ] = size(zProfile);
    zhist = reshape(zProfile, [], nZ);
    zhist = zhist.'; % smoothing over Dim 1
    
    zhist = smoothdata(zhist, 'movmean', smoothing_size); 
end

        
%%
function locs_peak = myPeakFinder( zm, NumExpectedPeak, MinProms, MinPeakDist )
% [Peaks x observations]
    [frames, n_observation] = size(zm);
    locs_peak = zeros(NumExpectedPeak, n_observation);
    
    figure;
    for i=1:n_observation
        v = zm(:,i); % veector to analyize
        plot(v);
        [pks,locs,widths,proms] = findpeaks(v, 'MinPeakProminence', MinProms, 'MinPeakDistance', MinPeakDist);
        if length(locs) ~= NumExpectedPeak
            meg = sprintf('(Frame %d) Peak Numbers: %d (Expected Peak Num: %d) \n', i, length(locs), NumExpectedPeak);
            figure; plot(v); title(['Frame ', num2str(i)]);
            findpeaks(v, 'MinPeakProminence', MinProms, 'MinPeakDistance', MinPeakDist);
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
end

%% 
% function z = getAlignedZvector(peak1, peak2, maxZ)
% % Coordinate vector or matrix such that two (Chat) peaks are aligned at 0 and 1. 
% % 1st Chat band is usually toward GCL side. 
% 
%     % Distance between chat bands
%     dist_peaks = peak2 - peak1;
%     
%     % size
%     [row, col] = size(dist_peaks);
%     
%     % Scalining for Chat band dist = 1
%     scaling = ones(row, col) ./ dist_peaks;
%     
%     % Z coordinate 3-D matrix
%     [~, ~, z] = meshgrid(1:row, 1:col, 1:maxZ);
%     
%     % Reshape into 2-D
%     scaling_row =  reshape(scaling, 1,  []);     % Scailing as row vector
%     scaling_mat = meshgrid(scaling_row, 1:maxZ); % Extend row vector along dim 1  
%               z = reshape(     z, [], maxZ);
%           
%     % Scaling by matrix multiplication
%     z = z * scaling_mat; 
%           
%     % Translation
%     peak1  = reshape(peak1, [], 1)      % peak1 as col vector 
%     offset = peak1 .* scaling_row(:);   % col vector * col vector
%     [~, offset] = meshgrid(1:maxZ, offset);
%     z = z - offset;
%     
%     % Reshape back
%     z = reshape(z, row, col, maxZ);
%     
% %     for i=1:length(dist_peaks)
% %         % Z coordinate scaling
% %         z = (1:maxZ) * scaling(i);
% %         % Translate z coordinate such that the 1st Chat band is positioned at 0.
% %         z = z - peak1 *  scaling(i);
% %     end
% 
% end

%% 
function z = alignPeaksGetZmatrix(peak1, peak2, maxZ)
% Coordinate vector or matrix such that two (Chat) peaks are aligned at 0 and 1. 
% 1st Chat band is usually toward GCL side. 

    % Distance between chat bands
    dist_peaks = peak2 - peak1;
    
    % size
    [row, col] = size(dist_peaks);
    
    % Scalining for Chat band dist = 1
    scaling = ones(row, col) ./ dist_peaks;
    
    % Z coordinate 3-D matrix
    [~, ~, z] = meshgrid(1:row, 1:col, 1:maxZ);
    
    % Reshape into 2-D
    scaling_row =  reshape(scaling, 1,  []);     % Scailing as row vector
    scaling_mat = meshgrid(scaling_row, 1:maxZ); % Extend row vector along dim 1  
              z = reshape(     z, [], maxZ);
          
    % Scaling by matrix multiplication
    % !!!!! Too large matrix!!!!!
    z = z * scaling_mat; 
          
    % Translation
    peak1  = reshape(peak1, [], 1)      % peak1 as col vector 
    offset = peak1 .* scaling_row(:);   % col vector * col vector
    [~, offset] = meshgrid(1:maxZ, offset);
    z = z - offset;
    
    % Reshape back
    z = reshape(z, row, col, maxZ);
    
%     for i=1:length(dist_peaks)
%         % Z coordinate scaling
%         z = (1:maxZ) * scaling(i);
%         % Translate z coordinate such that the 1st Chat band is positioned at 0.
%         z = z - peak1 *  scaling(i);
%     end

end

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
function newStack = alignStack(vol, z, zrange)
% Align and resample column vectors according to z coordinate vector.
%
% vol = Z stack matrix. row vector is the profile.
% z   = Z-Coordinates matrix. Same size 3-D matrix with vol.
% zpoints: new Z sampling points
    N = ndims(vol);
    if N == 3
        [row, col, nZ] = size(vol);
    elseif N == 2
        error('Vol is not 3-D matrix');
    end 
    
    if nargin < 3 
        zrange = linspace(-1, 2, nZ);
    end
    
    if size(vol) ~= size(z) 
        error('Size of Z-coordi. matrix should be same as that of 3-D vol stack.');
    end
    
    % reshape 
    vol = reshape(vol, [], nZ);
      z = reshape(z,   [], nZ);
    
    % New Z stack (2-D)
    newStack = zeros(size(vol));
    
    figure;
    for i=1:n_observations
    
        %plot(z(:,i), vol(:,i)); hold on
        
        % resample at [-1, 2]
        newStack(i, :)  = interp1( z(i,:), vol(i,:), zrange, 'linear', 'extrap');
    end
    %hold off
    
    newStack = reshape(newStack, row, col, nZ);
    
    % visualization as image
    imvol(newStack);
end

%% Convert sampled 


%% 
function [zhist, X, Y] = getZprofile(vol, N)
% vol: image stack. 3-D matrix
% N = num of patches per XY image 
% output:
%        zhist - (X, Y, Z-profile)   
%        X     - corresponding X (col) positions
%        Y     - corresponding Y (row) positions
     
    if nargin < 2
        N = 10;
    end
    
    [row, col, nZ] = size(vol);
    zhist = zeros(N, N, nZ); % later, reshape into (N*N, nZ)
    
    % length
    L_px = floor(row/N);
    
    % Sampling start locations
    [X0, Y0] = meshgrid(1:N, 1:N);
    X0 = (X0 -1) * L_px + 1;
    Y0 = (Y0 -1) * L_px + 1;
    
    %
    for i=1:N % y
    for j=1:N % x

%         x0 = (j-1)*L_px + 1;
%         y0 = (i-1)*L_px + 1;
%         xid = x0:(x0+L_px-1);
%         yid = y0:(y0+L_px-1);
  
        xid = X0(i,j):(X0(i,j)+L_px-1);
        yid = Y0(i,j):(Y0(i,j)+L_px-1);
        
        vv = vol(yid, xid, :);
        
        zhist(i, j, :) = squeeze( mean( max(vv, [], 1), 2 ) ); % max over dim 2, mean over 1
        
    end
    end

%     zhist = reshape(zhist, [], nZ);
%     zhist = zhist.';
    % sampling locations
    X = X0 - 1 + 0.5*L_px;
    Y = Y0 - 1 + 0.5*L_px;
    
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