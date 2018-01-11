function [in_array] = multiRoi(img, varargin)
% Choose multiple 'Square ROI'
% Figure should be created in advance if you don't want to mess up other
% figures.
%
% input: 
%       img - image data (2-D)
%       varargin{1} - previous ROI array
% output: 
%       in_array  - Array of 2-D logical array

if nargin > 1 
    in_array = varargin{1};
    [~, ~, id] = size(in_array); 
    disp([num2str(id), ' ROIs were given as an input to function multiRoi']);
    % Check the given ROIs
    roi_tot = sum(in_array, 3) > 0;
    I = merge(img, roi_tot);
    figure; 
        hfig = gcf;
        hfig.Color = 'none';
        hfig.PaperPositionMode = 'auto';
        hfig.InvertHardcopy = 'off';
        axes('Position', [0  0  1  0.9524], 'Visible', 'off');
    imshow(I);
else
    in_array = [];
    id = 0; % current ROI index
    [I, ~] = myshow(img, 0.5);
end

box_color = 'yellow';

try    
    [in, h] = ellipseRoi(img);
    %[in, h] = squareRoi(img);

    while ~isempty(h)
        
        id = id +1; 
        in_array = cat(3, in_array, in);
        
        pos = getPosition(h); % handle location. rectangular specific function.
        
        % add ROI Rect & ROI id
        I = insertShape(I,'Rectangle', pos,'linewidth',1,'color',[255 255 0]);
        %I = insertShape(I,'Circle', pos,'linewidth',1,'color',[255 255 0]);
        I = insertText(I,[pos(1)+pos(3), pos(2)],num2str(id),'FontSize',8,'BoxColor',box_color,'BoxOpacity',0.2,'TextColor','white');
        
        imshow(I);
        
        [in, h] = ellipseRoi(img);
        %[in, h, pos] = squareRoi(img);
    end
    
catch ME   
    
    disp([num2str(id),' ROI was selected.']);
    %rethrow(ME)

end