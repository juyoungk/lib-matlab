function Aout = stackRGB(a, R, G, B)
%
% Aout = stackRGB(a, R, G, B);
%  Input    (a) structure: [rox, col, ch, frames]
% Output (Aout) structure: [rox, col, 3(RGB), frames], Ch-normalized.
% Make truecolor RGB image stack from multi-channel image stack

a = ch_normalize(a);

if isempty(R) || ~isscalar(R)
    Rstack = zeros(size(a(:,:,1,:)));
else
    Rstack = a(:,:,R,:);
end

if isempty(G) || ~isscalar(G)
    Gstack = zeros(size(a(:,:,1,:)));
else
    Gstack = a(:,:,G,:);
end

if isempty(B) || ~isscalar(B)
    Bstack = zeros(size(a(:,:,1,:)));
else
    Bstack = a(:,:,B,:);
end

Aout = cat(3, Rstack, Gstack, Bstack);

[row, col, colors, frames] = size(Aout);
text = sprintf('[row col colors frames] = [%d\t%d\t%d\t%d]\n',row,col,colors,frames);

disp(text);

implay(Aout);

end