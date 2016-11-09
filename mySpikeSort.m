function mySpikeSort
%
% Start procedure for spike sorting.
%
    dirname = uigetdir;
    cd(dirname);
    spikesort(dirname);


end