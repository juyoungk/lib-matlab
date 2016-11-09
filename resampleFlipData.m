function [qy, qx] = resampleFlipData(y, fliptimes, newtimes)
% Resample the flip data (e.g. stim frames)
% # of rows (y) : # of channels. column(y) : data at each times (or flips)
% Stim at each time will be reshape as row vector and resampled at newtimes.
% qy is dim-2 matrix.
%

% DATA (y) info and reshape 
Dim = ndims(y);
if Dim >2
    disp('data (y) is dim>3 array. It should be 1-D or 2-D data');
    qy = []; qx = [];
    return;
elseif Dim == 2
    [~, Ny] = size(y);
elseif Dim == 1
    Ny = length(y);
end
% Timeindex should be column index.
y = reshape(y, [], Ny);

% Check the data and flip timestamps
Nflips = length(fliptimes);
% Goal: data = N, flip = N+1
% Assumption: the first fliptime is the first flip time of the data (y)
if Nflips > (Ny+1)      % execessive timestamps
    fprintf('# of flip timestamps (%d) is larger than # of data (%d)\n',Nflips, Ny);
    %disp('# of flip timestamps is larger than # of data');
    fliptimes = fliptimes(1:(Ny+1));
elseif Ny > (Nflips-1)  % excessive data
    fprintf('# of data (%d) is larger than # of flips (%d)\n', Ny, Nflips);
    y = y(:,1:(Nflips-1));
end
%[Nch, N] = size(y); % # of flips = N + 1 (automatically)

qx = newtimes;
% Limint the new smapling range within the given fliptimes
if newtimes(1) < fliptimes(1)  
    fprintf('New sampling start time (%.5f) is sooner than the flip start time (%.5f).\n', newtimes(1), fliptimes(1));
    % limit the sampling range
    qx = qx( qx >= fliptimes(1) );
    fprintf('New sampling start time is (%.5f).\n', qx(1));
end
if fliptimes(end) < newtimes(end)
    fprintf('New sampling end time (%.5f) is later than the last flip end time (%.5f).\n', newtimes(end), fliptimes(end));
    % limit the sampling range
    qx = qx( qx <= fliptimes(end) );
    fprintf('New sampling end time is (%.5f).\n', qx(end));
end

% Select fliptimes only during the new smapling. 
before_idx = find( fliptimes <= qx(1) );
 after_idx = find( fliptimes >= qx(end) );
fliptimes = fliptimes(before_idx(end):after_idx(1));
        y = y(:, before_idx(end):(after_idx(1)-1) );
 [Nch, N] = size(y); % data = N, flips within newsampling = N+1

 % Make 2-D matrix for new sampling y 
qy = zeros(Nch,length(qx));

% scan each point in the stim frames
for i=1:N
    % logical index in qx
    idx = fliptimes(i)<= qx & qx <fliptimes(i+1);
    % allocate the value in new stim(q) for the index
    for j=1:Nch
        qy(j,idx) = y(j,i);
    end
end

%newtimes(1) < fliptimes
%for 1:length(qx)    
%end

end