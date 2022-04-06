function err = lossfun(M_FEM,M_exp)
n = size(M_FEM,1);
err = 0;
for k = 1:n
    err = err + (M_FEM(k)-M_exp(k))^2;
end
err = sqrt(err/n);
end