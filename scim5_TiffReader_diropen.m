function [dirpath, header, cmaps] = scim5_TiffReader_diropen(varargin)
% Open Tiff files using SC library, average over frames, and stack it.
% Average dimension = 3.

avgdim = 3;

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
    vol = ScanImageTiffReader(filename).data();
    
    % log for the data
    [ynum, xnum, frames, ch] = size(vol);
    text = sprintf('%s [row col frames ch] = [%d\t%d\t%d\t%d]', file_list{i}, ynum, xnum, frames, ch);
    disp(text);
    
    %
    mean_vol = mean(vol, avgdim);
    if i==1
        n = ndims(mean_vol);
    end    
    
    % stack along (n+1) dim
    tifstack = cat(n+1, tifstack, mean_vol);
  
end

tifstack = double(tifstack);
[ynum, xnum, frames, n_files] = size(tifstack);
text = sprintf('Avg Stack: [row col files] = [%d\t%d\t%d\t%d]\n',ynum,xnum,frames, n_files);
% can be [row col frames files]
disp(text);

% basic statistics over frames
% [mean_ch, std_ch] = myimgstat(tifstack);

% Create variable in base workspace
if ischar(data_name)
    data_name = ['data_',data_name];
else
    data_name = 'data_';
end

namestr1 = [data_name,'_mean'];
namestr2 = [data_name,'_std'];
namestr3 = [data_name,'_header'];
%assignin('base', namestr1, mean_ch);
%assignin('base', namestr2, std_ch);
%assignin('base', namestr3, header);
assignin('base', data_name, tifstack);

% Print acq properties
% printScimHeader(header);

end
