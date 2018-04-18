function move_conex_xyz_stage(src, evt)
% ASSUMPTION:
% XY stage (NEWPORT CONEX) are algined with the pos_ref_pos in advance.
% CAUTION: Coordinate of 285A is 10x lower than actual dimensions.
% MP285A @ COM8
    
    % conversion factor for 285A
    c = 1;
    
    % Check ref positions 
    % top (285A) and bottom (CONEX) units.
    
    % Top ref positions will be same if
    % 1. MEA location
    % 2. Laser align
    % 3. Top unit PMT installations (weight and angle vary)
    % are same
    % 920 vs 1070 focus difference < 3 um (to Green PMT)

    % Previous alignment locations
%         % align 0409 2018 (920 nm)
%         pos_top_ref = [114.7000 -4.4000 7.7387e+03];
%         % align 4x obj (0411 2018)
%         pos_bot_ref = [6.556, 13.028, 22.8];            % 0411 2018 4x obj. 
%         % Focus (Z) for UV = 22.6, for Blue = 23.01
%         % For RED PMT: 
%         % adjust bot position for red PMT setting
%             pos_bot_ref(1) = pos_bot_ref(1) - 0.14;
%             pos_bot_ref(2) = pos_bot_ref(2) + 0.05;

    % VS to MEA 0416
    pos_bot_ref = [5.958, 13.016, 22.8];
    
    % align 2P to MEA 0416 201
    % w/ 2 PMTs
    pos_top_ref = [-346.3000 68.4000 7.6760e+03];
        % Differences between detector configurations
        % w/ Red PMT + camera: 4 um X,Y shift & 6 um focus shift
        % [-350.3000 72.4000 7.6824e+03];
    % adjusted ref position
    pos_top_ref = [-347.3000 69.4000 7.6790e+03];
        
    % offset between 2p and VS focal planes
    z_offset_vstim = 0.150 + 0.100; % [mm]
    
    % current pos after focus done.
    % pos_top = src.hSI.hMotors.motorPosition; % scanimage relative pos
    pos_top = src.hSI.hMotors.motorPositionTarget;
    
    % (absolute) dist of top obj (285A) [in mm]
    dist = c * (pos_top - pos_top_ref)/1000;
    
    try 
        % open serial ports
        s1 = conex_serial_init('COM6');
        s2 = conex_serial_init('COM5');
        s3 = conex_serial_init('COM4');

        % Move if the dist is acceptible. 
        if abs(dist(1)) > 5
            error('CONEX stage: Too large x move attempted.');
        else
            x_comm = sprintf('1PA%.3f\n',dist(1)+pos_bot_ref(1));
            fprintf(s1, x_comm);
            %fprintf(x_comm);
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
        
        % close ports
        serial_port_close(s1);
        serial_port_close(s2);
        serial_port_close(s3);
        
    catch % in case of error
        % display error
        
        
        % (option) get current position of CONEX XY stage: TP
        %fprintf(s1, '1TP\n'); x_vstim = str2num(fscanf(s1, '1TP%s\n'))
        %fprintf(s2, '1TP\n'); y_vstim = str2num(fscanf(s2, '1TP%s\n'))

        % close ports
        serial_port_close(s1);
        serial_port_close(s2);
        serial_port_close(s3);
    end
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