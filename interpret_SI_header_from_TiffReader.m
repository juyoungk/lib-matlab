function h = interpret_SI_header_from_TiffReader(text)

%
str_info = 'SI.hScan2D.logFramesPerFile = ';
loc = strfind(text, str_info);
str_lines = splitlines(text(loc:end));
s = str_lines{1};

h.FramesPerFile = sscanf(s, [str_info, '%f']);

%
str_info = 'SI.hChannels.channelSave = ';
loc = strfind(text, str_info);
str_lines = splitlines(text(loc:end));
s = str_lines{1};

h.channelSave = sscanf(s, [str_info, '%f']);
h.channelSave = extract_numbers(s);

%

end

function B = extract_numbers(A)

B = regexp(A,'\d*','Match');
C = regexp(A,'[0-9]','match');
disp(C);

for ii= 1:length(B)
  if ~isempty(B{ii})
      Num(ii,1)=str2double(B{ii}(end));
  else
      Num(ii,1)=NaN;
  end
end

end