function move_conex_xyz_stage(src, evt)
% ASSUMPTION:
% XY stage (NEWPORT CONEX) are algined with the pos_ref_pos in advance.
% CAUTION: Coordinate of 285A is 10x lower than actual dimensions.
% MP285A @ COM8
% What is the coordinate of MP285A in the eyes of scanimage?
% ====> type "hSI.hMotors"
    
    % conversion factor for 285A
    c = 1;
    
    % Check ref positions 
    % top (285A) and bottom (CONEX) units.
    
    % Top ref positions will be same if
    % 1. MEA location (each time might be different.)
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
        pos_bot_ref = [5.958, 13.016, 23.017]; % mm
       
        % 0814 New MEA ref
        pos_bot_ref = [6.465, 13.0289, 22.600];
        % 1221 2018 new origin
        pos_bot_ref = [6.314, 13.340, 21.965];
        % 1221 2018 new origin
        pos_bot_ref = [6.314, 13.340, 22.6150];
        
        % 1221 2018 new origin
        pos_bot_ref = [5.92, 13.340, 21.8350];
    
    % Align 2P (not VS focus) to MEA 0416 201
       % w/ 2 PMTs, 920 laser
        pos_top_ref = [-346.3000 68.4000 7.6760e+03];
            % Differences between detector configurations
            % w/ Red PMT + camera: 4 um X,Y shift & 6 um focus shift
            % [-350.3000 72.4000 7.6824e+03];
        % adjusted ref position
        pos_top_ref = [-347.3000 69.4000 7.6790e+03];

        % 0419. Switch to 1070 laser.
        %pos_top_ref = [-322.1000 105.8000 6.0019e+03];

        % 0620: 1070 laser
        pos_top_ref = [-347.3000 69.4000 -4.6362e+03]; %
        
        % 0718: 1070 laser (large shift in z) 
        pos_top_ref = [-347.3000 69.4000 -6.4173e+03];
        
        % 0814: 1070 laser
        pos_top_ref = [112.2000 221.9000 -7.098e+03];
        
        % 0829: a little right and down
        pos_top_ref = [132.2000 241.9000 -7.098e+03];
        
        % 0829: new origin, zoom 3 scanning
        pos_top_ref = [24, 72, 21746];
        
        % 1221
        pos_top_ref = [87, 105.8, 15470];
        
        % 2019 0228 (reference to 2P scanning, not MEA)
        pos_top_ref = [60 -382.5000 1.1228e+04];
        
        % 2019 0409
        pos_top_ref = [-179.2000 -214 1.1058e+04];
           
        % 2019 0626
        pos_top_ref(1) = pos_top_ref(1) - 60; % (+) moves VS right
        pos_top_ref(2) = pos_top_ref(2) - 20; % (+) moves VS down
        
    % offset between 2p and VS focal planes: 
    % always 150 um below imaging plane(e.g. GCL)
    %z_offset_vstim = 0;
    z_offset_vstim = 0.150; % [mm] (+) means below the 2P focal plane. Away from top obj.
   
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

        if abs(dist(3)) > 3.5
            % current position?
%             fprintf(s3, '1TP\n'); z_vstim = str2double(fscanf(s1, '1TP%s\n'));
%             disp(['Curent Z position: ', num2str(z_vstim)]);
            disp(['Command move Z by ', num2str(dist(3)), '. Too large.']);
            error('CONEX stage: Too large z move attempted');
        else
            z_comm = sprintf('1PA%.3f\n',-dist(3)+pos_bot_ref(3)-z_offset_vstim);
            disp(['Command move Z Success.']);
            %disp(['Command move Z by ', num2str(dist(3)), '. Success.']);
            %z_comm = sprintf('1PA%.3f\n',-dist(3)+pos_bot_ref(3));
            fprintf(s3, z_comm);
        end
        
        % close ports
        serial_port_close(s1);
        serial_port_close(s2);
        serial_port_close(s3);
        
    catch ME % in case of error
        % display error
        disp(ME.message);
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