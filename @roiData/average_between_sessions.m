function average_between_sessions(r, session_ids, duration)

if nargin < 3
end

r.avg_trigger_times = r.sess_trigger_times(session_ids);
r.avg_duration = duration;

str = strrep(['between_sess_', num2str(session_ids)], ' ', '_');
r.avg_analysis_name = str;

r.avg_FLAG = true;
r.average_analysis;

end