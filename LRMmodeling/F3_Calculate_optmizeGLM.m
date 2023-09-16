% clear;clc;
gen_train = load('General_train_EAD_summary.mat');
trans_train = load('Trans_train_EAD_summary.mat');
gen_test = load('General_test_EAD_summary.mat');
params = readtable('Random_samples.txt');
params = table2array(params);
load('mima.mat')

%% prepare for the data
params_norm = (params - repmat(mi,300,1))./(repmat(ma,300,1) -  repmat(mi,300,1));
params_norm = params_norm(:,2:6);
EAD_data_Gen_train   = params_norm(1:100,:);
EAD_data_Trans_train = params_norm(101:200,:);
EAD_data_Gen_test = params_norm(201:300,:);

N_Gen_train = gen_train.N;
N_Trans_train = trans_train.N;
N_Gen_test = gen_test.N;

EAD_Gen_train = gen_train.EAD;
EAD_Trans_train = trans_train.EAD;
EAD_Gen_test = gen_test.EAD;

PEAD_Gen_train = gen_train.PEAD;
PEAD_Trans_train = trans_train.PEAD;
PEAD_Gen_test = gen_test.PEAD;

%%
EAD_Para_norm = [EAD_data_Gen_train;EAD_data_Trans_train];
EAD = [EAD_Gen_train;EAD_Trans_train];N = [N_Gen_train;N_Trans_train];

num = 5;
F2nd = nan(200,nchoosek(num+1,2));
C = combnk([1:num+1],2);
for i=1:nchoosek(num+1,2)
    if (C(i,1)==(num+1))
        C(i,1) = C(i,2);
    elseif (C(i,2)==(num+1))
        C(i,2) = C(i,1);
    end
    F2nd(:,i) = EAD_Para_norm(:,C(i,1)).*EAD_Para_norm(:,C(i,2));
end

F = cell(2^nchoosek((num+1),2),1);
F{1} = EAD_Para_norm;
ind_F = 2;
C2_record = cell(2^nchoosek((num+1),2),1);
C2_record{1}=[];
for i=1:nchoosek(num+1,2)
    C2 = combnk([1:nchoosek(num+1,2)],i);
    for j = 1:nchoosek(nchoosek(num+1,2),i)
        F{ind_F} = [EAD_Para_norm F2nd(:,C2(j,:))];
        C2_record{ind_F} = C2(j,:);
        ind_F=ind_F+1;
    end
end

R_2_collection = cell(2^nchoosek((num+1),2),1);
Coef_collection =  cell(2^nchoosek((num+1),2),1);
IC_collection = cell(2^nchoosek((num+1),2),1);

tic;
parfor i=1:2^nchoosek((num+1),2)
    mdl = fitglm(F{i},[EAD N],'linear','Distribution','binomial');
    R_2_collection{i} = mdl.Rsquared;
    Coef_collection {i} = mdl.Coefficients;
    IC_collection{i} = mdl.ModelCriterion;
end
toc;

ICtable = nan(2^nchoosek((num+1),2),4);
R2adj = nan(2^nchoosek((num+1),2),1);

for i=1:2^nchoosek((num+1),2)
    ICtable(i,1) = IC_collection{i}.AIC;
    ICtable(i,2) = IC_collection{i}.AICc;
    ICtable(i,3) = IC_collection{i}.BIC;
    ICtable(i,4) = IC_collection{i}.CAIC;
    R2adj(i) = R_2_collection{i}.Adjusted;
end
%% find the optimal number for Gen+Trans
[~,I_opt_F] = min(ICtable);
b_Gen_Trans_opt = table2array(Coef_collection{I_opt_F(4)}(:,1));
P_EAD_est_gen_trans_opt_train = 1./(1+exp(-[ones(200,1) F{I_opt_F(4)}]*b_Gen_Trans_opt));
Quad_feats = C(C2_record{I_opt_F(4)},:);

EAD_data_Gen_test_opt = EAD_data_Gen_test;

for i=1:length(Quad_feats(:,1))
    EAD_data_Gen_test_opt(:,5+i) = EAD_data_Gen_test(:,Quad_feats(i,1)).*EAD_data_Gen_test(:,Quad_feats(i,2));
end

P_EAD_est_gen_opt_test = 1./(1+exp(-[ones(100,1) EAD_data_Gen_test_opt]*b_Gen_Trans_opt));
%%
coefs = Coef_collection{I_opt_F(4)};
save('opt_bopt.mat','b_Gen_Trans_opt','Quad_feats','coefs');
%%
figure;hold on
plot(PEAD_Gen_test,P_EAD_est_gen_opt_test,'o')
plot([0 1],[0 1],'k')
grid on
xlabel('actual P(EAD) in test set');
ylabel('predicted P(EAD) in test set');
