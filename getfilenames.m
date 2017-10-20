function filenames = getfilenames(dirpath, str_condition)
% (e.g.) a = dir([dirpath, '/*Loc2_flash*.h5'])
% output: filenames as array of cells


a = dir([dirpath, str_condition]);
filenames = {a.name};


end