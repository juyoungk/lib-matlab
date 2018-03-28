x = 1:50;
s = double(zeros(1, 50));

for i = 1:50
    b = mean(a(:,1:i), 2);
    s(i) = std(b, 1, 1);
end



plot(log(x), log(s))
slope = log(s(end)) - log(s(1));
slope = slope/ (log(50)-log(1))


plot(1:50, s)
hold on


c = s(1)*ones(1,50);

plot( c ./ sqrt(x) );

hold off
