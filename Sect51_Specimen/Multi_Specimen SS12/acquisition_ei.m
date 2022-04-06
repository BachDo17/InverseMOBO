function fval = acquisition_ei(x,Pareto,ref_point,GP1,GP2,Beta,xcompro,lb,ub)
[mean_predict1, ~, var_predict1] = predictor(x,GP1);
std_predict1 = sqrt(var_predict1);
f1 = mean_predict1-Beta*std_predict1;

[mean_predict2, ~, var_predict2] = predictor(x,GP2);
std_predict2 = sqrt(var_predict2);
f2 = mean_predict2-Beta*std_predict2;

f_vector = [f1 f2];
% Current hypervolume
cur_HV = Hypervolume(Pareto,ref_point);
% Hypervolumne improvement
xnor = (x-lb)./(ub-lb);
xcomnor = (xcompro-lb)./(ub-lb);
% fval = (hypervolume([Pareto;f_vector],ref_point,100000)-cur_HV)*exp(-0.5*norm(xnor-xcomnor));
fval = (Hypervolume([Pareto;f_vector],ref_point)-cur_HV)*exp(-0.5*norm(xnor-xcomnor));
end