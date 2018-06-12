%% Script for WAVESURFER data files

%% Ex conditions & log
ex_common = '21 DIV';
ex_conditions = {'No insert', 'P4 insert', 'P14 insert'};

%% Coverslip % Recording id
ex_time = datestr(now);
ex_condition = ex_conditions{2}
ex_coverslip = 3;
ex_cell_id = 1;

% Start ex & Time log (Manual)
stims    = struct('Name', 'Ames', 't_start',   0); i =1; i = i+1;
stims(i) = struct('Name', 'Mus ', 't_start', 410); i = i+1;
stims(i) = struct('Name', 'Ames', 't_start', 590); i = i+1;
stims(i) = struct('Name', 'KCl ', 't_start', 700); i = i+1;
stims(i) = struct('Name', 'Ames', 't_start', 780); i = i+1;

% additional info
stims(1).ex_common = ex_common;
stims(1).condition = ex_condition;
stims(1).coverslip = ex_coverslip;
stims(1).cell_id = ex_cell_id;
%%
h5_filenames = getfilenames(pwd, '/*.h5')
%% File select by id number
id_file = 3;
[A, times, header] = load_analogscan_WaveSufer_h5(h5_filenames{id_file});
%
stims(1).filename = h5_filenames{id_file};
stims(1).A = A;
stims(1).times = times;
stims(1).header = header;
%% File open by other means?

%%
figure; h = gcf; h.Position(3) = 740;
%
plot(times, A(:,1))
    xlabel('[secs]');
    %ylabel('Membrane Potential [mV]');
    ylabel('MP [mV]');
    ax = gca;
    ax.FontSize = 15;
    hold on
% lines
label_offset = 3; % secs in plot
for i = 1:length(stims)
    x = stims(i).t_start;
    plot([x x], ax.YLim, '-.', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
    
    text(x+label_offset, ax.YLim(1), stims(i).Name, 'FontSize', 15, 'Color', 'k', ...
                                    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');  
end
% ex info
ex_str = sprintf('%s\ncoverslip: %d\n     cell id: %d', ex_condition, ex_coverslip, ex_cell_id);
%ex_str = [ex_condition, 'coverslip ', ex_coverslip, 'recording ', ex_recording];
text(label_offset, ax.YLim(end), ex_str, 'FontSize', 12, 'Color', 'k', ...
                                    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');  
hold off
%% Save
str_file = sprintf('%s_coverslip_%d_cell_id_%d', ex_condition, ex_coverslip, ex_cell_id);
saveas(gcf, [str_file,'.png']);
% save ex structure 'stims'
save(str_file, 'stims');

%%