function pixelsEyeClustering(img, varargin)
%
% pixelsEyeClustering(X, Y)                 %   X & Y are 2-D images 
% pixelsEyeClustering(imgstack)             %   imgstack is NxMx2 stack 
% pixelsEyeClustering(proj, comp1, comp2)   %   proj is 3-D image stack
% pixelsEyeClustering(proj, comp1, comp2, coeff) % coeff is the basis matrix (e.g. coeff after PCA analysis)
%
size_img = size(img);
DimImg = ndims(img);
nVarargs = numel(varargin);

if ismatrix(img) && (nVarargs >= 1)  %   X & Y are 2-D images 
    if ~ismatrix(varargin{1})
        return
    end
    X = img;
    Y = varargin{1};
elseif (DimImg == 3) && (nVarargs == 0) %   imgstack is NxMx2 stack 
    disp('under developing');
    return
elseif (DimImg == 3) && (nVarargs >= 2)
    if ~isscalar(varargin{1}) || ~isscalar(varargin{2}) 
        disp('Wrong input to comp1, comp2');
        return
    end    
    X = comp(img, varargin{1});
    Y = comp(img, varargin{2});
    ImgReshaped = reshape(img, [], size(img,ndims(img)));
    
    if nVarargs >= 3
        % 3th variable is coeff
        coeff = varargin{3};
        RawImgReshaped = scaled(ImgReshaped * coeff');
    end 
end

hfig = figure('position', [5, 120, 1050, 980], ...
    'Name','Image X, Y, Clustered Pixels','NumberTitle','off'); 
subplot(2,2,1); myshow(X); title('1st image','FontSize',16);
subplot(2,2,2); myshow(Y); title('2nd image','FontSize',16);
ax_ImgPixSelected = subplot(2,2,3); axis off;
ax_scatter = subplot(2,2,4); plot(X,Y,'kd','MarkerSize',1.5,'LineWidth',2);
xlabel('1st image'); ylabel('2nd image');
% Large figure for polygon drawing
hfig2 = figure('position', [580, 400, 760, 710], ...
    'Name','Draw the polygon for clustering','NumberTitle','off'); 
ax_draw=subplot(1,1,1); plot(X,Y,'kd','MarkerSize',1.5,'LineWidth',2);

%
if nVarargs >= 3
    hfig_spectra = figure('position', [1330, 620, 600, 480], ...
        'Name','Spectra: PC basis and Clustered Pixels','NumberTitle','off');
    ax_spectra = subplot(1,1,1); hg = plot(coeff(:,1:3), ':', 'LineWidth', 1.5);
    S = sprintf('PC basis %d*', 1:3); %percentage explained
    D = regexp(S, '*', 'split'); legend(hg, D{1:(end-1)}); hold on;
end
%
reply = 'Y';
% Loop start
while (reply == 'Y') || (reply == 'y')
    % Set the polygon and display the selected pixels
    % returns the true/false value for each pixel.
    %
    % set focus to hfig
    %figure(hfig); axes(ax_scatter);
    figure(hfig2); axes(ax_draw);
    %
    in = [];
    in = polygonCluster(X, Y, ax_draw, ax_scatter); % output in? always 1-D array
    %in = polygonCluster(X, Y, ax_scatter); % output in? always 1-D array
    
    % image of the selected pixels
    if DimImg >1
        img_in = reshape(in, size_img(1), size_img(2));
        
        axes(ax_ImgPixSelected);
        %imagesc(im); axis off; colormap(color);
        C = merge(img_in, X); imshow(C);
    end
    % Mean spectrum of clustered pixels
    if nVarargs >= 3
        InSpectra = RawImgReshaped(in,:).';
        OutSpectra = RawImgReshaped(~in,:).';
        meanSpec_In  = scaled(mean(InSpectra,2))/2;
        meanSpec_Out = scaled(mean(OutSpectra,2))/2;
        plot(ax_spectra, meanSpec_In, 'LineWidth', 2.0);
        plot(ax_spectra, meanSpec_Out, 'LineWidth', 2.0);
        plot(ax_spectra, scaled(meanSpec_In-meanSpec_Out)/2, 'LineWidth', 2.0);
        l = legend(ax_spectra, D{1:(end-1)}, 'Cluster Pixels', 'Outside Pixels', 'Subtracted');
        l.FontSize = 14;
        title(ax_spectra, 'PC basis vs Mean spectrum of Clustered pixels');
    end
    
    %break;
    
    % Another polygon for clustering
    % Focus to cmd window and ask for further clustering
    commandwindow;
    reply = input('More polygons for clustering? Y/N [N]:','s');
    if isempty(reply)
      reply = 'N';
    end
    
end

end