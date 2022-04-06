%%%% Bach Do & Makoto Ohsaki, Kyoto University
%%%% Proximal exploration multi-objective Bayesian optimization for inverse 
%%%% identification of cyclic constitutive law of structural steels
%%%% (Submitted to SMO)
% MOBO for solving identification problem in Section 5.1 - Requirement: Abaqus installed

clc;clear all;close all
% load cases
loadcase1 = 'SS1';
loadcase2 = 'SS2';

% load experimental data
experiment1 = xlsread('Experiments.xlsx',loadcase1);
strain_exp1 = experiment1(:,1);
stress_exp1 = experiment1(:,2);
experiment2 = xlsread('Experiments.xlsx',loadcase2);
strain_exp2 = experiment2(:,1);
stress_exp2 = experiment2(:,2);
tic;

% initial samples
% no = 50; % number of samples
%[input,output] = Bayes_inidata(no,experiment1,experiment2,loadcase1,loadcase2); % generate samples
load('data1.mat'); % load initial dataset (already generated)
%load('data2.mat')
%load('data3.mat')
u_input = input;
u_output = output;

% Reference point
ref_point = [150,150];

% Initial solutions and HV
[iniPareto_x,iniPareto_y,iniDominated_y]=sort_Pareto(u_input,u_output); % sort solutions
x_compro = sort_compro(iniPareto_x,iniPareto_y); % best compromise solution
ini_HV = Hypervolume(iniPareto_y,ref_point); % Hypervolume

% MOBO setting
iter_max = 50; % limit of number of MOBO iterations - 1st stopping condition
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
% amination
figure(1);
axis manual % this ensures that getframe() returns a consistent size
filename = 'AnimatedSS12_Pareto_Run1.gif';
sort_Pareto2 = sortrows(iniPareto_y,1);
plot(sort_Pareto2(:,1),sort_Pareto2(:,2)),'-o';
xlabel('{\itf}_{1} [MPa]')
ylabel('{\itf}_{2} [MPa]')
title(sprintf('Iteration: %d',1));drawnow;
hold on;
frame = getframe(1); 
im = frame2im(frame); 
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,filename,'gif','DelayTime',0.3, 'Loopcount',inf); 
int_plot = 1; % parameter for tracking stoping condition

%addpath(genpath('GP')); % DACE toolbox
% Main loop
for k = 2:iter_max
    Iteration_optimization = k
    % GPs
    d1 = size(u_input,2);
    theta0 = 10*ones(1,d1);
    lob0 = 10^-3*ones(1,d1);
    upb0 = 20*ones(1,d1);
    GP1 = dacefit(u_input,u_output(:,1),@regpoly0,@corrgauss,theta0,lob0,upb0);
    GP2 = dacefit(u_input,u_output(:,2),@regpoly0,@corrgauss,theta0,lob0,upb0);
    % Maximize aquisition function
    % bounds for material parameters
    sigmaL = 250; sigmaU = 260;
    C1L = 2000; C1U = 8000;
    gamma1L = 10; gamma1U = 100;
    QinfL = 10; QinfU = 100; 
    bL= 5; bU = 25; range_b = [bL bU];
    lb = [sigmaL,C1L,gamma1L,QinfL,bL];
    ub = [sigmaU,C1U,gamma1U,QinfU,bU];
    ei_fun = @(x)-acquisition_ei(x,store_Pareto_y{k-1},ref_point,GP1,GP2,Beta,x_compro,lb,ub);
    % GA parameters
    initialPoint = 0.5*(lb+ub);
    objective = ei_fun;
    nvars = 5;
    bound = [lb; ub];
    populationSize = 4000;
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
    if efal==tole_eval
        int_plot = k-1;
        break;
    else
    % call FEM
    update_input(input_new,loadcase1);
    Run_job();
    [Strain1,Stress1]=Read_ODB_outputs_ele();
    stress_FEM1 = (1+Strain1).*Stress1;
    err1 = lossfun(stress_FEM1,stress_exp1);
    
    update_input(input_new,loadcase2);
    Run_job();
    [Strain2,Stress2]=Read_ODB_outputs_ele();
    stress_FEM2 = (1+Strain2).*Stress2;
    err2 = lossfun(stress_FEM2,stress_exp2);
    output_new = [err1,err2];
    
    % update data
    u_input = [u_input;input_new];
    u_output = [u_output;output_new];
    
    % update solutions
    [curPareto_x,curPareto_y,curDominated_y]=sort_Pareto(u_input,u_output); % sort solutions
    x_compro = sort_compro(curPareto_x,curPareto_y); % best compromise solution
    cur_HV = Hypervolume(curPareto_y,ref_point); % Hypervolume
    
    % amination
    sort_Pareto2 = sortrows(curPareto_y,1);
    plot(sort_Pareto2(:,1),sort_Pareto2(:,2)),'-o';
    title(sprintf('Iteration: %d',k));drawnow;
    frame = getframe(1); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,filename,'gif','DelayTime',0.3,'WriteMode','append'); 
    
    store_Pareto_x{k} = curPareto_x;
    store_Pareto_y{k} = curPareto_y;
    store_Dominated_y{k} = curDominated_y;
    store_HV(k) = cur_HV;
    end
end
hold off
time_run = toc;
% Post process
save('SS12_Run1.mat');

fg1 = figure('Color',[1 1 1]);
plot(1:int_plot,store_HV(1:int_plot));

fg2 = figure('Color',[1 1 1]);
sort_Pareto2 = sortrows(store_Pareto_y{1},1); 
plot(sort_Pareto2(:,1),sort_Pareto2(:,2),'Marker','^','LineStyle',':','Color',[0 0 0]); hold on

sort_Pareto2 = [];
sort_Pareto2 = sortrows(store_Pareto_y{round((int_plot)/2,0)},1); 
plot(sort_Pareto2(:,1),sort_Pareto2(:,2),'MarkerSize',8,'Marker','square','LineStyle','--',...
    'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]); 

sort_Pareto2 = [];
sort_Pareto2 = sortrows(store_Pareto_y{int_plot},1); 
plot(sort_Pareto2(:,1),sort_Pareto2(:,2),'MarkerEdgeColor',[0 0.447058826684952 0.74117648601532],...
    'MarkerSize',8,...
    'Marker','o',...
    'LineWidth',1,...
    'Color',[0 0.447058826684952 0.74117648601532]);
% Create xlabel
xlabel('{\itf}_1 [MPa]');
% Create ylabel
ylabel('{\itf}_2 [MPa]');
hold off;

