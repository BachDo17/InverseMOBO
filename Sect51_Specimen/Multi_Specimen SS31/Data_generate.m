clc; clear all; close all

% bounds for material parameters
sigmaL = 250; sigmaU = 260;
C1L = 2000; C1U = 8000;
gamma1L = 10; gamma1U = 100;
QinfL = 10; QinfU = 100;
bL= 5; bU = 25; 

% number of samples and randomseed
no = 10;
seed = 200;

% generate samples uniformly
sigma_f = pdf_Uniform(no,[sigmaL,sigmaU], seed);
C1_f = pdf_Uniform(no,[C1L,C1U], seed);
gamma1_f = pdf_Uniform(no,[gamma1L,gamma1U], seed);
Qinf_f = pdf_Uniform(no,[QinfL,QinfU], seed);
b_f = pdf_Uniform(no,[bL,bU], seed);
inputdata = [sigma_f C1_f gamma1_f Qinf_f b_f];

%storing matrices
store_strain = cell(1,no); %rotation
store_stress = cell(1,no); %moment
store_history_ener = cell(1,no);%step-by-step energy
store_ener = zeros(no,1);%energy
%store_backbone = cell(1,no);%backbone curve
for k = 1:no
    update_input(inputdata(k,:));
    Run_job();
    % Engineering strain and stress
    [Strain,Stress]=Read_ODB_outputs_ele();
    % True strain and stress
    Stress = (1+Strain).*Stress;
    Strain = log(1+Strain);
    [ener,history_ener] = energy(Strain,Stress);
    store_strain{k} = Strain;
    store_stress{k} = Stress;
    store_history_ener{k} = history_ener;
    store_ener(k) = ener;
    [x_sort,y_sort] = backbone(store_strain{k},store_stress{k});
    %store_backbone{k} = [x_sort,y_sort];
end
for k = 1:no
    plot(store_strain{k},store_stress{k});
    hold on
end
experiment = xlsread('Experiments.xlsx','SS2');
experi_Strain = experiment(:,1);
experi_Stress = experiment(:,2);
