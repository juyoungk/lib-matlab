function average_between_sessions(r, session_ids, duration)

if nargin < 3
end

r.avg_trigger_times = r.sess_trigger_times(session_ids);
r.avg_duration = duration;

r.avg_FLAG = true;
r.average_analysis;

end