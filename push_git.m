function push_git(varargin)

p = ParseInput(varargin{:});
commit_msg = p.Results.comment;

eval('!git add -A')
eval(['!git commit -am ', commit_msg])
eval('!git push')

end

function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    addParamValue(p,'comment', 'my_Macbook_pro');
    
%     addParamValue(p,'barWidth', 100, @(x)x>=0);
%     addParamValue(p,'barSpeed', 1.4, @(x)x>=0);
%     addParamValue(p,'barColor', 'dark', @(x) strcmp(x,'dark') || ...
%         strcmp(x,'white'));
%      
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end