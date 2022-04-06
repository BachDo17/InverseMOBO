function [x_compro,y_compro] = sort_compro(Par_x,Par_y)
N = size(Par_x,1);
M = size(Par_y,2);
x_compro = Par_y(1,:);
y_compro = Par_x(1,:);
min_y = min(Par_y);
max_y = max(Par_y);
if N <=2
    x_compro = Par_x(1,:);
    y_compro = Par_y(1,:);
else
    for i = 1:N
        for j = 1:M
            if Par_y(i,j)==min_y(:,j)
                muy(i,j)  = 1;
            elseif Par_y(i,j)==max_y(:,j)
                muy(i,j)  = 0;
            else
                muy(i,j) = (max_y(:,j)-Par_y(i,j))/(max_y(:,j)-min_y(:,j));
            end
        end
    end
    sum_total = sum(sum(muy));
    for i = 1:N
        normalized_muy(i,1) = sum(muy(i,:))/sum_total;
    end
    [~,ide] = max(normalized_muy);
    x_compro = Par_x(ide,:);
    y_compro = Par_y(ide,:);
end
end