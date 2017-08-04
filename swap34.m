function dataByCH = swap34(data)
%
% change [row col ch frames] to [row col frames ch]
%
if ndims(data) ~= 4
    disp('dn: swap34: dims of data is not 4');
    return
end

data = double(data);

[ynum, xnum, ch, frames] = size(data);
text = sprintf('[row col ch frames] = [%d\t%d\t%d\t%d]',ynum,xnum,ch,frames);
fprintf('%s\n', text);

% Channel index goes to the last using reshape
newData = zeros(ynum,xnum,frames,ch);
for i = 1:ch
    newData(:,:,:,i) = reshape(data(:,:,i,:),ynum,xnum,frames);
end
[ynum, xnum, frames, ch] = size(newData);
text = sprintf('[row col frames ch] = [%d\t%d\t%d\t%d]',ynum,xnum,frames,ch);
fprintf('%s : ch index is changed to last..\n', text);

dataByCH = newData;

end