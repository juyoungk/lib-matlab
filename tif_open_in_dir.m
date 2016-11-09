function [stack, headers, cmaps] = tif_open_in_dir(varargin)
% Open tif files in one specific directory using scanimage function,
% scim_openTif

nVarargs = length(varargin);
if nVarargs<1
    d = uigetdir;
else
    d = varargin{1};
    
s = dir([d, '/*.tif']);
% file list: convert the name field into cell array
file_list = {s.name};
stack = []; headers = []; cmaps = [];
for i=1:numel(file_list)
    filename = [d,'/',file_list{i}];
    [header, Aout, cmap] = scim_openTif(filename);
    if i==1
        n = ndims(Aout);
        disp(header.acq);
    end
    % cmap? [lowPixVal highPixVal] for each channel
    
    stack = cat(n+1, stack, Aout);
end


end
