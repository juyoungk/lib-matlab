function h = interpret_SI_header_from_TiffReader(t)

%
h = [];

% channel parameters
h = get_digit_numbers_to_new_field(h, t, 'channelSave');
h.n_channelSave = numel(h.channelSave);

% beam parameters
h = get_float_number_to_new_field(h, t, 'hBeams.powers');

% scan parameters
h = get_float_number_to_new_field(h, t, 'scanZoomFactor');
h = get_float_number_to_new_field(h, t, 'scanFramePeriod');
h = get_float_number_to_new_field(h, t, 'scanFrameRate');
h = get_float_number_to_new_field(h, t, 'linesPerFrame');
h = get_float_number_to_new_field(h, t, 'pixelsPerLine');
h = get_float_number_to_new_field(h, t, 'logFramesPerFile');
h = get_float_number_to_new_field(h, t, 'logAverageFactor');

% stack parameters
h = get_float_number_to_new_field(h, t, 'framesPerSlice');
h = get_float_number_to_new_field(h, t, 'numSlices');
h = get_float_number_to_new_field(h, t, 'stackZStepSize');
h = get_digit_numbers_to_new_field(h, t, 'zs');

% Motor parameters
% SI.hMotors.motorPosition = [-706.04 -3209.32 4519.2]
h = get_digit_numbers_to_new_field(h, t, 'motorPosition');

end

function h = get_float_number_to_new_field(h, text, str)
% search 'str' in 'text' file and add the float number as a new field of the struct 'h' 

num = get_float_number_after_str(text, [str,' = ']);

% exclude any other characters.
%str = str(isletter(str));

str = strrep(str,'.','_');

h.(str) = num; 

end

function h = get_digit_numbers_to_new_field(h, text, str)
% search 'str' in 'text' file and add the float number as a new field of the struct 'h' 

s = get_line(text, str);
a = extract_numbers(s);

h.(str) = a; 

end

function str_line = get_line(text, str)
% get the line from the text
% inputs:
%   text
%   str

loc = strfind(text, str);
str_lines = splitlines(text(loc:end));
str_line = str_lines{1};

end

function a = get_float_number_after_str(text, str)
% get the line from the text
% inputs:
%   text
%   str

loc = strfind(text, str);
str_lines = splitlines(text(loc:end));
str_line = str_lines{1};

a = sscanf(str_line, [str, '%f']);

end

function B = extract_numbers(A)

B = regexp(A,'\d*','Match'); % digits. not for float.
B = str2double(B);
%C = regexp(A,'[0-9]','match');
%disp(C);

% for i= 1:length(B)
%   if ~isempty(B{i})
%       Num(i,1)=str2double(B{i}(end));
%   else
%       Num(i,1)=NaN;
%   end
% end

end