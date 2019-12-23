classdef mdata < matlab.mixin.Copyable
    
    properties
        header
        exp_id
        numch
        
        % optode params
        sds
        
        %
        period % integration time
        t      % timestamp
        count % total count over integration time
        
        % Count (rate) of interest
        cri % recorded counts in H5 file.
        cri_onset_ns
        cri_until_ns
        cri_param
        
        % DTOF
        dtof_param
        dtof_res_ps
        dtof_mean
        dtof_max  % for normlizing counts or cri
        dtof_tot
        dtof_stat % other stat
        dtof_baseline
        dtof % histogram x timestamp (or exp conditions) x channels
        tau
        tau_ch % channel-optimized tau range. cell array since the length varies. 
        
        % normalizer
        normalizer
        laser
    end
    
    methods
        function m = mdata(filename)
            
            if nargin > 0
                    
                m.import_Juliet_H5(filename);
                
            end
            
        end
        
    end
            
end
