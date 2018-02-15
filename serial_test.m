sy = conex_serial_init('COM5');

function s = conex_serial_init(str_port)
    s = serial(str_port);
    s.BaudRate = 921600;
    s.FlowControl = 'software';
    fopen(s);
end