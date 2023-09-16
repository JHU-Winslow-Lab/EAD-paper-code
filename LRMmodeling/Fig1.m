% Fig1 code (Fig 1A and 1B would be blank due to the fact that they require
% large simulation data which can't be uploaded to the Gtihub).
clear;clc;close all;
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

%% load coefficient data
GLMparams = load('opt_bopt.mat');
b_opt = GLMparams.b_Gen_Trans_opt;
Quad_feats = GLMparams.Quad_feats;
params_norm_quad = params_norm;

for i=1:length(Quad_feats(:,1))
    params_norm_quad(:,5+i) = params_norm(:,Quad_feats(i,1)).*params_norm(:,Quad_feats(i,2));
end
PEAD_est = 1./(1+exp(-[ones(300,1) params_norm_quad]*b_opt));
%%
Myfontsize = 10;
figure(1);
set(gcf, 'Position',  [100, 100, 1000, 600])

%% Gen+Trans
% Train
figure(1);
subplot(2,3,1);hold on
% data = readtable('../df_V_sim26.csv');
% df_Vs = table2array(data(2:end,2:end));
% fs = data.Var1(2:end);
% fs_num =  nan(size(fs));
% for i = 1:numel(fs_num)
%     fs_num(i) = str2double(fs{i}(29:31)); % for the general test
% end
% EAD_ind = nan(size(fs_num));
% for i=1:numel(fs_num)
%     EAD_ind(i) = df_Vs(i,500)>-40;
% end
% num_sample = 100;
% N_persample = 100;
% N = nan(num_sample,1);
% EAD = nan(num_sample,1);
% 
% df_V_100s = nan(10000,1001);
% for i=1:num_sample
%     I = find(fs_num==(i-1));
%     I = I(1:N_persample);
%     df_V_100s(100*(i-1)+1:100*i,:) = df_Vs(I,:);
% end
% 
% for i=1:10000
%     if df_V_100s(i,500)>-40
%         plot(df_V_100s(i,:),'r')
%     else
%         plot(df_V_100s(i,:),'b')
%     end
% end
% 
% data = readtable('../df_V_sim29.csv');
% df_Vs = table2array(data(2:end,2:end));
% fs = data.Var1(2:end);
% fs_num =  nan(size(fs));
% for i = 1:numel(fs_num)
%     fs_num(i) = str2double(fs{i}(29:31))-100; % for the general test
% end
% EAD_ind = nan(size(fs_num));
% for i=1:numel(fs_num)
%     EAD_ind(i) = df_Vs(i,500)>-40;
% end
% num_sample = 100;
% N_persample = 100;
% N = nan(num_sample,1);
% EAD = nan(num_sample,1);
% 
% df_V_100s = nan(10000,1001);
% for i=1:num_sample
%     I = find(fs_num==(i-1));
%     I = I(1:N_persample);
%     df_V_100s(100*(i-1)+1:100*i,:) = df_Vs(I,:);
% end
% 
% for i=1:10000
%     if df_V_100s(i,500)>-40
%         plot(df_V_100s(i,:),'r')
%     else
%         plot(df_V_100s(i,:),'b')
%     end
% end
% plot([500 500],[-100 40],'black','LineWidth',2)
% xlim([0 600]);
% yticks([-100,-50,0])
% xlabel('time (ms)');ylabel('V (mV)');
% ylim([-100 49]);
% set(gca,'FontSize',Myfontsize)

%% plot the 4th sample in 2nd round
subplot(2,3,2);hold on
% data = readtable('../df_V_sim29.csv');
% df_Vs = table2array(data(2:end,2:end));
% fs = data.Var1(2:end);
% fs_num =  nan(size(fs));
% for i = 1:numel(fs_num)
%     fs_num(i) = str2double(fs{i}(29:31))-100; % for the general test
% end
% EAD_ind = nan(size(fs_num));
% for i=1:numel(fs_num)
%     EAD_ind(i) = df_Vs(i,500)>-40;
% end
% num_sample = 100;
% N_persample = 100;
% N = nan(num_sample,1);
% EAD = nan(num_sample,1);
% 
% df_V_100s = nan(10000,1001);
% for i=1:num_sample
%     I = find(fs_num==(i-1));
%     I = I(1:N_persample);
%     df_V_100s(100*(i-1)+1:100*i,:) = df_Vs(I,:);
% end
% 
% for i=301:400
%     if df_V_100s(i,500)>-40
%         plot(df_V_100s(i,:),'r')
%     else
%         plot(df_V_100s(i,:),'b')
%     end
% end
% 
% % plot([500 500],[-100 40],'black','LineWidth',2)
% xlim([0 600]);
% yticks([-100,-50,0])
% xlabel('time (ms)');ylabel('V (mV)');
% ylim([-100 49]);
% set(gca,'FontSize',Myfontsize)

%%
PEAD_train = [PEAD_Gen_train;PEAD_Trans_train];
x = [-40:0.001:20];
subplot(2,3,3);hold on
plot(x,1./(1+exp(-x)),'LineWidth',2);
plot([ones(200,1) params_norm_quad(1:200,:)]*b_opt,PEAD_train,'*','LineWidth',2);
legend({'LRM','MM'},'FontSize',Myfontsize,'location','northwest');
legend boxoff
xlabel('B^TP');
ylabel('P(EAD)');
set(gca,'FontSize',Myfontsize)

subplot(2,3,4);
hold on
plot(PEAD_train,PEAD_est(1:200),'r*','LineWidth',2);
plot([0 1],[0 1],'black','LineWidth',2);
xlabel('P(EAD) from MM');ylabel('P(EAD) from LRM');

I = find(PEAD_train>0 & PEAD_train<1);
mdl2 = fitlm(PEAD_train(I),PEAD_est(I));
r2data2 = mdl2.Rsquared.Ordinary;
text(0.02,0.95,strcat('R^2 = ',num2str(r2data2,3),' (TD)'),'FontSize',Myfontsize);
err_m = mean(abs(PEAD_est(1:200) - PEAD_train));
err_sd = std(abs(PEAD_est(1:200) - PEAD_train));
err_sm = std(abs(PEAD_est(1:200) - PEAD_train))/sqrt(200);

text(0.02,0.85,strcat('Error = ',num2str(err_m,2),'¡À',num2str(err_sm,1)),'FontSize',Myfontsize);
set(gca,'FontSize',Myfontsize)
%%
x = [-40:0.001:20];
subplot(2,3,5);hold on
plot(x,1./(1+exp(-x)),'LineWidth',2);
plot([ones(100,1) params_norm_quad(201:300,:)]*b_opt,[PEAD_Gen_test],'*','LineWidth',2);
legend({'LRM','MM'},'FontSize',Myfontsize,'location','northwest');
legend boxoff
xlabel('B^TP');
ylabel('P(EAD)');
set(gca,'FontSize',Myfontsize)

subplot(2,3,6);
hold on
plot([PEAD_Gen_test],PEAD_est(201:300),'r*','LineWidth',2);
plot([0 1],[0 1],'black','LineWidth',2);
xlabel('P(EAD) from MM');ylabel('P(EAD) from LRM');


I = find(PEAD_Gen_test>0 & PEAD_Gen_test<1);

PEAD_est_test = PEAD_est(201:300);
mdl2 = fitlm(PEAD_Gen_test(I),PEAD_est_test(I));
r2data2 = mdl2.Rsquared.Ordinary;

text(0.02,0.95,strcat('R^2 = ',num2str(r2data2,3),' (TD)'),'FontSize',Myfontsize);
err_m = mean(abs(PEAD_Gen_test - PEAD_est_test));
err_sd = std(abs(PEAD_Gen_test - PEAD_est_test));
err_sm = std(abs(PEAD_Gen_test - PEAD_est_test))/sqrt(100);
text(0.02,0.85,strcat('Error = ',num2str(err_m,2),'¡À',num2str(err_sm,1)),'FontSize',Myfontsize);
% text(0.1,0.6,strcat('Max Error = ',num2str(max(abs(P_EAD_est_gen_trans_opt_train - P_EAD_Gen_Trans)),2)));
set(gca,'FontSize',Myfontsize)

%%
annotation('textbox',[.088       .94 .04 .04],'String','a','EdgeColor','none','FontSize',25,'FontWeight','bold');
annotation('textbox',[.088+0.28  .94 .04 .04],'String','b','EdgeColor','none','FontSize',25,'FontWeight','bold');
annotation('textbox',[.088+0.562 .94 .04 .04],'String','c','EdgeColor','none','FontSize',25,'FontWeight','bold');
% 
annotation('textbox',[.088 .97-0.49 .04 .04],'String','d','EdgeColor','none','FontSize',25,'FontWeight','bold');
annotation('textbox',[.088+0.28 .97-0.49 .04 .04],'String','e','EdgeColor','none','FontSize',25,'FontWeight','bold');
annotation('textbox',[.088+0.562 .97-0.49 .04 .04],'String','f','EdgeColor','none','FontSize',25,'FontWeight','bold');

% exportgraphics(gcf,'fig1.tiff','Resolution',300);
