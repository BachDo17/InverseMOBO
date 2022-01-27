function [Pareto_x,Pareto_y,Dominated_y]=sort_Pareto(candidates,obj)
 Pareto = paretoFront(obj);
 Pareto_y = obj(Pareto,:);
 Dominated_y = setdiff(obj,Pareto_y,'rows');
 %Dominated_y = unique(Dominated_y,'rows','stable');
 ID_sol = sortID2(obj,Pareto_y);
 Pareto_x = candidates(ID_sol,:);
 %Pareto_x = unique(solution,'rows','stable');
end