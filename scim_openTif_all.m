function [dirpath, header, cmaps] = scim_openTif_all(varargin)
% Open tif files in one specific directory using scanimage function,
% scim_openTif
%
% scim_diropenTif_all;
% scim_diropenTif(dirpath);
%
% d = directory (for later)
% data(ch) retrieves tif data for specific channel # ???

nVarargs = numel(varargin);
if nVarargs<1
    dirpath = uigetdir;
elseif nVarargs >= 1
    dirpath = varargin{1};
end
    
s = dir([dirpath, '/*.tif']);
% file list: convert the name field into cell array
file_list = {s.name};
N = numel(file_list);
for i=1:N
    % file
    filename = [dirpath,'/',file_list{i}];
    % open Tif
    [header, Aout, cmap] = scim_openTif(filename);
    printScimHeader(header);
    % file info
    [pathstr,file_name,ext] = fileparts(filename); 
    disp(['File name : ', filename]);
    % 
    if i == 1
        commandwindow;
        exp_name = input('* prefix for images in the folder (e.g. date) ? ','s');
        if isempty(exp_name)
            exp_name = 'noname';
        end
    end
    % cmap? [lowPixVal highPixVal] for each channel  
    % checking saturation?
    
    data_name = ['data_', exp_name, '_', file_name];
    headerstr =   [data_name,'_header'];
    assignin('base', data_name, Aout);
    assignin('base', headerstr, header);
end

end
