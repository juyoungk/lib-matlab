function load_roiData_save(g, mat_fname)
% Open saved roiData mat file and create roiData object with given 'cc'.
    
    if ~isempty(mat_fname)
        
        S = load(mat_fname);
        % S should have a field name 'cc', 'c', 'c_note', 'roi_review'

        if isfield(S, 'cc')
            g.cc = S.cc;
            disp('gData: ROI (cc) was defined. [roiDATA g.rr].');

            if isfield(S, 'c')
                g.rr.load_c(S.c, S.c_note, S.roi_review);
                disp('gData: Cluster data was loaded for g.rr roiDATA.');
            end
            if isfield(S, 'ex_stim')
                g.rr.load_ex1(S.ex_stim);
            end
            if isfield(S, 'avg_stim_plot')
                g.rr.avg_stim_plot = S.avg_stim_plot;
            end 

        end % cc end
        
    else
        
        disp('Empty file name.');
        
    end

    
    
end