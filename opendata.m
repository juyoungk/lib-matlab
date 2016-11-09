function [stim, resp] = opendata()
dirstim = '/Users/peterfish/Documents/1__Retina_Study/Docs_Code_Stim/MyStim';
dirresp = '/Users/peterfish/Documents/1__Retina_Study/Docs_Code_Rec';

cd(dirstim);
% fidstim = fopen();
cd(dirresp);
fidresp = fopen('response1.txt');

% stim = fread(fidstim);
stim = rfMap1_recreate(100, 9, 342);
resp = fscanf(fidresp,'%f', inf);

stim = reshape(stim, 38, 38, []);

% fclose(fidstim);
fclose(fidresp);
end