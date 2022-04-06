function [iniinput,inioutput] = Bayes_inidata(no,experiment1,experiment2,load1,load2)
% no = number of data
% experiment = [strain stress] from experiment

% experimental data
experi_Strain1 = experiment1(:,1);
experi_Stress1 = experiment1(:,2);
experi_Strain2 = experiment2(:,1);
experi_Stress2 = experiment2(:,2);

% bounds for material parameters
sigmaL = 250; sigmaU = 260; range_sigma = [sigmaL sigmaU];
C1L = 2000; C1U = 8000; range_C1 = [C1L C1U];
gamma1L = 10; gamma1U = 100; range_gamma1 = [gamma1L gamma1U];
QinfL = 10; QinfU = 100; range_Qinf = [QinfL QinfU];
bL= 5; bU = 25; range_b = [bL bU];  

% LHS
% inputdata = rlh(no,5,1);
load('inputdat1.mat');
% load('inputdat2.mat');
% load('inputdat3.mat');
range_matrix = [range_sigma;range_C1;range_gamma1;range_Qinf;range_b];
for i = 1:size(inputdata,2)
    inputdata(:,i)  = inputdata(:,i).*(range_matrix(i,2)-range_matrix(i,1))+ range_matrix(i,1);
end
% initial input
iniinput = inputdata;

% initial ouput
inioutput = [];
for k = 1:no
    current_generation = k
    
    update_input(iniinput(k,:),load1);
    Run_job();
    % Engineering strain and stress
    [Strain1,Stress1]=Read_ODB_outputs_ele();
    % True strain and stress
    Stress1 = (1+Strain1).*Stress1;
    Strain1 = log(1+Strain1);
    err1 = lossfun(Stress1,experi_Stress1);
    
    update_input(iniinput(k,:),load2);
    Run_job();
    % Engineering strain and stress
    [Strain2,Stress2]=Read_ODB_outputs_ele();
    % True strain and stress
    Stress2 = (1+Strain2).*Stress2;
    Strain2 = log(1+Strain2);
    err2 = lossfun(Stress2,experi_Stress2);
    
    inioutput = [inioutput;[err1,err2]];
end
end