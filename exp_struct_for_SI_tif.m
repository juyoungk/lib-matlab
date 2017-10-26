function g = exp_struct_for_SI_tif(dirpath, str, varargin) 
    
    p = ParseInput(varargin{:});
    g = p.Results.exp;

    str_condition = ['/*',str,'*'];
    %
    tif_filenames = getfilenames(dirpath, [str_condition,'.tif'])
    % 
    
    for i=1:numel(tif_filenames)
        g.(str)(i).tif_filename = tif_filenames{i}; 
        
        % Tif imaging data loading
        SI_data = ScanImageTiffReader([dirpath,'/',g.(str)(i).tif_filename]);
        h = SI_data.metadata;
        h = interpret_SI_header_from_TiffReader(h);
        vol = SI_data.data;      
        
        % de-interleave into channels
        [rows, cols, n_frames] = size(vol);
        n = h.n_channelSave;
        h.n_frames = n_frames;
        h.n_frames_ch = n_frames/n;
        id_ch = mod((1:n_frames)-1, n)+1;
        
        g.(str)(i).header = h;
        % analog inputs (Assume max 4 channels)
        n_channels = 4;
        g.(str)(i).AI      = cell(n_channels, 1);
        g.(str)(i).AI_mean = cell(n_channels, 1);
        
        for j=1:n
            ch = vol(:,:,id_ch==j); % de-interleave frames
            ch_mean = mean(ch, 3);  % not-normalized.
            g.(str)(i).AI{h.channelSave(j)} = ch;
            g.(str)(i).AI_mean{h.channelSave(j)} = ch_mean;
            figure; 
            myshow(ch_mean);
        end

    end
    
    
end

function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    addParamValue(p,'exp', []);
    addParamValue(p,'barWidth', 100, @(x)x>=0);
    addParamValue(p,'barSpeed', 1.4, @(x)x>=0);
    
    addParamValue(p,'barColor', 'dark', @(x) strcmp(x,'dark') || ...
        strcmp(x,'white'));
     
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end