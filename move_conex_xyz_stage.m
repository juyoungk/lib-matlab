function move_conex_xyz_stage(src, evt)
% ASSUMPTION:
% XY stage (NEWPORT CONEX) are algined with the pos_ref_pos in advance.
% CAUTION: Coordinate of 285A is 10x lower than actual dimensions.
% MP285A @ COM8
    
    % conversion factor for 285A
    c = 1;
    
    % Check ref positions 
    % top (285A) and bottom (CONEX) units.
    pos_top_ref = [1.5242e+03 641.9000 -1.1977e+03];% MEA R-side align
    pos_top_ref = [27 10 8.3800e+03]; %MEA R-side 5x zoom align 0215 2018
    pos_bot_ref = [7.228, 12.946, 22.76];           % 0214 2018 4x obj
    z_offset_vstim = 0.150 + 0.150; % [mm]
    
    % open serial ports
    s1 = conex_serial_init('COM6');
    s2 = conex_serial_init('COM5');
    s3 = conex_serial_init('COM4');
    
    % current pos after focus done.
    % pos_top = src.hSI.hMotors.motorPosition; % scanimage relative pos
    pos_top = src.hSI.hMotors.motorPositionTarget;
    
    % (absolute) dist of top obj (285A) [in mm]
    dist = c * (pos_top - pos_top_ref)/1000;
    
    % Move if the dist is acceptible. 
    if abs(dist(1)) > 5
        error('CONEX stage: Too large x move attempted.');
    else
        x_comm = sprintf('1PA%.3f\n',dist(1)+pos_bot_ref(1));
        fprintf(s1, x_comm);
    end
    
    if abs(dist(2)) > 5
        error('CONEX stage: Too large y move attempted');
    else    
        y_comm = sprintf('1PA%.3f\n',-dist(2)+pos_bot_ref(2));
        fprintf(s2, y_comm);
    end
    
    if abs(dist(3)) > 2
        error('CONEX stage: Too large z move attempted');
    else
        z_comm = sprintf('1PA%.3f\n',-dist(3)+pos_bot_ref(3)-z_offset_vstim);
        %z_comm = sprintf('1PA%.3f\n',-dist(3)+pos_bot_ref(3));
        fprintf(s3, z_comm);
    end

    % (option) get current position of CONEX XY stage: TP
    %fprintf(s1, '1TP\n'); x_vstim = str2num(fscanf(s1, '1TP%s\n'))
    %fprintf(s2, '1TP\n'); y_vstim = str2num(fscanf(s2, '1TP%s\n'))
    
    % close ports
    serial_port_close(s1);
    serial_port_close(s2);
    serial_port_close(s3);
end

%
function s = conex_serial_init(str_port)
    s = serial(str_port);
    s.BaudRate = 921600;
    s.FlowControl = 'software';
    fopen(s);
end

% 
function serial_port_close(s)
    fclose(s);
    clear s;
end