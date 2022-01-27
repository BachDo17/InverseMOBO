[x,y] = meshgrid(-2:0.05:2);
x1 = meshgrid(-2:0.05:2);
x2 = -x1;
[m,n] = size(x);
for i = 1:m
    for j = 1:n
        [z1(i,j),z2(i,j)] = test_func(x(i,j),y(i,j));
        z3(i,j) = test_func(x1(i,j),x2(i,j));
    end
end
xxx1 = meshgrid(-1:0.05:1);
[xxx,yyy] = size(xxx1);
for i = 1:xxx
    for j = 1:yyy
        zzz(i,j) = test_func(xxx1(i,j),xxx1(i,j));
    end
end
surf(x,y,z1); hold on
surf(x,y,z2);
surf(x1,x2,z3);
surf(xxx1,xxx1,zzz);
hold off
xx1 = [-1:0.05:1];
xx2 = xx1;
bb = size(xx1,2);
for k = 1:bb
[ff1(k),ff2(k)] = test_func(xx1(k),xx2(k));
end
plot(ff1,ff2)