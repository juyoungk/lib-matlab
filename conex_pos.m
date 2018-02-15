function conex_pos
    % open serial ports
    s1 = conex_serial_init('COM6');
    s2 = conex_serial_init('COM5');
    s3 = conex_serial_init('COM4');
    
     % (option) get current position of CONEX XY stage: TP
    fprintf(s1, '1TP\n'); x_vstim = str2num(fscanf(s1, '1TP%s\n'))
    fprintf(s2, '1TP\n'); y_vstim = str2num(fscanf(s2, '1TP%s\n'))
    fprintf(s3, '1TP\n'); z_vstim = str2num(fscanf(s3, '1TP%s\n'))
    
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