function [norm_min] = sliceimgplot(img, timestamps)
% Text image (matrix) after reslicing images will be analyzed and plotted.
% img: data text image
% timestamps: array for timestamps or delay lines.

    Dim = ndims(img);
    if Dim >3
        disp('[fn: sliceimgplot] data(img) is dim>3 array. It should be dim 1~3 data');
        return;
    elseif Dim ==3
        %[Xstim, Ystim, N] = size(img);
        disp('[fn: sliceimgplot] Need to be implemented.');
        % reshape in to 2 dim?
        return;
    elseif Dim == 2
        [Nframe, Npixel] = size(img);
    elseif Dim == 1
        Nframe = length(img);
    end
    
    avg = mean(img, Dim);    % mean over many pixels
    var = std(img, 0, Dim);  % std
    norm = avg/max(avg);     % normalized
    norm_min = avg/min(avg); % normalized to min   
    snr = max(avg)/min(avg); % Max-to-min ratio (possibly, SNR)
    min_Subtracted = avg - min(avg);
    norm_Subtracted = min_Subtracted/max(min_Subtracted);
    %
    figure('position', [0, 50, 500, 900]);
    subplot(2,1,1); h1= plot(timestamps, img);
    set(gca,'FontSize',14,'FontWeight','bold');
    
    subplot(2,1,2); 
    %h2= errorbar(timestamps, avg/min(avg), var/min(avg), 'linewidth', 2);
    %h2 = plot(timestamps, avg, 'linewidth', 2);
    h2 = plot(timestamps, norm_min, 'linewidth', 2);
    xlim([min(timestamps),max(timestamps)]);
    xlabel('Delay time [us]','FontSize',14,'FontWeight','bold')
    set(gca,'FontSize',14,'FontWeight','bold');
    % ax = gca;set(ax, 'XTickLable','FontSize',16);
    
    % Result as Text in figure
    Result = sprintf('Max-to-min ratio (before min subtraction) = %.2f', snr);
    mTextBox = uicontrol('style','text');
    set(mTextBox,'String', Result,'position',[50,10,450,25]);
    set(mTextBox,'Units','characters');
end