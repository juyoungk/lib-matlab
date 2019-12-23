function import_ascii(m, dir_str)
% open multiple files, but create one mdata object

d = dir(dir_str);

if isempty(d)
    error('No files matching the string');
end

numFiles = numel(d);
numHistogram = get_data(fullfile(d(1).folder, d(1).name), 2);
numChannels = length(get_data(fullfile(d(1).folder, d(1).name), 4));


if numFiles == 1
    % single file open
    filename = fullfile(d.folder, d.name);
    disp(filename);
    m.header.name = filename;

    % Display curve no.
    m.header.channels = get_data(filename, 4);

    % Resolution
    m.dtof_param.resolution = get_data(filename, 8) * 1e3; % ps resoltuion
    m.dtof_param.resolution = m.dtof_param.resolution(1);
    m.dtof_res_ps = m.dtof_param.resolution;
    res_ns = m.dtof_param.resolution * 1e-3;

    % DTOF (can be 8 channels)
    m.dtof = get_data(filename, 10);    

    % tau
    numtau = size(m.dtof, 1);
    m.tau = (1:numtau) * res_ns; 
else
    % multi file case
    % Dtof structure: histogram x channels x exp conditions
    % but later permute.
    m.dtof = zeros(numHistogram, numChannels, numFiles);
    m.header.name = cell(1, numFiles);

    for i = 1:numFiles

        filename = fullfile(d(i).folder, d(i).name);
        disp(filename);
        m.header.name{i} = filename;

        % Display curve no.
        m.header.channels = get_data(filename, 4);

        % Resolution
        m.dtof_param.resolution = get_data(filename, 8) * 1e3; % ps resoltuion
        m.dtof_param.resolution = m.dtof_param.resolution(1);
        m.dtof_res_ps = m.dtof_param.resolution;
        res_ns = m.dtof_param.resolution * 1e-3;

        % DTOF (can be 8 channels)
        m.dtof(:,:,i) = get_data(filename, 10);    

        % tau
        numtau = size(m.dtof, 1);
        m.tau = (1:numtau) * res_ns; 
    end
    % Dtof histogram x timestamps(exp) x channels
    m.dtof = permute(m.dtof, [1 3 2]);
end

m.header.numChan = length(m.header.channels);
% Dtof analysis
m.dtof_analyzer;

end


function out = get_data(filename, headerlinesIn)

A = importdata(filename, '\t', headerlinesIn);
%disp(A.textdata{end});
    
out = A.data;

end