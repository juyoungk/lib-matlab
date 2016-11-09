function ss = nowtest
a = now;
pause(0.5);
b= now;
aa = rem(a,1);
bb = rem(b,1);
ss = bb - aa ;
ss = second(b) - second(a);

end