function [in_array] = multiRoi(img, varargin)
% Choose multiple 'Square ROI'
%
% input: 
%       img - image data (2-D)
%       
% output: 
%       in_array  - Array of 2-D logical array

[I, h_image] = myshow(img, 2);

in_array = [];
box_color = 'yellow';

try
    id = 0; % current ROI index
    
    %[in, h] = ellipseRoi(img);
    [in, h] = squareRoi(img);

    while ~isempty(h)
        
        id = id +1; 
        in_array = cat(3, in_array, in);
        
        pos = getPosition(h);
        
        % add ROI Rect & ROI id
        I = insertShape(I,'Rectangle',pos,'linewidth',1,'color',[255 255 0]);
        I = insertText(I,[pos(1)+pos(3), pos(2)],num2str(id),'FontSize',8,'BoxColor',box_color,'BoxOpacity',0.2,'TextColor','white');
        
        imshow(I);
        
        %[in, h] = ellipseRoi(img);
        [in, h, pos] = squareRoi(img);
    end
    
catch ME   
    
    disp([num2str(id),' ROI was selected.']);
    %rethrow(ME)

end