function [mean_r, std_r] = stat_every(r, num, dim)

    if nargin < 3
        dim = 1; % average or std along row directions.
    end

    if dim > 2
        error('Invalid dimension for statistics');
    end

    if ~ismatrix(r)
        error('Input is not a matrix');
    end

    if dim == 1
        r = r';
    end

    [n_bin, n_exp] = size(r);
    if n_exp < num
        error('n_exp is less than n_avg.');
    end
    
    if mod(n_exp, num) ~= 0
        n_exp = floor(n_exp/num)*num;
        r = r(:, n_exp);
        disp(['Size of cols (or # of experiments) is not divisible. Adjusted to ', num2str(n_exp)]);
    end


    re = reshape(r, n_bin, num, []);

    mean_r = reshape(mean(re, 2), n_bin, []);
    std_r = reshape( std(re, 0, 2), n_bin, []); % 0 in std function means normalization by (N-1)

    if dim == 1
        mean_r = mean_r';
        std_r =  std_r';
    end
 
end