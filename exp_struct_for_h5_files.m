function g = exp_struct_for_h5_files(dirpath, str, varargin) 
% Open h5 WaveSurfer recording files

    p = ParseInput(varargin{:});
    g = p.Results.Exp;
    pos = get(0, 'DefaultFigurePosition');
    
    str_condition = ['/*',str,'*'];
    %
     h5_filenames = getfilenames(dirpath, [str_condition,'.h5'])
    %
    if isempty(h5_filenames)
        error('There is no h5 recording files');
    end
    
    % routine for h5 recording (by WS) data
    for i=1:numel(h5_filenames)
        g.(str)(i).recording_h5_filename = h5_filenames{i};
        % filename w/o h5
        str_file = h5_filenames{i};
        str_end = strfind(str_file,'.h5');
        filename_wo_h5 = str_file(1:str_end-1);
        % Load the data
        [rec, times, header] = load_analogscan_WaveSufer_h5(g.(str)(i).recording_h5_filename);
        srate = header.Acquisition.SampleRate;
        % rec can be m x 3 matrix (e.g. Votage, Current and Photodiode)
        % photodiode?
   
        %
        g.(str)(i).rec = rec;
        g.(str)(i).rec_times = times;
        g.(str)(i).h5_header = header;
        g.(str)(i).rec_srate = srate;
        %
        figure; set(gcf, 'Position', pos+[pos(3)*floor((i-1)/2), -pos(4)*mod(i-1,2), 0, 0]);
        plot(times,rec); hold on; 
            grid on;
            xlabel('Sec'); ylabel('Voltage (mV)');
            ax = gca; Fontsize = 18;
            ax.XAxis.FontSize = Fontsize;
            ax.YAxis.FontSize = Fontsize;
            s_title = strrep(filename_wo_h5, '_', '  ');
            title(s_title, 'FontSize', Fontsize*1.1, 'FontName', 'Helvetica');

            % event timestamps if exists
%             if pd
%                 pd_threshold = 0.9;
%                 min_ev_interval_secs = 2.5;
%                 ev_idx = th_crossing(pd, pd_threshold, min_ev_interval_secs*srate);
%                 ev = times(ev_idx);
% 
%                 plot(ev, pd(ev_idx), 'bo');
%                     legend(['Num of events: ', num2str(length(ev_idx))],'Location','southeast');
%             end
        hold off
        %makeFigBlack(hf);
        saveas(gcf, [str,'_ex',num2str(i),'.png']);    
        
        % open imaging tif files if exists. 
        str_condition = ['/*',filename_wo_h5,'*'];
        tif_filenames = getfilenames(dirpath, [str_condition,'.tif']) % hopefully 1 file.
        
        
        % Tif data loading
%         SI_data = ScanImageTiffReader([dirpath,'/',g.(str)(i).tif_filename]);
%         h = SI_data.metadata;
%         h = interpret_SI_header_from_TiffReader(h);
%         vol = SI_data.data;      

% Double-axis figure
% figure; hold on;
% yyaxis left
% plot(data_h5.times{7},data_h5.voltage{7},'LineWidth', 1.1); grid on;
%     xlabel('second'); ylabel('Voltage (mV)');
%     ax = gca; Fontsize = 18;
% 
% yyaxis right
% plot(f_times, scaled(roi_trace));
%     ylim([0, 0.6])
%     xlim([0, 300])
%     ylabel('fluorescence (a.u.)');
%     ax = gca; Fontsize = 18;
%     ax.XAxis.FontSize = Fontsize;
%     ax.YAxis.FontSize = Fontsize;
% hold off;

    end
    
end

function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    addParamValue(p,'Exp', []);
    addParamValue(p,'exp_name', []);
    
%     addParamValue(p,'barWidth', 100, @(x)x>=0);
%     addParamValue(p,'barSpeed', 1.4, @(x)x>=0);
%     addParamValue(p,'barColor', 'dark', @(x) strcmp(x,'dark') || ...
%         strcmp(x,'white'));
%      
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end