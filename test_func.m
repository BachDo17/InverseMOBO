function [y1,y2] = test_func(x1,x2)
x = [x1,x2];
one_m = [1,1];
y1 = norm(x-one_m);
y2 = norm(x+one_m);
end