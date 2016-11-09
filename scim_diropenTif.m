function [dirpath, header, cmaps] = scim_diropenTif(varargin)
% Open tif files in one specific directory using scanimage function,
% scim_openTif
%
% scim_diropenTif;
% scim_diropenTif('data_name');
% scim_diropenTif('data_name', dirpath);
%
% d = directory (for later)
% data(ch) retrieves tif data for specific channel #

nVarargs = numel(varargin);
if nVarargs<1
    dirpath = uigetdir;
    commandwindow;
    data_name = input('Name for image (stack)? ','s');
elseif nVarargs == 1
    data_name = varargin{1};
    dirpath = uigetdir;
else
    data_name = varargin{1};
    dirpath = varargin{2};
end
    
s = dir([dirpath, '/*.tif']);
% file list: convert the name field into cell array
file_list = {s.name};
N = numel(file_list);
tifstack = []; header = []; cmaps = [];
for i=1:N
    filename = [dirpath,'/',file_list{i}];
    [header, Aout, cmap] = scim_openTif(filename);
    if i==1
        n = ndims(Aout);
    end
    % cmap? [lowPixVal highPixVal] for each channel
    
    % checking saturation?
    
    % stack along (n+1) dim
    tifstack = cat(n+1, tifstack, Aout); 
end

tifstack = double(tifstack);
[ynum, xnum, ch, frames] = size(tifstack);
text = sprintf('[row col ch frames] = [%d\t%d\t%d\t%d]\n',ynum,xnum,ch,frames);
disp(text);

% Channel index goes to the last using reshape
tifch = zeros(ynum,xnum,frames,ch);
for i = 1:ch
    tifch(:,:,:,i) = reshape(tifstack(:,:,i,:),ynum,xnum,frames);
end
[ynum, xnum, frames, ch] = size(tifch);
text = sprintf('[row col ch frames] = [%d\t%d\t%d\t%d]\n',ynum,xnum,frames,ch);
disp('Channel index is changed to last..'); disp(text);

% basic statistics over frames (dim 4)
[mean_ch, std_ch] = myimgstat(tifstack,4);

% Create variable in base workspace
if ischar(data_name)
    data_name = ['data_',data_name];
else
    data_name = 'data_';
end

namestr1 = [data_name,'_mean'];
namestr2 = [data_name,'_std'];
namestr3 = [data_name,'_header'];
assignin('base', namestr1, mean_ch);
assignin('base', namestr2, std_ch);
assignin('base', namestr3, header);
assignin('base', data_name, tifch);

% Print acq properties
printScimHeader(header);

end
