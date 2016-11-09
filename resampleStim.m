function qstim = resampleStim(stim, fliptimes, newtimes);

% stim upsampling  
[Xstim,Ystim,Nframe] = size(stim);
stimas1d = reshape(stim, [], Nframe);
stimvect = shiftdim(stimas1d, 1);
% stim flip times and resample times
fliptimes = linspace(0, stimFrameInterval*Nframe, Nframe+1);
 newtimes = bintime;
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