function avg_frames_by_triggers_in_session(g, session_id)

if nargin < 2
    session_id = [];
end

disp('Averaging frames ... ');

triggers = g.pd_events_within(session_id);

if isempty(triggers)
    disp('No trigger times were given.');
    return;
else
    fprintf('trigger = %.1f\n', triggers); 
end

reply = input('Do you want to average frames by the above trigger times? [Y]', 's');
if isempty(reply); reply = 'Y'; end

if reply == 'Y' || reply == 'y'
    g.avg_frames_by_triggers(triggers);
else
    disp('No averaging now...');
end


end