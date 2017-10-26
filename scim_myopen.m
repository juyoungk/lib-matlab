function scim_myopen(varargin)
%
% scim_myopen;
% [row col ch frame]
% No swap for direct RGB image.
% scim_myopen('data name');
% data = [row, col, ch (RGB), frame] 
%

%addpath('/Users/peterfish/Documents/1__Retina_Study/Softwares/SCANIMAGE_r3.8_down2015Jan/scim');
%addpath('/Users/peterfish/Documents/1__Retina_Study/Softwares/SCANIMAGE_r3.8_down2015Jan/scim/scim_private');


[header, Aout, cmap] = scim_openTif;
% Print acq properties
printScimHeader(header);

% Create variable in base workspace
nVarargs = numel(varargin);

if nVarargs>=1 && ischar(varargin{1})
    data_name = ['data_',varargin{1}];
else
    commandwindow;
    data_name = input('* Name for image (stack)? ','s');
    %disp('No argument input or invalid name for data');
    if isempty(data_name)
        data_name = 'data_noname';
    end
end
data_name = ['data_',data_name];
namestr =   [data_name,'_header'];

% Channel index goes to the last using reshape
% Aout = swap34(Aout);

% assignin('base', data_name, dataByCH);
assignin('base', data_name, Aout);
assignin('base', namestr, header);

Dim = ndims(Aout);
[row, col, ch, frames] = size(Aout);
text = sprintf('Dims = %d. [row col ch frames*..] = [%d\t%d\t%d\t%d]\n',Dim, row,col,ch,frames);
disp(text);

if Dim == 4
    [Aout_mean, Aout_std] = myimgstat(Aout, 4);
    switch ch
        case 1
            
        case 2    
            stackRGB(Aout, 1, 2, []);
        case 3
            stackRGB(Aout, 1, 2, 3);
        otherwise
            disp(['Only 1,2,3 Chs are included in RGB stack. Numnber of CHs are ', num2str(ch),'.']);
            stackRGB(Aout, 1, 2, 3);
    end
end


end