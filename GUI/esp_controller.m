function varargout = esp_controller(varargin)
% ESP_CONTROLLER MATLAB code for esp_controller.fig
%      ESP_CONTROLLER, by itself, creates a new ESP_CONTROLLER or raises the existing
%      singleton*.
%
%      H = ESP_CONTROLLER returns the handle to a new ESP_CONTROLLER or the handle to
%      the existing singleton*.
%
%      ESP_CONTROLLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ESP_CONTROLLER.M with the given input arguments.
%
%      ESP_CONTROLLER('Property','Value',...) creates a new ESP_CONTROLLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before esp_controller_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to esp_controller_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help esp_controller

% Last Modified by GUIDE v2.5 01-Jul-2016 15:38:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @esp_controller_OpeningFcn, ...
                   'gui_OutputFcn',  @esp_controller_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% BEGIN MAIN FIGURE INITIALIZATION %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before esp_controller is made visible.
function esp_controller_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to esp_controller (see VARARGIN)

% Choose default command line output for esp_controller
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% --- Outputs from this function are returned to the command line.
function varargout = esp_controller_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function initialize_gui(fig_handle, handles, isreset) %#ok<*INUSD>

% Close any open communication devices
open_devices = instrfind('Status', 'open');
for i = 1:length(open_devices)
	fclose(open_devices(i));
end

% Find serial ports
serial_info = instrhwinfo('serial');
set(handles.serial_port_menu, 'String', serial_info.AvailableSerialPorts);

% Set z-axis relative selection menu
strs = arrayfun(@num2str, 1:4, 'UniformOutput', false);
set(handles.z_axis_relative_menu, 'String', strs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% END MAIN FIGURE INITIALIZATION %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% BEGIN STATUS BAR FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function status_bar_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function status_bar_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function reset_error_button_Callback(hObject, eventdata, handles)
set(handles.status_bar, 'String', 'Ready');
set(handles.status_bar, 'ForegroundColor', 'k');

function check_error_button_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'port')
    return;
end
err_str = get_error(handles.port);
if ~strncmp(err_str, 'NOERR', 5)
    set_status_error(handles, ...
        sprintf('Error: %s', err_str));
else
    set_status_ok(handles, 'Ready');
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% END STATUS BAR FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% BEGIN PRESET PANELS FUNCTIONS %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lower_objective_button_Callback(hObject, eventdata, handles)
% Lower the stage to the lower Z limit, keeping X and Y positions
% unchanged.
% Check if we're moving to or from the preset position
if get(hObject, 'Value')
    % MOVING TO PRESET
    set_status_ok(handles, 'Lowering objective completely');
    
    % Disable other movement widgets
    set_memory_widget_status(handles, 'off');
    set_movement_widget_status(handles, 'off');
    set(handles.turret_rotate_button, 'Enable', 'off');
    pause(0.01);
    
    % Save current z-position
    handles.lower_objective_saved_position = ...
        get_current_position(handles, 'z');
    
    % Print to "Return to:" field
    set(handles.lower_objective_return_position, 'String', ...
        sprintf('Z = %.4f', handles.lower_objective_saved_position));
    
    % Move down in Z to hardware travel limit, wait for motion stop
    fprintf(handles.port, '3MT+');
    fprintf(handles.port, '3WS');
    fprintf(handles.port, '3MD?');
    while strcmp(fscanf(handles.port, '%s'), '0')
        fprintf(handles.port, '3MD?');
        pause(0.01);
    end
    
    % Update the Z-position
    fprintf(handles.port, '3TP');
    current_zpos = fscanf(handles.port, '%f');
    set_current_position(handles, 'z', current_zpos);
    
    % Recompute relative z-position
    idx = get_current_relative_zpos_idx(handles);
    relative_position = compute_relative_zposition(handles, idx);
    set_relative_zpos(hObject, handles, relative_position);
    
    % Notify
    set_status_ok(handles, ...
        'Objective lowered. Press toggle button again when ready');
else
    % MOVING BACK FROM PRESET
    set_status_ok(handles, 'Returing to saved position');
  
    % Do the move and update the position field
    do_absolute_move(hObject, handles, 'z', ...
        handles.lower_objective_saved_position);
    handles.lower_objective_saved_position = NaN;
    set(handles.lower_objective_return_position, 'String', 'None');
    
    % Recompute relative z-position
    idx = get_current_relative_zpos_idx(handles);
    relative_position = compute_relative_zposition(handles, idx);
    set_relative_zpos(hObject, handles, relative_position);
    
    % Re-enable other widgets
    pause(0.01);
    set_memory_widget_status(handles, 'on');
    set_movement_widget_status(handles, 'on');
    set(handles.turret_rotate_button, 'Enable', 'on');
    set_status_ok(handles, 'Ready');
end
guidata(hObject, handles);

function turret_rotate_button_Callback(hObject, eventdata, handles)
% Move the stage to the preset position that allows safe rotating of the
% objective turret.

% Check if moving to or from preset
if get(hObject, 'Value')
    % Moving to preset
    set_status_ok(handles, 'Moving to "turret rotate" position');
    
    % Disable other movement widgets
    set_memory_widget_status(handles, 'off');
    set_movement_widget_status(handles, 'off');
    set(handles.lower_objective_button, 'Enable', 'off');
    pause(0.01);
    
    % Get current position, print to "Return to:" field
    handles.turret_rotate_saved_position(1) = ...
        get_current_position(handles, 'x');
    handles.turret_rotate_saved_position(2) = ...
        get_current_position(handles, 'y');
    handles.turret_rotate_saved_position(3) = ...
        get_current_position(handles, 'z');
    set(handles.turret_rotate_return_position, 'String', ...
        sprintf('[%.4f, %.4f, %.4f]', handles.turret_rotate_saved_position));

    % Move down in Z to hardware travel limit, wait for motion stop
    fprintf(handles.port, '3MT+');
    fprintf(handles.port, '3WS');
    fprintf(handles.port, '3MD?');
    while strcmp(fscanf(handles.port, '%s'), '0')
        fprintf(handles.port, '3MD?');
        pause(0.01);
    end
    fprintf(handles.port, '3TP');
    set_current_position(handles, 'z', fscanf(handles.port, '%f'));
    
    % Move to Y at 22mm. Will change when Newport restarts.
    do_absolute_move(hObject, handles, 'y', 22);
    fprintf(handles.port, '2WS');
    fprintf(handles.port, '2MD?');
    while strcmp(fscanf(handles.port, '%s'), '0')
        fprintf(handles.port, '2MD?');
        pause(0.01);
    end

    % Update the Y- and Z-positions
    fprintf(handles.port, '2TP');
    set_current_position(handles, 'y', fscanf(handles.port, '%f'));
    
    % Notify
    set_status_ok(handles, ...
        'Movement done. Press toggle button again when ready');
else
    % Moving back to saved position. Z is last!
    set_status_ok(handles, ...
        'Moving back to saved position');
    axes = {'x', 'y', 'z'};
    for i = 1:length(axes)
        do_absolute_move(hObject, handles, axes{i}, ...
            handles.turret_rotate_saved_position(i));
    end
    handles.turret_rotate_saved_position = NaN(3, 1);
    set(handles.turret_rotate_return_position, 'String', 'None');
    
    % Re-enable movement widgets
    set_memory_widget_status(handles, 'on');
    set_movement_widget_status(handles, 'on');
    set(handles.lower_objective_button, 'Enable', 'on');
    set_status_ok(handles, 'Ready');
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% END PRESET PANELS FUNCTIONS %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% BEGIN SERIAL PORT PANEL FUNCTIONS %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function serial_port_menu_Callback(hObject, eventdata, handles)

function serial_port_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function connect_button_Callback(hObject, eventdata, handles)
% Connects to the Newport controller via the selected serial port.
% Prints any connection errors to the status bar.

% Check if we're connecting or disconnecting
if (strcmp(get(handles.connect_button, 'String'), 'Connect') == 1)
    set_status_ok(handles, 'Connecting to serial port');
    try
        % Get the selected port
        port_value = get(handles.serial_port_menu, 'Value');
        port_strings = get(handles.serial_port_menu, 'String');
        selected_port = serial(port_strings{port_value});
        
        % Setup the serial port and open
        handles.port = serial(selected_port);
        set(handles.port, 'Timeout', 20); % Needed for long-duration movements.
        set(handles.port, 'BaudRate', 19200);
        set(handles.port, 'DataBits', 8);
        set(handles.port, 'Parity', 'none');
        set(handles.port, 'StopBits', 1);
        set(handles.port, 'FlowControl', 'hardware');
        set(handles.port, 'Terminator', 'CR');
        fopen(handles.port);
    catch
        set_status_error(handles, ...
            sprintf('Could not open serial port: %s', port_strings{port_value}));
        fclose(handles.port);
        clear handles.port;
        guidata(hObject, handles);
        return
    end
    
    try
        % Try to get the status. If this fails, we aren't actually connected to
        % the Newport.
        fprintf(handles.port, 'TS');
        [~, ~, msg] = fscanf(handles.port, '%s');
        if ~isempty(msg)
            set_status_error(handles, ...
                'Could not connect to Newport. Is the serial port correct?');
            fclose(handles.port);
            clear handles.port);
            return;
        end
        
        % Set X,Y movement speeds
        fprintf(handles.port, sprintf('1VA%d', 1));
        fprintf(handles.port, sprintf('2VA%d', 1));
        
        % Read and display the current positions
        fprintf(handles.port, '1TP');
        set_current_position(handles, 'x', fscanf(handles.port, '%f'));
        fprintf(handles.port, '2TP');
        set_current_position(handles, 'y', fscanf(handles.port, '%f'));
        fprintf(handles.port, '3TP');
        set_current_position(handles, 'z', fscanf(handles.port, '%f'));
    catch
        try
            err_str = get_error(handles.port);
        catch
            set_status_error(handles, ...
                ['Cannot connect to serial port. ' ...
                sprintf('Port "%s" probably does not do hardware handshaking', ...
                port_strings{port_value})]);
            fclose(handles.port);
            clear handles.port;
            guidata(hObject, handles);
            return
        end
        if ~isempty(err_str)
            extra = err_str;
        else
            extra = 'Unknown error';
        end
        set_status_error(handles, ...
            sprintf('Error getting axis positions: %s', extra));
    end
    
    % Preallocate space to save the positions to which we return after moving
    % to either of the presets
    handles.lower_objective_saved_position = NaN;
    handles.turret_rotate_saved_position = NaN(3, 1);
    
    % Enable everything
    set(handles.serial_port_menu, 'Enable', 'off');
    set_all_status(handles, 'on');
    set_status_ok(handles, 'Ready');
    set_step_size(handles, 'z_axis', get(get(handles.z_axis_preset_panel, ...
        'SelectedObject'), 'UserData'));
    set_step_size(handles, 'lateral', get(get(handles.lateral_preset_panel, ...
        'SelectedObject'), 'UserData'));
    set(handles.connect_button, 'String', 'Disconnect');
else
    % Disconnects from the Newport and resets everything.
    set_status_ok(handles, 'Disconnecting from serial port');
    fclose(handles.port);
    delete(handles.port);
    clear handles.port
    set_all_status(handles, 'off');
    reset_memory_positions(handles, '1', 'off');
    reset_memory_positions(handles, '2', 'off');
    reset_memory_positions(handles, '3', 'off');
    reset_zmem_positions(handles, 'off');
    set(handles.x_axis_position, 'String', 'None');
    set(handles.y_axis_position, 'String', 'None');
    set(handles.z_axis_position, 'String', 'None');
    set(handles.serial_port_menu, 'Enable', 'on');
    set(handles.connect_button, 'String', 'Connect')
    set_status_ok(handles, 'Ready');
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% END SERIAL PORT PANEL FUNCTIONS %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% BEGIN MEMORY POSITIONS FUNCTIONS %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function memory3_save_button_Callback(hObject, eventdata, handles)
save_memory_position(hObject, handles, '3');

function memory3_x_position_Callback(hObject, eventdata, handles)

function memory3_x_position_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function memory3_y_position_Callback(hObject, eventdata, handles)

function memory3_y_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function memory3_z_position_Callback(hObject, eventdata, handles)

function memory3_z_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function memory3_reset_button_Callback(hObject, eventdata, handles)
reset_memory_positions(handles, '3', 'inactive');

function memory2_save_button_Callback(hObject, eventdata, handles)
save_memory_position(hObject, handles, '2');

function memory2_x_position_Callback(hObject, eventdata, handles)

function memory2_x_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function memory2_y_position_Callback(hObject, eventdata, handles)

function memory2_y_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function memory2_z_position_Callback(hObject, eventdata, handles)

function memory2_z_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function memory2_reset_button_Callback(hObject, eventdata, handles)
reset_memory_positions(handles, '2', 'inactive');

function memory1_save_button_Callback(hObject, eventdata, handles)
save_memory_position(hObject, handles, '1');

function memory1_x_position_Callback(hObject, eventdata, handles)

function memory1_x_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function memory1_y_position_Callback(hObject, eventdata, handles)

function memory1_y_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function memory1_z_position_Callback(hObject, eventdata, handles)

function memory1_z_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function memory1_reset_button_Callback(hObject, eventdata, handles)
reset_memory_positions(handles, '1', 'inactive');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% END MEMORY POSITIONS FUNCTIONS %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% BEGIN Z-MOVEMENT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function z_axis_step_size_Callback(hObject, eventdata, handles)

function z_axis_step_size_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function z_axis_step_size_KeyPressFcn(hObject, eventdata, handles)
% Unselects any selected preset step size buttons, allowing the user to
% enter completely custom step size values.
set(handles.z_axis_preset_panel, 'SelectedObject', []);

function z_axis_preset_panel_SelectionChangeFcn(hObject, eventdata, handles)
% Changes z-axis stepsize to be one of the pre-defined step sizes given in
% the radio buttons.
set_step_size(handles, 'z_axis', get(hObject, 'UserData'));

function z_axis_position_Callback(hObject, eventdata, handles)

function z_axis_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function z_axis_relative_position_Callback(hObject, eventdata, handles)

function z_axis_relative_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function z_axis_relative_menu_Callback(hObject, eventdata, handles)
idx = get_current_relative_zpos_idx(handles);
relative_position = compute_relative_zposition(handles, idx);
set_relative_zpos(hObject, handles, relative_position);
guidata(hObject, handles);

function z_axis_relative_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function z_axis_up_button_Callback(hObject, eventdata, handles)
step_size = get_step_size(handles, 'z_axis');
if isnan(step_size)
    set_status_error(handles, 'Invalid step size for z-axis');
    return;
end
do_relative_move(hObject, handles, 'z', -1, step_size);
% Recompute relative position
idx = get_current_relative_zpos_idx(handles);
relative_position = compute_relative_zposition(handles, idx);
set_relative_zpos(hObject, handles, relative_position);
guidata(hObject, handles);

function z_axis_down_button_Callback(hObject, eventdata, handles)
step_size = get_step_size(handles, 'z_axis');
if isnan(step_size)
    set_status_error(handles, 'Invalid step size for z-axis');
    return;
end
do_relative_move(hObject, handles, 'z', 1, step_size);
% Recompute relative position
idx = get_current_relative_zpos_idx(handles);
relative_position = compute_relative_zposition(handles, idx);
set_relative_zpos(hObject, handles, relative_position);
guidata(hObject, handles);

function z_axis_go_button_Callback(hObject, eventdata, handles)
% Moves the Z axis to the absolute position defined in the "Position"
% field.
% Get and validate current desired position
pos = get_current_position(handles, 'z');
if isnan(pos)
    set_status_error(handles, 'Invalid absolute z-position');
    return;
end
do_absolute_move(hObject, handles, 'z', pos);

function z_axis_enable_go_checkbox_Callback(hObject, eventdata, handles)
% Enables the GO button for the z-axis, which allows the user to move
% directly to the absolute position entered into the "Position" field.
if get(hObject, 'Value')
    status = 'on';
    other_status = 'on';
else
    status = 'off';
    other_status = 'inactive';
end
set(handles.z_axis_go_button, 'Enable', status);
set(handles.z_axis_position, 'Enable', other_status);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% END Z-MOVEMENT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% BEGIN LATERAL MOVEMENT FUNCTIONS %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lateral_step_size_Callback(hObject, eventdata, handles)

function lateral_step_size_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lateral_step_size_KeyPressFcn(hObject, eventdata, handles)
set(handles.lateral_preset_panel, 'SelectedObject', []);

function y_axis_up_button_Callback(hObject, eventdata, handles)
step_size = get_step_size(handles, 'lateral');
if isnan(step_size)
    set_status_error(handles, 'Invalid step size for lateral axes');
    return;
end
do_relative_move(hObject, handles, 'y', 1, step_size);

function y_axis_down_button_Callback(hObject, eventdata, handles)
step_size = get_step_size(handles, 'lateral');
if isnan(step_size)
    set_status_error(handles, 'Invalid step size for lateral axes');
    return;
end
do_relative_move(hObject, handles, 'y', -1, step_size);

function x_axis_up_button_Callback(hObject, eventdata, handles)
step_size = get_step_size(handles, 'lateral');
if isnan(step_size)
    set_status_error(handles, 'Invalid step size for lateral axes');
    return;
end
do_relative_move(hObject, handles, 'x', 1, step_size);

function x_axis_down_button_Callback(hObject, eventdata, handles)
step_size = get_step_size(handles, 'lateral');
if isnan(step_size)
    set_status_error(handles, 'Invalid step size for lateral axes');
    return;
end
do_relative_move(hObject, handles, 'x', -1, step_size);


function y_axis_position_Callback(hObject, eventdata, handles)

function y_axis_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function y_axis_go_button_Callback(hObject, eventdata, handles)
% Moves the Y axis to the absolute position defined in the "Position"
% field.
% Get and validate current desired position
pos = get_current_position(handles, 'y');
if isnan(pos)
    set_status_error(handles, 'Invalid absolute y-position');
    return;
end
do_absolute_move(hObject, handles, 'y', pos);

function y_axis_enable_go_checkbox_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    status = 'on';
    other_status = 'on';
else
    status = 'off';
    other_status = 'inactive';
end
set(handles.y_axis_go_button, 'Enable', status);
set(handles.y_axis_position, 'Enable', other_status);

function x_axis_position_Callback(hObject, eventdata, handles)

function x_axis_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function x_axis_go_button_Callback(hObject, eventdata, handles)
% Moves the X axis to the absolute position defined in the "Position"
% field.
% Get and validate current desired position
pos = get_current_position(handles, 'x');
if isnan(pos)
    set_status_error(handles, 'Invalid absolute x-position');
    return;
end
do_absolute_move(hObject, handles, 'x', pos);

function x_axis_enable_go_checkbox_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    status = 'on';
    other_status = 'on';
else
    status = 'off';
    other_status = 'inactive';
end
set(handles.x_axis_go_button, 'Enable', status);
set(handles.x_axis_position, 'Enable', other_status);

function lateral_preset_panel_SelectionChangeFcn(hObject, eventdata, handles)
set_step_size(handles, 'lateral', get(hObject, 'UserData'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% END LATERAL MOVEMENT FUNCTIONS %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% BEGIN Z-MEMORY POSITION FUNCTIONS %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function z_axis_memory4_position_Callback(hObject, eventdata, handles)

function z_axis_memory4_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function z_axis_memory4_label_Callback(hObject, eventdata, handles)

function z_axis_memory4_label_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function z_axis_memory4_save_button_Callback(hObject, eventdata, handles)
set_zmem_position(hObject, handles, '4', ...
    get_current_position(handles, 'z'));
% Recompute relative position
idx = get_current_relative_zpos_idx(handles);
relative_position = compute_relative_zposition(handles, idx);
set_relative_zpos(hObject, handles, relative_position);
guidata(hObject, handles);

function z_axis_memory4_go_button_Callback(hObject, eventdata, handles)
pos = get_zmem_position(handles, '4');
if isnan(pos)
    set_status_error(handles, 'Invalid absolute z-position');
    return;
end
do_absolute_move(hObject, handles, 'z', pos);
% Recompute relative position
idx = get_current_relative_zpos_idx(handles);
relative_position = compute_relative_zposition(handles, idx);
set_relative_zpos(hObject, handles, relative_position);
guidata(hObject, handles);

function z_axis_memory4_enable_go_checkbox_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    status = 'on';
else
    status = 'off';
end
set(handles.z_axis_memory4_go_button, 'Enable', status);

function z_axis_memory3_position_Callback(hObject, eventdata, handles)

function z_axis_memory3_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function z_axis_memory3_label_Callback(hObject, eventdata, handles)

function z_axis_memory3_label_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function z_axis_memory3_save_button_Callback(hObject, eventdata, handles)
set_zmem_position(hObject, handles, '3', ...
    get_current_position(handles, 'z'));
% Recompute relative position
idx = get_current_relative_zpos_idx(handles);
relative_position = compute_relative_zposition(handles, idx);
set_relative_zpos(hObject, handles, relative_position);
guidata(hObject, handles);

function z_axis_memory3_go_button_Callback(hObject, eventdata, handles)
pos = get_zmem_position(handles, '3');
if isnan(pos)
    set_status_error(handles, 'Invalid absolute z-position');
    return;
end
do_absolute_move(hObject, handles, 'z', pos);
% Recompute relative position
idx = get_current_relative_zpos_idx(handles);
relative_position = compute_relative_zposition(handles, idx);
set_relative_zpos(hObject, handles, relative_position);
guidata(hObject, handles);

function z_axis_memory3_enable_go_checkbox_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    status = 'on';
else
    status = 'off';
end
set(handles.z_axis_memory3_go_button, 'Enable', status);

function z_axis_memory2_position_Callback(hObject, eventdata, handles)

function z_axis_memory2_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function z_axis_memory2_label_Callback(hObject, eventdata, handles)

function z_axis_memory2_label_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function z_axis_memory2_save_button_Callback(hObject, eventdata, handles)
set_zmem_position(hObject, handles, '2', ...
    get_current_position(handles, 'z'));
% Recompute relative position
idx = get_current_relative_zpos_idx(handles);
relative_position = compute_relative_zposition(handles, idx);
set_relative_zpos(hObject, handles, relative_position);
guidata(hObject, handles);

function z_axis_memory2_go_button_Callback(hObject, eventdata, handles)
pos = get_zmem_position(handles, '2');
if isnan(pos)
    set_status_error(handles, 'Invalid absolute z-position');
    return;
end
do_absolute_move(hObject, handles, 'z', pos);
% Recompute relative position
idx = get_current_relative_zpos_idx(handles);
relative_position = compute_relative_zposition(handles, idx);
set_relative_zpos(hObject, handles, relative_position);
guidata(hObject, handles);

function z_axis_memory2_enable_go_checkbox_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    status = 'on';
else
    status = 'off';
end
set(handles.z_axis_memory2_go_button, 'Enable', status);

function z_axis_memory1_position_Callback(hObject, eventdata, handles)

function z_axis_memory1_position_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function z_axis_memory1_label_Callback(hObject, eventdata, handles)

function z_axis_memory1_label_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function z_axis_memory1_save_button_Callback(hObject, eventdata, handles)
set_zmem_position(hObject, handles, '1', ...
    get_current_position(handles, 'z'));
% Recompute relative position
idx = get_current_relative_zpos_idx(handles);
relative_position = compute_relative_zposition(handles, idx);
set_relative_zpos(hObject, handles, relative_position);
guidata(hObject, handles);

function z_axis_memory1_go_button_Callback(hObject, eventdata, handles)
pos = get_zmem_position(handles, '1');
if isnan(pos)
    set_status_error(handles, 'Invalid absolute z-position');
    return;
end
do_absolute_move(hObject, handles, 'z', pos);
% Recompute relative position
idx = get_current_relative_zpos_idx(handles);
relative_position = compute_relative_zposition(handles, idx);
set_relative_zpos(hObject, handles, relative_position);
guidata(hObject, handles);

function z_axis_memory1_enable_go_checkbox_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    status = 'on';
else
    status = 'off';
end
set(handles.z_axis_memory1_go_button, 'Enable', status);

function z_axis_memory1_label_KeyPressFcn(hObject, eventdata, handles)
function z_axis_memory2_label_KeyPressFcn(hObject, eventdata, handles)
function z_axis_memory3_label_KeyPressFcn(hObject, eventdata, handles)
function z_axis_memory4_label_KeyPressFcn(hObject, eventdata, handles)
function z_axis_memory1_label_ButtonDownFcn(hObject, eventdata, handles)
function z_axis_memory2_label_ButtonDownFcn(hObject, eventdata, handles)
function z_axis_memory3_label_ButtonDownFcn(hObject, eventdata, handles)
function z_axis_memory4_label_ButtonDownFcn(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% END Z-MEMORY POSITION FUNCTIONS %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% BEGIN HELPER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function set_movement_widget_status(handles, status)
% Set the 'Enable' status of all widgets in the "Movement" panel
if (strcmp(status, 'on'))
    other_status = 'inactive';
else
    other_status = 'off';
end
set(handles.lateral_10um_stepsize_button, 'Enable', status);
set(handles.lateral_50um_stepsize_button, 'Enable', status);
set(handles.lateral_100um_stepsize_button, 'Enable', status);
set(handles.lateral_300um_stepsize_button, 'Enable', status);
set(handles.lateral_1mm_stepsize_button, 'Enable', status);
set(handles.lateral_step_size, 'Enable', status);
set(handles.x_axis_position, 'Enable', other_status);
set(handles.x_axis_down_button, 'Enable', status);
set(handles.x_axis_up_button, 'Enable', status);
set(handles.x_axis_enable_go_checkbox, 'Enable', status);
set(handles.y_axis_position, 'Enable', other_status);
set(handles.y_axis_down_button, 'Enable', status);
set(handles.y_axis_up_button, 'Enable', status);
set(handles.y_axis_enable_go_checkbox, 'Enable', status);
set(handles.z_axis_2um_stepsize_button, 'Enable', status);
set(handles.z_axis_5um_stepsize_button, 'Enable', status);
set(handles.z_axis_10um_stepsize_button, 'Enable', status);
set(handles.z_axis_50um_stepsize_button, 'Enable', status);
set(handles.z_axis_1mm_stepsize_button, 'Enable', status);
set(handles.z_axis_step_size, 'Enable', status);
set(handles.z_axis_position, 'Enable', other_status);
set(handles.z_axis_relative_position, 'Enable', other_status);
set(handles.z_axis_down_button, 'Enable', status);
set(handles.z_axis_up_button, 'Enable', status);
set(handles.z_axis_enable_go_checkbox, 'Enable', status);
set(handles.z_axis_relative_menu, 'Enable', status);
set(handles.z_axis_memory1_label, 'Enable', status);
set(handles.z_axis_memory1_save_button, 'Enable', status);
set(handles.z_axis_memory1_position, 'Enable', other_status);
set(handles.z_axis_memory1_enable_go_checkbox, 'Enable', status);
set(handles.z_axis_memory2_label, 'Enable', status);
set(handles.z_axis_memory2_save_button, 'Enable', status);
set(handles.z_axis_memory2_position, 'Enable', other_status);
set(handles.z_axis_memory2_enable_go_checkbox, 'Enable', status);
set(handles.z_axis_memory3_label, 'Enable', status);
set(handles.z_axis_memory3_save_button, 'Enable', status);
set(handles.z_axis_memory3_position, 'Enable', other_status);
set(handles.z_axis_memory3_enable_go_checkbox, 'Enable', status);
set(handles.z_axis_memory4_label, 'Enable', status);
set(handles.z_axis_memory4_save_button, 'Enable', status);
set(handles.z_axis_memory4_position, 'Enable', other_status);
set(handles.z_axis_memory4_enable_go_checkbox, 'Enable', status);

function set_memory_widget_status(handles, status)
% Set the "Enable" status of all widgets in the "Memory positions" panel
if (strcmp(status, 'on'))
    other_status = 'inactive';
else
    other_status = 'off';
end
set(handles.memory1_save_button, 'Enable', status);
set(handles.memory1_reset_button, 'Enable', status);
set(handles.memory1_x_position, 'Enable', other_status);
set(handles.memory1_y_position, 'Enable', other_status);
set(handles.memory1_z_position, 'Enable', other_status);
set(handles.memory2_save_button, 'Enable', status);
set(handles.memory2_reset_button, 'Enable', status);
set(handles.memory2_x_position, 'Enable', other_status);
set(handles.memory2_y_position, 'Enable', other_status);
set(handles.memory2_z_position, 'Enable', other_status);
set(handles.memory3_save_button, 'Enable', status);
set(handles.memory3_reset_button, 'Enable', status);
set(handles.memory3_x_position, 'Enable', other_status);
set(handles.memory3_y_position, 'Enable', other_status);
set(handles.memory3_z_position, 'Enable', other_status);

function set_preset_widget_status(handles, status)
% Set the "Enable" status of all widgets in the "Presets" panel
set(handles.lower_objective_button, 'Enable', status);
set(handles.turret_rotate_button, 'Enable', status);

function set_all_status(handles, status)
% Enable or disable every GUI element that should be set
% when connecting or disconnecting from the Newport
set_memory_widget_status(handles, status);
% set_preset_widget_status(handles, status); THESE ARE OFF FOR NOW
set_movement_widget_status(handles, status);

function set_status_error(handles, err_string)
% Set the status bar with a red error string.
set(handles.status_bar, 'ForegroundColor', [0.7 0.2 0.2]);
set(handles.status_bar, 'String', err_string);

function set_status_ok(handles, string)
% Set the status bar with the given string.
set(handles.status_bar, 'ForegroundColor', 'k');
set(handles.status_bar, 'String', string);

function err_str = get_error(port)
% Returns the error status of the Newport as a string
fprintf(port, 'TB');
err = fscanf(port, '%s');
tokens = regexp(err, ',', 'split');
err_str = tokens{end};

function set_step_size(handles, axis, sz)
% Set the step size for the given axis. Axis should be 'lateral' to set the
% lateral step size or 'z_axis' to set the z stepsize.
try
    set(handles.(sprintf('%s_step_size', axis)), 'String', ...
        sprintf('%0.4f', sz));
catch me
    set_status_error(sprintf('Internal error: %s', me.message));
end

function sz = get_step_size(handles, axis)
% Get the step size of the given axis. The axis should be one of 'lateral'
% to set the lateral step size or 'z_axis' to set the z stepsize;
try
    sz = str2double(get(...
        handles.(sprintf('%s_step_size', axis)), 'String'));
catch me
    set_status_error(sprintf('Internal error: %s', me.message));
    sz = NaN;
end

function pos = get_save_position(handles, mem, axis)
% Get the position of the given memory position along the given axis. Both
% 'mem' and 'axis' should be characters.
try
    pos = str2double(get(handles.(sprintf('memory%c_%c_position', ...
        mem, axis)), 'String'));
catch me
    pos = NaN;
    set_status_error(handles, sprintf('Internal error: %s', me.message));
end

function pos = get_current_position(handles, axis)
% Get the current position of the given axis. The axis should be a string,
% e.g., 'x', and the returned value is a double if it's valid, or NaN
% otherwise.
try
    pos = str2double(get(handles.(sprintf('%s_axis_position', ...
        axis)), 'String'));
catch me
    set_status_error(sprintf('Internal error: %s', me.message));
    pos = NaN;
end

function set_current_position(handles, axis, pos)
% Set the position string of the given axis. The axis should be a string,
% e.g., 'x', and the position should be a %f-formattable number.
try
    set(handles.(sprintf('%c_axis_position', axis)), 'String', ...
        sprintf('%.4f', pos));
catch me
    set_status_error(sprintf('Internal error: %s', me.message));
end

function do_absolute_move(hObject, handles, axis, pos)
% Perform a absolute movement along the given axis. The 'axis' is a 
% character giving the axis, e.g., 'x'. The absolute position to which the
% stage is moved is given in the double 'pos'.

% Get the axis to move
switch axis
    case 'x'
        axis_number = '1';
    case 'y'
        axis_number = '2';
    case 'z'
        axis_number = '3';
end

% Verify requested movement within software limits
if ~verify_within_software_limits(handles, axis, pos)
    set_status_error(handles, ...
    sprintf('Software movement limit reached for %c-axis', axis));
    return;
end

set_status_ok(handles, ...
    sprintf('Moving %c-axis to: %.4f', axis, pos));
pause(0.01);

% Write commands to the Newport to do the movement.
fprintf(handles.port, ...
    sprintf('%cWS', axis_number));
fprintf(handles.port, ...
    sprintf('%cPA%f', axis_number, pos));
fprintf(handles.port, ...
    sprintf('%cWS', axis_number));
err_str = get_error(handles.port);
if ~isempty(err_str) && ~strncmp(err_str, 'NOERR', 5)
    set_status_error(handles, ...
        sprintf('Error in absolute move: %s', err_str));
    return;
end

% Update the position
set_status_ok(handles, 'Ready');
set_current_position(handles, axis, pos);
guidata(hObject, handles);

function do_relative_move(hObject, handles, axis, direction, step_size)
% Perform a relative movement along the given axis in the given direction.
% The 'axis' is a character giving the axis, e.g., 'x', and the direction
% should be -1 if moving downwards, and anything else if moving upwards.
% The step size should be a double.

% Determine axis and direction
switch axis
    case 'x'
        axis_number = '1';
    case 'y'
        axis_number = '2';
    case 'z'
        axis_number = '3';
end
if direction == -1
    direction_string = '-';
    if strcmp(axis, 'z')
        dir_string = 'up';
    else
        dir_string = 'down';
    end
    
else
    direction_string = '';
    if strcmp(axis, 'z')
        dir_string = 'up';
    else
        dir_string = 'down';
    end
end

% Verify requested movement within software limits
current_position = get_current_position(handles, axis);
if ~verify_within_software_limits(handles, axis, current_position + ...
        direction * step_size)
    set_status_error(handles, ...
    sprintf('Software movement limit reached for %c-axis', axis));
    return;
end

% Set status bar and check if axis is moving
set_status_ok(handles, sprintf('Moving %c-axis %s', axis, dir_string));
pause(0.01);
is_moving = check_is_moving(handles);
if is_moving
    fprintf(handles.port, '%cWS', axis_number);
end

% Print commands to Newport. Note that we can't use fprintf as it is
% normally used, to format the values directly, because the overloaded
% version for serial ports does not support this. So use 'sprintf' to
% format the string before writing to the port.
fprintf(handles.port, ...
    sprintf('%cPR%c%f', axis_number, direction_string, step_size));
fprintf(handles.port, ...
    sprintf('%cWS', axis_number));
fprintf(handles.port, ...
    sprintf('%cMD?', axis_number));
while strcmp(fscanf(handles.port, '%s'), '0')
    fprintf(handles.port, ...
        sprintf('%cMD?', axis_number));
    pause(0.01);
end

% Read position and update display
fprintf(handles.port, sprintf('%cTP', axis_number));
set_current_position(handles, axis, fscanf(handles.port, '%f'));
set_status_ok(handles, 'Ready');
guidata(hObject, handles);

function reset_memory_positions(handles, mem, status)
% Reset the memory positions to 'None', for all axes of the given memory
% position. The position 'pos' should be a character.
axes = {'x', 'y', 'z'};
for j = 1:length(axes)
    pos_field = sprintf('memory%c_%c_position', mem, axes{j});
    set(handles.(pos_field), 'String', 'None');
    set(handles.(pos_field), 'Enable', status);
end

function save_memory_position(hObject, handles, mem)
% Save the current position in the given memory position. The input 'mem'
% should be a char.
set_status_ok(handles, ...;
    sprintf('Saving current position to memory %c', mem));
pause(0.01);
axes = {'x', 'y', 'z'};
for i = 1:3
    set(handles.(sprintf('memory%c_%s_position', mem, axes{i})), ...
        'String', sprintf('%.4f', get_current_position(handles, axes{i})));
end
set_status_ok(handles, 'Ready');
guidata(hObject, handles);

function pos = get_zmem_position(handles, mem)
% Return the z-position of the given z-axis memory position, or NaN if this
% memory position has not been saved. 'mem' should be a char.
s = get(handles.(sprintf('z_axis_memory%c_position', mem)), 'String');
if strcmp(s, 'None')
    pos = NaN;
else 
    pos = str2double(s);
end

function set_zmem_position(hObject, handles, mem, pos)
% Sets the z-position for the given memory position to the given position,
% pos. 'mem' should be a string and 'pos' should be a %f-formattable
% number.
set(handles.(sprintf('z_axis_memory%c_position', mem)), 'String', ...
    sprintf('%0.4f', pos));
guidata(hObject, handles);

function is_moving = check_is_moving(handles)
% Return true if the Newport is moving along any axis
fprintf(handles.port, 'TS');
ret = dec2bin(fscanf(handles.port, '%c'), 8);
for i = 1:3
    if strcmp(ret(i), '1')
        is_moving = true;
        return;
    end
end
is_moving = false;

function idx = get_current_relative_zpos_idx(handles)
% Return the index of the currently selected z-memory position in the
% dropdown menu
idx = get(handles.z_axis_relative_menu, 'Value');
return;

function relative_position = compute_relative_zposition(handles, idx)
% Return the current z-position relative to the selected z-memory position
mem_position = get_zmem_position(handles, num2str(idx));
z_position = get_current_position(handles, 'z');
relative_position = z_position - mem_position;
return;

function set_relative_zpos(hObject, handles, relative_position)
% Sets the relative z-position to the given value, if it is a valid number,
% otherwise, sets it 'None'
if isnan(relative_position)
    set(handles.z_axis_relative_position, 'String', 'None');
else
    set(handles.z_axis_relative_position, 'String', ...
        sprintf('%d um', round(relative_position * -1000))); 
        % Display in microns, not mm.
end
guidata(hObject, handles);
return;

function reset_zmem_positions(handles, status)
set(handles.z_axis_memory1_position, 'String', 'None');
set(handles.z_axis_memory2_position, 'String', 'None');
set(handles.z_axis_memory3_position, 'String', 'None');
set(handles.z_axis_memory4_position, 'String', 'None');
set(handles.z_axis_relative_position, 'String', 'None');
set(handles.z_axis_memory1_go_button, 'Enable', status);
set(handles.z_axis_memory1_enable_go_checkbox, 'Value', 0);
set(handles.z_axis_memory2_go_button, 'Enable', status);
set(handles.z_axis_memory2_enable_go_checkbox, 'Value', 0);
set(handles.z_axis_memory3_go_button, 'Enable', status);
set(handles.z_axis_memory3_enable_go_checkbox, 'Value', 0);
set(handles.z_axis_memory4_go_button, 'Enable', status);
set(handles.z_axis_memory4_enable_go_checkbox, 'Value', 0);

function ok = verify_within_software_limits(handles, axis, position)
MINIMUM_POSITIONS = [-Inf, -Inf, -Inf];
MAXIMUM_POSITIONS = [Inf, Inf, Inf];
% NOTE: This is really *minimum* position for z-axis, but sign is reversed.
switch axis
    case 'x'
        idx = 1;
    case 'y'
        idx = 2;
    case 'z'
        idx = 3;
end
ok = ( (position <= MAXIMUM_POSITIONS(idx)) & ...
        (position >= MINIMUM_POSITIONS(idx)) );
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% END HELPER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function TopX_Callback(hObject, eventdata, handles)
% hObject    handle to TopX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TopX as text
%        str2double(get(hObject,'String')) returns contents of TopX as a double


% --- Executes during object creation, after setting all properties.
function TopX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TopX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TopY_Callback(hObject, eventdata, handles)
% hObject    handle to TopY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TopY as text
%        str2double(get(hObject,'String')) returns contents of TopY as a double


% --- Executes during object creation, after setting all properties.
function TopY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TopY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
