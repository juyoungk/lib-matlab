function displayRF(rf, fperiod, blocksize)
%
% future function?
% ROI-averaged STA:
%   roi = ellipseMask(mean_img);
%    totRoi_1D_array = reshape(totRoi,[],1); % as 1-D
%    totRoi_Spectrum = RawImgReshaped(totRoi_1D_array,:).';
    
    if nargin < 3 || isempty(blocksize)
        blocksize = 50; %um
    elseif nargin < 2 || isempty(fperiod)
        fperiod = 0.03322955;
    elseif nargin < 1 || isempty(rf)
        disp('RF should be given');
        return;
    end 
        
    Xstim = 1; Ystim = 1;
    % stim size & reshape [ch, frames]
    Dim = ndims(rf);
    if Dim >3
        disp('[fn: displayRF] rf is dim>3 array. It should be dim 1~3 data');
        return;
    elseif Dim ==3
        [Xstim, Ystim, N] = size(rf);
    elseif Dim == 2
        [Ystim, N] = size(rf);
    elseif Dim == 1
        N = length(rf);
    end

    t_label = 0:fperiod:fperiod*(N-1);
    t_label = -fliplr(t_label);

    if (Xstim == 1) || (Ystim == 1)
        rf = reshape(rf, Xstim*Ystim, []);
        [~, ind] = max(rf(:));
        [iy_max, if_max] = ind2sub(size(rf), ind);
        [~, ind] = min(rf(:));
        [iy_min, if_min] = ind2sub(size(rf), ind);
        
        figure('position', [900, 400, 420, 900]); 
        subplot(1,3,1); imagesc(rf); colorbar;
        subplot(1,3,2); plot( vec(rf(iy_max,:)) );
        subplot(1,3,3); plot( vec(rf(iy_min,:)) );
        return;
    else
        [~, ind] = max(rf(:));
        [ix_max, iy_max, if_max] = ind2sub(size(rf), ind);
        [~, ind] = min(rf(:));
        [ix_min, iy_min, if_min] = ind2sub(size(rf), ind); 
        
        figure('position', [550, 550, 940, 200]); 
        subplot(1,3,1); imagesc(rf(:,:,if_max)); axis off;
        colorbar; axis equal tight; 
        xlabel(['t = ', num2str(t_label(if_max)*1000,'%.0f'),' ms']);
        
        subplot(1,3,2); imagesc(rf(:,:,if_min)); axis off;
        colorbar; axis equal tight; 
        xlabel(['t = ', num2str(t_label(if_min)*1000,'%.0f'),' ms']);
        
        %temporal profile
        rf1D = reshape(rf, Xstim*Ystim, []);
        t_rf = sum(rf1D, 1);

        subplot(1,3,3); 
        %plot( vec(rf(ix_min,iy_min,:)) );
        plot(t_label, t_rf, 'LineWidth', 1.6);
        xlabel('time [s]','FontSize',16);
        ylabel('STA','FontSize',16);
        xlim([t_label(1), 0]);
        ax = gca;
        ax.XGrid = 'on';
        ax.XTick = -fliplr(0:0.1:0.5);
        ax.YTick = [];
        ax.YTickLabel = {};
    end
    %bc;
end

% implay