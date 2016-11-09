function [ImgProjected, coeff, explained] = pcaimg(img,varargin)
% PCA analysis and do projection onto the largest 3 eigenvectors.
% input: uint16 will be converted to double precision for pca() and *MTIMES
% Reshape img matrix as 2D keeping last dimension.
% Output: scaled PC-projected "image" (2D), smoothing, after scaling onto [0 1] for each image
% Following Clustering analysis?
% [idx, cent, sumdist] = mykmeans(comp(proj,2:5),k)

reimg = reshape(img,[],size(img,ndims(img)));
X = im2double(reimg);
% mean subtraction (pca function automatically centers the data)
% X = X - mean(X(:)); 
Xscaled = scaled(X);

% PCA: X is n-by-p (p variables, e.g. different spectral points)
% Coeff matrix is p-by-p. (basis transformation)
% score = X*coeff
% score to raw data? score*coeff' (inverse of rot mat is a transpose)
[coeff, score, latent, ts, explained] = pca(X); 
Xprojected1D = X*coeff; % or score
ImgProjected = reshape(Xprojected1D, size(img,1), size(img,2), []);
ImgProjected = discfilter(ImgProjected);
% disp('Variance explained by PCs:'); disp(explained);

% Projected images onto PCs
n = 4;
figure('position', [0, 530, 1500, 575], ...
    'Name',[inputname(1),' - Projected images onto PCs (scaled images)'],'NumberTitle','off');
mag =1.2; proj = []; varNames = []; % number of PC components
for i=1:n
    xlabelname = ['PC ',num2str(i)];
    g = subplot(2,n+1,i+1); magnify(mag, g);
    %imagesc(ImgProjected(:,:,i)); axis off; %axis equal; 
    myshow(ImgProjected(:,:,i)); axis off; colormap(g, 'default');
    
    %if i==n; colorbar; end;
    g = subplot(2,n+1,i+n+2); magnify(mag, g);
    %subimage(scaled(ImgProjected(:,:,i))); axis off; colormap(g, gray);
    myshow(ImgProjected(:,:,i)); axis off; %colormap(g, gray); 
    title(xlabelname,'FontSize',16,'Color',[0 1 0]);
    % 
    proj = cat(3, proj, scaled(ImgProjected(:,:,i)));
    %varNames = cat(1, varNames, xlabelname);
    varNames = {varNames; xlabelname};
end
% Mean image
MeanImg = mean(img,3); % over frames. 
g = subplot(2,n+1,1); magnify(mag, g); 
myshow(MeanImg); axis off; colormap(g, 'default'); ylabel('Parula colormap'); 
g = subplot(2,n+1,n+2); magnify(mag, g);
myshow(MeanImg); axis off; colormap(g, gray); ylabel('gray colormap'); 
title('Mean','FontSize',16,'Color',[0 1 0]);
%
iptsetpref('ImshowInitialMagnification','fit');  % Mag. option for imshow

% 3-color 3-PC image
figure('position', [0, 0, 450, 450], 'Name',[inputname(1),' First 3 projected images in RGB channels'],'NumberTitle','off');
i = 1; j = 2; k = 3;
proj3com = cat(3, scaled(ImgProjected(:,:,i)), scaled(ImgProjected(:,:,j)), scaled(ImgProjected(:,:,k)));
name = sprintf('PC score %d-%d-%d as R-G-B\n', i,j,k);
%subplot(1,2,1); 
imshow(proj3com); title(name, 'FontSize', 16);

%
figure('position', [700, 165, 1920, 360], ...
    'Name',[inputname(1),'Variances and basis of PCs'],'NumberTitle','off'); 
subplot(1,4,1); g = imshow(proj3com,'InitialMagnification','fit');
title('PC 123 as RGB', 'FontSize',16);
%
% 2. Variance explained by each PCs
subplot(1,4,2); semilogy(latent, 'b-o', 'LineWidth', 2); ylabel 'Log plot'; title('Variances by PC','FontSize',16);
%
% 3. PC basis and Avg Spectrum. Do they look reasonable?
%    Avg spectrum: normalized by max value of PC basis
avg_spectrum = mean(X.',2);
avg_spectrum = avg_spectrum/max(avg_spectrum)*max(vec(coeff(:,1:n)));
%    PC basis (up to 'n')
n =4;
subplot(1,4,3); plot(coeff(:,1:n), 'LineWidth', 2); hold on;
plot(avg_spectrum, '-.', 'LineWidth', 2);
title('PC basis', 'FontSize', 16); ylim([-0.6 1.0]);
S = sprintf('PC basis %d*', 1:n); C = regexp(S, '*', 'split');
S = sprintf('PC : %.1f%%*', explained(1:n)); %percentage explained
D = regexp(S, '*', 'split');
legend(D{1:(end-1)}, 'Avg Spec'); %legend(C{:});
%
% 4. Draw spectrums from several pixels
% Select pixels that have high mean value.  
Xmean = scaled(mean(X, 2)); rangeTop = 1; % Top percentage
lowerB = prctile(Xmean,99.5-rangeTop); upperB = prctile(Xmean,99.5);
id = Xmean>lowerB & Xmean<upperB;
% Plot along different variables (p), not along the (n) observation.
% Transpose (.')
pixels_spectrum = mean(Xscaled(id,:).',2);
pixels_spectrum = pixels_spectrum/max(pixels_spectrum)*max(vec(coeff(:,1:n)));
subplot(1,4,4); plot(coeff(:,1:n),  ':', 'LineWidth', 1.9); hold on; 
plot(avg_spectrum, '-.', 'LineWidth', 1.9); 
plot(pixels_spectrum, 'LineWidth', 2.2); 
S = sprintf('PC basis %d*', 1:n); C = regexp(S, '*', 'split');
D = regexp(S, '*', 'split');
legend(D{1:(end-1)}, 'Avg (total)', 'Avg (pixels)');
title(['Mean Spectrum of Top ',num2str(rangeTop),'% pixels'], 'FontSize',16); ylim([-0.6 1.0]);
bc; % copy figure

% Show pixel locations at the Mean  
HighMeanPixels = reshape(id, size(img,1), size(img,2));
figure('position', [1415, 625, 505, 425]); 
C = merge(MeanImg,HighMeanPixels); 
imshow(C); title('Sampled High-Mean Pixels for Spectra', 'FontSize', 16);
% imgclu(id, size(img,1), size(img,2));

nVarargs = length(varargin);
% disp(['nVarargs = ',num2str(nVarargs)]);
if nVarargs >= 1 && varargin{1} <= n; i = varargin{1}; else i = n-2; end;
if nVarargs >= 2 && varargin{2} <= n; j = varargin{2}; else j = n-1; end;
if nVarargs >= 3 && varargin{3} <= n; k = varargin{3}; else k = n; end;

proj3com = cat(3, scaled(ImgProjected(:,:,i)), scaled(ImgProjected(:,:,j)), scaled(ImgProjected(:,:,k)));
proj3com = scaled(proj3com);

% name = sprintf('PC score %d (red), %d (green), %d (blue)\n', i,j,k);
% subplot(1,2,2); imshow(proj3com); title(['\fontsize{16}',name]);

% bivariant scatter plot: reshape and scatter plot
%figure('position', [0, 0, 800, 500], 'Name',[inputname(1),': Bivariant scatter plot'],'NumberTitle','off');
%gplotmatrix(Itransformed(:,1:n), []);

mycluscatter(Xprojected1D(:,1:3));
end