classdef fdata < handle
% Imaging data under same FOV
% Array of gdata objects
% class for imaging sessions that can share same roi cc structure
    properties
        FOV_name
        g
        numImaging  % # of imaging sessions under same FOV
        %
        cc          % Setting cc will trigger to compute roi data for all imaging sessions
        numRoi
        roi_channel % ch number will be automatically shared. 
        roi_rgb     % roi rgb snapshot
        %
        roi_selected 
    end
    % pipieline: ch select -> cc input -> roi data 
    
    methods
        % constructor
        function obj = fdata(ex_str, dirpath)
           if nargin > 0
               obj.FOV_name = get_ex_name(ex_str);
               % in case of no dirpath
               if nargin < 2; dirpath = pwd; end;
               
               % List of filenames
               [tif_filenames, h5_filenames] = tif_h5_filenames(dirpath, ex_str)
               
               % cluster into imaging sessions
               n = numel(tif_filenames);
               
               % construct n gdata
               g(1, n) = gdata;
               obj.numImaging = n;
               for i =1:n
                    tif_filename = [dirpath,'/',tif_filenames{i}];
                    h5_filename = [dirpath,'/',h5_filenames{i}];
                    %
                    g(i) = gdata(tif_filename, h5_filename);
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
            obj.cc = cc;
            obj.numRoi = cc.NumObjects;
            obj.roi_rgb = label2rgb(labelmatrix(cc), @parula, 'k', 'shuffle');
            obj.roi_selected = 1:obj.numRoi;
        end
        
        % roi analysis channel number set function
        function set.roi_channel(obj, ch)
            for i=1:obj.numImaging
                obj.g(i).roi_channel = ch;
            end
            obj.roi_channel = ch;
        end
        
        % compare mean images between imaging sessions
        function imshowpair(obj)
            for ch = obj.g(1).header.channelSave
                figure('Position', [100 150 737 774]);
                hfig.Color = 'none';
                hfig.PaperPositionMode = 'auto';
                hfig.InvertHardcopy = 'off';
                axes('Position', [0  0  1  0.9524], 'Visible', 'off');
                
                % loop for non-diagonal subscripts.
                n = obj.numImaging;
                m = ones(n) - eye(n);
                ind_pairs = find(m(:));
                n_subplots = length(ind_pairs)/2;
                i_plot =1;
                kk = 1;
                while kk <= length(ind_pairs)
                    k = ind_pairs(kk);
                    [i, j] = ind2sub([n, n], k);
                    if i >= j 
                        % do nothing
                    else
                        if n_subplots ~= 1
                            subplot(1, n_subplots, i_plot);
                            i_plot = i_plot +1;
                        end
                        imshowpair(obj.g(i).AI_mean{ch}, obj.g(j).AI_mean{ch});
                        title(['session pair: ', num2str(i), ', ', num2str(j)], 'FontSize', 18, 'Color', 'k');
                    end
                    kk = kk+1;
                end
            end
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