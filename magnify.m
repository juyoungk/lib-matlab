function magnify(mag, varargin)
% magnify size of the image
% magnify(mag)
% magnify(mag, gca) or magnify(mag, ax)

nVarargs = numel(varargin);
if nVarargs < 1
    ax = gca;
elseif nVarargs == 1
    ax = varargin{1};
end

pos = get(ax, 'position'); 
pos(3) = pos(3)*mag; pos(4) = pos(4)*mag; 
set(ax, 'position', pos);

end