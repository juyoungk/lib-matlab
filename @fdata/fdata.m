classdef fdata < handle
% Imaging data under same FOV
% Array of gdata objects
% class for imaging sessions that can share same roi cc structure
    properties
        g
        numImaging
    end
    
    properties (AbortSet)
        cc          % New cc will trigger to compute roi data for all imaging sessions 
        roi_channel % Ch number will be automatically shared. 
    end
    % pipieline: ch select -> cc input -> roi data 
    
    methods
        % constructor
        function obj = fdata(ex_str, dirpath)
           if nargin > 0
               if nargin < 2; dirpath = pwd; end;
               [tif_filenames, h5_filenames] = tif_h5_filenames(dirpath, ex_str)
               
               % cluster into ex sessions
               n = numel(tif_filenames);
               
               % construct n gdata
               g(1, n) = gdata;
               obj.numImaging = n;
               for i =1:n
                    g(i) = gdata(tif_filenames{i}, h5_filenames{i});
               end
               obj.g = g;
           end
        end
        
        % Create roi data for all imaging sessions
        function set.cc(obj, cc)
            % ch select
            if ~isempty(obj.roi_channel)
                % do nothing
            elseif obj.g(1).header.n_channelSave == 1
                ch = obj.g(1).header.channelSave(1);
                disp(['Ch# ',num2str(ch),' is selected for roi analysis']);
                obj.roi_channel = ch;
            else    
                ch = input(['Imaging PMT channel # (Available: ', num2str(obj.g(1).header.channelSave),') ? ']);
                obj.roi_channel = ch;
            end
            
            % cc struct input to create roi data in gdata class
            for i=1:obj.numImaging
                obj.g(i).cc = cc;
            end
        end
        
        % roi analysis channel number set function
        function set.roi_channel(obj, ch)
            for i=1:obj.numImaging
                obj.g(i).roi_channel = ch;
            end
            obj.roi_channel = ch;
        end
        
            
        
    end
    
    
end



function [tif_filenames, h5_filenames] = tif_h5_filenames(dirpath, str)
    str_condition = ['/*',str,'*'];
    %
    tif_filenames = getfilenames(dirpath, [str_condition,'.tif']);
     h5_filenames = getfilenames(dirpath, [str_condition,'.h5']);
    %
    if isempty(tif_filenames)
        error('There are no tif files');
    end
end

function str_ex_name = get_ex_name(tif_filename)
    s_filename = strrep(tif_filename, '_', '  ');    
    s_filename = strrep(s_filename, '00', '');
    loc_name = strfind(s_filename, '.');
    str_ex_name = s_filename(1:loc_name-1);
end