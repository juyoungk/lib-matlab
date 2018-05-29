function B = rollingwindow1d(A, window_size)
% A should be row vector
N = length(A);
X = hankel(1:window_size, window_size:N).';
B = A(X);

end