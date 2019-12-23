function normed = normalize(m, raw)
% provides various normalized outputs for given raw trace.

% default normalizer: dtof_max
normed.dtof_max = raw./m.dtof_max;


% user-defined normalizer
fields = fieldnames(m.normalizer);

for id = 1:length(fields)
    field = fields{id};
    normed.(field) = raw./m.normalizer.(field);
end


end