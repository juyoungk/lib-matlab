function [mean_img, std_img] = myimgstat(imgstack, varargin)
% Statistics (over frames) and Merge of channel image stack
%
% [mean & std] = myimgstat(data, dim# for avg);
%
% tifs = 4-D matrix [row col d3 d4] or 3-D
% Mean & Std of each channel
% Merge images between 1,2,3
%
[row, col, d3, d4] = size(imgstack);
text = sprintf('\nImage [row  col  d3  d4] = [%d  %d  %d  %d]',row,col,d3,d4);
disp(text);

Dim = ndims(imgstack);
if Dim >4
    disp('Dim of image stack is over 4');
    return
elseif Dim <3
    disp('Dim is less than 3. Single image frame can be imaged by imshow or myshow. End.');
    return
end

nVarargs = numel(varargin);
if nVarargs < 1
    %avgdim = Dim; % average over last dimension 
    %answer = input('Frame dimension over which you want to compute avg and std ? (3 or 4) ');
    if d3 > d4
        answer = input(['d3 (',num2str(d3),') is the frame dimension? [Return(y) or 3 or 4] ']);
        if isempty(answer)
            avgdim = 3;
        elseif isnumeric(answer) && answer >=3 && answer <=4
            avgdim = answer;
        else
            disp('Unexpected input. No dim was selected.');
            return
        end      
    else
        answer = input(['d4 (',num2str(d4),') is the frame dimension? [Return(y) or 3 or 4] ']);
        if isempty(answer)
            avgdim = 4;
        elseif isnumeric(answer) && answer >=3 && answer <=4
            avgdim = answer;
        else
            disp('Unexpected input. No dim was selected.');
            return
        end
    end            
elseif nVarargs == 1
    avgdim = varargin{1};
    disp(['Stat(e.g. average) over dim ',num2str(avgdim), ' (It is NOT channel #)']);
end

imgstack = double(imgstack);
mean_img = mean(imgstack, avgdim);
std_img = std(imgstack, 0, avgdim); % FLAG is for normalization (N or N-1)

% Channel images
if avgdim == 3
    n = d4;
elseif avgdim == 4
    n = d3;
end
figure('position', [0, 600, 900, 500]);
for i = 1:n
    subplot(2,n,i); if i == 1; ylabel('Mean over frames'); end; 
    myshow(mean_img, i, 1.0); % adjuster level
    axis off; colormap gray; title(['Ch ',num2str(i),' mean']);
    subplot(2,n,n+i); if i == 1; ylabel('Std over frames'); end;
    myshow(std_img, i, 1.0);
    axis off; title(['Ch ',num2str(i),' std']);
end

% RGB merge images: meantif now has n-1 dim. 
% Ch1 - Green, Ch2 - Red, Ch3 - Blue
if Dim == 4 % Regardless of the avgdim (3 or 4), 'comp' function will extract specific channel
    merged_mean = cat(3, scaled(comp(mean_img,2)), scaled(comp(mean_img,1)), scaled(comp(mean_img,3)));
    merged_std = cat(3, scaled(comp(std_img,2)), scaled(comp(std_img,1)), scaled(comp(std_img,3)));
    %merged_mean = cat(3, scaled(meantif(:,:,2)), scaled(meantif(:,:,1)), scaled(meantif(:,:,3)));
    %merged_std = cat(3, scaled(stdtif(:,:,2)), scaled(stdtif(:,:,1)), scaled(stdtif(:,:,3)));
    figure('position', [0, 180, 900, 400], 'Name','Merged Ch Images (Mean and STD)');
    subplot(1, 2, 1); 
    %imshow(merged_mean);
    C = merge2ch(mean_img,1,2,1.5,1); imshow(C); axis equal; axis off;
    title('Mean','FontSize', 16);
    subplot(1, 2, 2); 
    %imshow(merged_std); 
    C = merge2ch(std_img,1,2,1.5,1); imshow(C); axis equal; axis off;
    title('STD','FontSize', 16);
    %myaxis;
end

iptsetpref('ImtoolInitialMagnification', 'fit');
%imtool(merged_mean);
end