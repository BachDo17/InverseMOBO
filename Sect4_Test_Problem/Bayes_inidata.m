function [iniinput,inioutput] = Bayes_inidata(no)
% no = number of data

% bounds for material parameters
range_x1 = [-2 2];
range_x2 = [-2 2];  

% LHS
inputdata = rlh(no,2,0);
range_matrix = [range_x1;range_x2];
for i = 1:size(inputdata,2)
    inputdata(:,i)  = inputdata(:,i).*(range_matrix(i,2)-range_matrix(i,1))+ range_matrix(i,1);
end
% initial input
iniinput = inputdata;
% initial ouput
inioutput = [];
for k = 1:no
    current_generation = k
    [f1,f2] = test_func(iniinput(k,1),iniinput(k,2));
    inioutput = [inioutput;[f1,f2]];
end
end