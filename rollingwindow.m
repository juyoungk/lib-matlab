function B = rollingwindow(A, window_size)


[rows, cols] = size(A);

numWin = cols - window_size + 1;

B = zeros(rows, window_size, numWin);

for i=1:numWin
    B(:,:,i) = A(:, i:(i+window_size-1) );
end


end