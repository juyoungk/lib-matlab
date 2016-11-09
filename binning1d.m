function bindata = binning1d(data, numavg)
 % function bindata = binning(data, numavg)
 % numavg: must be a denominator of the data number
 % num of binns? Total N of data/ # of avg
     N = length(data);
     if (mod(N,numavg))
         Adatanum = floor(N/numavg)*numavg;
         data = data(1:Adatanum);
         fprintf('[binning1d] Data size (%d) is not divisible by the num_avg (%d). %d data points has been ignored.\n', ... 
             N, numavg, N-Adatanum);
     end
     
     bindata = sum(reshape(data,numavg,[]),1)/numavg;
end
 
% [counts,idx] = histc(x,bins);
% t = accumarray(idx,y,[size(bins,1),1]);
 