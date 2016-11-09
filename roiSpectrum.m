function roiSpectrum(imgstack, varargin)
%
% roiSpectrum(imgstack)
% roiSpectrum(imgstack, coeff) % coeff is usually basis vetors after PCA
% analysis

size_img = size(imgstack);
Dim = ndims(imgstack);

%
if Dim ~= 3
    disp('Dim of image dataset is not 3.');
    return
end
%
nVarargs = numel(varargin);
if nVarargs >= 1 
    coeff = varargin{1};
else
    coeff = zeros(size_img(Dim),3);
end

% Mean image for ROI selection
imgstack = double(imgstack);
mean_img = mean(imgstack, Dim);
% image as 1-D : spectra
RawImgReshaped = reshape(imgstack,[],size(imgstack,ndims(imgstack)));
RawImgReshaped = im2double(RawImgReshaped);
% Avg spectrum
avg_spectrum = mean(RawImgReshaped.',2);
% normalization Max factor for spectra (Avg & Pixels)
MaxCoeff = max(vec(coeff(:,1:3)));
if MaxCoeff <= 0
    MaxCoeff = 0.5;
end
avg_spectrum = avg_spectrum/max(avg_spectrum)*MaxCoeff;

% Figure 1. spectrum display
hfig = figure('position', [3, 55, 500, 1050], ...
    'Name','Spectra','NumberTitle','off'); 
ax_spectra = subplot(2,1,1); 
%plot(avg_spectrum, '-.', 'LineWidth', 1.8); hold on;
%plot(coeff(:,1:3), ':', 'LineWidth', 1.5);
%S = sprintf('PC basis %d*', 1:3); %percentage explained
%D = regexp(S, '*', 'split'); legend('Avg spectrum', D{1:(end-1)}); 
hold on;
title('Spectra of ROIs','FontSize',16);

ax_tot = subplot(2,1,2); plot(coeff(:,1:3), ':', 'LineWidth', 1.5); 
xlabel('Spectral (delay) points');
ax = gca; ax.XTick = [];
S = sprintf('PC basis %d*', 1:3); %percentage explained
D = regexp(S, '*', 'split'); legend(ax, D{1:(end-1)}, 'Avg Spectrum over all ROIs');
%title(ax, 'Total ROI spectrum','FontSize',16); 

% Figure 2. ROI selection
hfig2 = figure('position', [450, 500, 650, 600], ...
    'Name','Total ROI spectrum','NumberTitle','off'); 
ax_roi = subplot(1,1,1); myshow(mean_img); title('Mean image','FontSize',16);

N_roi = 0; totRoi = zeros(size(mean_img));
reply = 'Y';
% Loop start
while (reply == 'Y') || (reply == 'y')
    % Set the polygon and display the selected pixels
    % returns the true/false value for each pixel.
    %
    axes(ax_roi);
    roi = ellipseMask(mean_img); % in is logical 2-D array like image
    totRoi = roi | totRoi;
    C = merge(mean_img, totRoi); imshow(C); % NOT myshow
    N_roi = N_roi +1;
    
    % individual ROI spectrum
    roi_1Darray  = reshape(roi,[],1); % as 1-D
    roi_Spectrum = RawImgReshaped(roi_1Darray,:).';
    %roi_Spectrum = scaled(mean(roi_Spectrum,2))/2;   
    roi_Spectrum = mean(roi_Spectrum,2);
    roi_Spectrum = roi_Spectrum/max(roi_Spectrum)*MaxCoeff;
    plot(ax_spectra, roi_Spectrum, 'LineWidth', 1.8);
    
    % integrated spectrum for total ROIs
    totRoi_1D_array = reshape(totRoi,[],1); % as 1-D
    totRoi_Spectrum = RawImgReshaped(totRoi_1D_array,:).';
    %totRoi_Spectrum  = scaled(mean(totRoi_Spectrum,2))/2;
    totRoi_Spectrum = mean(totRoi_Spectrum,2);
    totRoi_Spectrum = totRoi_Spectrum/max(totRoi_Spectrum)*MaxCoeff;
    plot(ax_tot, totRoi_Spectrum, 'LineWidth', 2.5); hold(ax_tot,'on');
    %plot(ax_tot, coeff(:,1:3), ':', 'LineWidth', 1.5); 
    hold(ax_tot,'off');
    xlabel(ax_tot,'Spectral points');
    ax_tot.XTick = []; 
    %break;
    
    % Focus to cmd window and ask for further clustering
    commandwindow;
    reply = input('More ellipses for ROI? Y/N [Y]:','s');
    if isempty(reply)
      reply = 'Y';
    end
    
end



end