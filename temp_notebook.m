%%
%figure;
Nsampling = 100;
repeats = 20;
for Nsampling = [80, 160, 1000, 2000]
    a = rand(Nsampling, repeats);
    a = normc(a);
    aa = std(a, 1, 2);
    mean(aa)
end

%% Poisson random numbers
i =1;
l_values = [1, 10, 20, 40, 80, 160, 1000, 2000];
N_sampling = 100;
repeats = 1000;
figure
for lambda = l_values
    
    %lambda = 1000;
    a = poissrnd(lambda, N_sampling, repeats);
    a= normc(a);
      
%     subplot(1, length(l_values), i);
%     plot( mean(a, 2) );
    i = i + 1;
    
    aa = std(a, 1, 2);
    mean(aa)
end


%% 
a = [1, 1; 2, 2];
b = [1:5; 1:5];

d = cdist(a, b.')

function d = cdist(a, b)
% a, b should be a matrix of [n_exp, n_variables].
% output d - all distances between elements in a and elements in b

if size(a, 2) ~= size(b, 2)
    error('Variable [observation] numbers (dim 2) of inputs mismatch.');
end

d = zeros(size(a,1)*size(b,1),1);
n_a = size(a, 1);
n_b = size(b, 1);

for i = 1:n_a
    dd = b - a(i, :);
    dd = dd.*dd; % dx^2, dy^2
    dd = sqrt(sum(dd, 2));
    
    % id
    init = (i-1)*n_b + 1;
    d(init:init+n_b-1) = dd;
end

end
