function [dtof_binned, tau_binned] = dtof_binning(m, bin_time)

bin_ndata = round(bin_time/m.dtof_res_ps); % data point per bin

%
[numTau, numExp, numCh] = size(m.dtof);
%
numBin = floor(numTau/bin_ndata);
dtof_reshape = reshape(m.dtof(1:(numBin*bin_ndata), :,:), [bin_ndata, numBin, numExp, numCh]);
dtof_binned = sum(dtof_reshape, 1); % can be sum!
dtof_binned = squeeze(dtof_binned); % why not dtof(1, :, :, :);
tau_binned = 0:bin_time:(bin_time*(numBin-1)) + bin_time/2.;
tau_binned = tau_binned * 0.001;

end