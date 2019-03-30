%%

str_line = get_line(g.metadata, 'scanFramePeriod')


%%
function str_line = get_line(text, str)
% get the line from the text
% inputs:
%   text
%   str

loc = strfind(text, str);
str_lines = splitlines(text(loc:end));
str_line = str_lines{1};

end



