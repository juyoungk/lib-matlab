
%%
get_ex_name('loc2_')

%%
function str_ex_name = get_ex_name(tif_filename)
    s_filename = strrep(tif_filename, '_', '  ');    
    s_filename = strrep(s_filename, '00', '');
    loc_name = strfind(s_filename, '.');
    if isempty(loc_name)
        str_ex_name = s_filename;
    else
        str_ex_name = s_filename(1:(loc_name-1));
    end
end
