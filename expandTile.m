function B = expandTile(A, Erow, Ecol)
% A is always 2d matrix
% E: The expansion ratio.
% or, kron(A,ones(E))

[M, N] = size(A);

if (M == 1)
    vy = ceil((1:Ecol*N)/Ecol);
    B = A(vy);
    return;
elseif (N == 1)    
    vx = ceil((1:Erow*M)/Erow);
    B = A(vx);
    return;
elseif (M > 1) 
    vx = ceil((1:Erow*M)/Erow);
    vy = ceil((1:Ecol*N)/Ecol);
    B = A(vx,vy);
    return;
else
    print "No matrix"
    return;
end
        
end


% another method?
%N = size(A,2);
%idx = cumsum(ones(E,N),2);
%B = A(idx,idx)