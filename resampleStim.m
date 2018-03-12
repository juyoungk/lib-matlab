function qstim = resampleStim(stim, fliptimes, newtimes)
% currently, I can't understand how this function works. 


% stim upsampling  
[~, ~, Nframe] = size(stim);

stimas1d = reshape(stim, [], Nframe);

stimvect = shiftdim(stimas1d, 1);
 
%
qstim = [];
for i=1:Nframe
    [qs, qt] = resampleFlipData( stimas1d(:,i), fliptimes, newtimes);
    qstim = [qstim, qs];
end

Nqsampling =  length(qt);

qstimvect = reshape(qstim, Nqsampling, []);
qstim = shiftdim(qstimvect, -1);


end