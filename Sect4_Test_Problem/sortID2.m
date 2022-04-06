function IDs = sortID2_(obj,Pareto_y)
n = size(obj,1);
m = size(Pareto_y,1);
IDs = [];
for i = 1:m
    for j = 1:n
        if Pareto_y(i,1) == obj(j,1) && Pareto_y(i,2) == obj(j,2)
            IDs = [IDs;j];
        end
    end
end
end