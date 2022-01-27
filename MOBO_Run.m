%%%% Bach Do & Makoto Ohsaki, Kyoto University
%%%% Proximal exploration multi-objective Bayesian optimization for inverse 
%%%% identification of cyclic constitutive law of structural steels
%%%% (Submitted to SMO)
% MOBO for test problem Section 4.

clc; clear all; close all;
tic;

% generate initial samples
no = 10; % number of samples
[input,output] = Bayes_inidata(no); % generate samples
u_input = input;
u_output = output;

% reference point
ref_point = [5,5];

% sort solutions and evaluate Hypervolume
[iniPareto_x,iniPareto_y,iniDominated_y]=sort_Pareto(u_input,u_output); % sort solutions
x_0 = sort_compro(iniPareto_x,iniPareto_y); % best compromise solution
ini_HV = Hypervolume(iniPareto_y,ref_point); % Hypervolume

% MOBO setting
iter_max = 20; % limit of number of MOBO iterations - 1st stopping condition
Beta = 0.01; % parameter Beta (Eq. (12) of the manuscript)
tole_eval = 0; % 2nd stopping condition

% Cells recording optimization results
store_Pareto_x = cell(iter_max,1);
store_Pareto_y = cell(iter_max,1);
store_Dominated_y = cell(iter_max,1);
store_HV = zeros(iter_max,1);

store_Pareto_x{1} = iniPareto_x;
store_Pareto_y{1} = iniPareto_y;
store_Dominated_y{1} = iniDominated_y;
store_HV(1) = ini_HV;

int_plot = 1; % parameter for tracking stoping condition
added_x = []; added_y = []; % additional samples

addpath(genpath('GP')); % DACE toolbox
% Main loop
for k = 2:iter_max
    currentIteration_optimization = k;
    % call GP
    d1 = size(u_input,2);
    theta0 = 10*ones(1,d1);
    lob0 = 10^-3*ones(1,d1);
    upb0 = 20*ones(1,d1);
    GP1 = dacefit(u_input,u_output(:,1),@regpoly0,@corrgauss,theta0,lob0,upb0);
    GP2 = dacefit(u_input,u_output(:,2),@regpoly0,@corrgauss,theta0,lob0,upb0);
    % maximize aquisition function
    lb = [-2,-2];
    ub = [2,2];
    ei_fun = @(x)-acquisition_ei(x,store_Pareto_y{k-1},ref_point,GP1,GP2,Beta,x_0,lb,ub);
    % GA parameters
    initialPoint = 0.5*(lb+ub);
    objective = ei_fun;
    nvars = 2;
    bound = [lb; ub];
    populationSize = 200;
    stallGenLimit = 20;
    generations = 50;
    options = optimoptions('ga','ConstraintTolerance',1e-6,...
        'InitialPopulationRange',bound,'MaxGenerations',generations,...
        'PopulationSize',populationSize,'MaxStallGenerations',stallGenLimit,...
        'CrossoverFraction',0.65,...
        'EliteCount',2,...
        'FunctionTolerance',10^-12,...
        'Display','iter',... 
        'PlotFcn', @gaplotbestf);
    [input_new,efal] = ga(objective,nvars,[],[],[],[],lb,ub,[],options);
    % new design variables
    added_x = [added_x;input_new];
    if efal==tole_eval
		int_plot = k-1;
        break;
	else
		int_plot = k;
		% new objective values
		[ff1,ff2] = test_func(input_new(1),input_new(2));
		output_new = [ff1,ff2];
		added_y = [added_y;output_new];
		% update data
		u_input = [u_input;input_new];
		u_output = [u_output;output_new];
		% update solution
		[curPareto_x,curPareto_y,curDominated_y]=sort_Pareto(u_input,u_output); % sort solutions
		x_0 = sort_compro(curPareto_x,curPareto_y); % best compromise solution
		cur_HV = Hypervolume(curPareto_y,ref_point); % Hypervolume
        
		store_Pareto_x{k} = curPareto_x;
		store_Pareto_y{k} = curPareto_y;
		store_Dominated_y{k} = curDominated_y;
		store_HV(k) = cur_HV;	
    end   
end
hold off
time_run = toc;
% Post process
save('Test_Run20.mat');
fg1 = figure('Color',[1 1 1]);
plot(1:int_plot,store_HV(1:int_plot));

fg2 = figure('Color',[1 1 1]);
F1 = [0 2*sqrt(2)]; 
F2 = [2*sqrt(2),0]; 
axes1 = axes('Parent',fg2);
hold(axes1,'on');
line(F1,F2,'LineWidth',2,'Color',[0 0.498039215803146 0])
plot(output(:,1),output(:,2),'MarkerSize',8,'Marker','o','LineWidth',1,'LineStyle','none',...
    'MarkerFaceColor',[0.501960813999176 0.501960813999176 0.501960813999176],'MarkerEdgeColor',[0 0 0]);
% Create xlabel
xlabel('{\itf}_1 ({\bfx})');
xlim(axes1,[0 5]);
% Create ylabel
ylabel('{\itf}_2 ({\bfx})');
ylim(axes1,[0 5]);
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'FontName','Times New Roman','FontSize',14,'XTick',[0 1 2 3 4 5],...
    'YTick',[0 1 2 3 4 5]);
plot(added_y(:,1),added_y(:,2),...
    'MarkerFaceColor',[0.850980401039124 0.325490206480026 0.0980392172932625],...
    'MarkerEdgeColor',[0 0 0],...
    'MarkerSize',10,...
    'Marker','o',...
    'LineWidth',1,...
    'LineStyle','none',...
    'Color',[0 0 0]);
