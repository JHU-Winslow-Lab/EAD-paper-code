clc;clear;
% calculate the upper and lower bound:
load('LQTS1_mutation.mat');
NumCells = [1,38,52,56,56,56;1,94,96,97,97,97;1,25,24,23,23,23;1,18,18,18,18,18;1,24,23,24,24,24;1,34,35,36,36,36;1,27,26,25,25,25;1,25,25,24,24,24;1,26,27,27,27,27;1,37,39,34,34,34;1,21,21,20,20,20;1,17,20,19,19,19;1,24,24,24,24,24;1,28,30,28,28,28;1,26,26,25,25,25;1,27,29,30,30,30;1,25,32,25,25,25;1,25,30,26,26,26;1,25,28,27,27,27];
% format of LQTS1 data
% exp current | t_act | t_deact | deltaV | k | Gmax
LQTS1_data_mean = RawData(:,[1 3 5 7 9 11]);
LQTS1_data_se   = RawData(:,[2 4 6 8 10 12]);

% convert se -> sd
LQTS1_data_se      = LQTS1_data_se.*sqrt(NumCells);
LQTS1_data_se(:,1) = LQTS1_data_se(:,1)/LQTS1_data_mean(1,1);
LQTS1_data_se(:,2) = LQTS1_data_se(:,2)/LQTS1_data_mean(1,2);
LQTS1_data_se(:,3) = LQTS1_data_se(:,3)/LQTS1_data_mean(1,3);
LQTS1_data_se(:,5) = LQTS1_data_se(:,5)/LQTS1_data_mean(1,5);
LQTS1_data_se(:,6) = LQTS1_data_se(:,6)/LQTS1_data_mean(1,6);
LQTS1_data_se(:,4) = LQTS1_data_se(:,4);% translation does not need to scale

LQTS1_data_mean(:,1) = LQTS1_data_mean(:,1)/LQTS1_data_mean(1,1);
LQTS1_data_mean(:,2) = LQTS1_data_mean(:,2)/LQTS1_data_mean(1,2);
LQTS1_data_mean(:,3) = LQTS1_data_mean(:,3)/LQTS1_data_mean(1,3);
LQTS1_data_mean(:,5) = LQTS1_data_mean(:,5)/LQTS1_data_mean(1,5);
LQTS1_data_mean(:,6) = LQTS1_data_mean(:,6)/LQTS1_data_mean(1,6);

LQTS1_data_mean(:,4) = LQTS1_data_mean(:,4)-LQTS1_data_mean(1,4);

mean_m2sd = LQTS1_data_mean-2*LQTS1_data_se;
mean_p2sd = LQTS1_data_mean+2*LQTS1_data_se;
mi = min(mean_m2sd);
ma = max(mean_p2sd);
%
mi(5)=0;mi(6)=0;
save('mima.mat','mi','ma')
%%
% load the previously normalized sample data (for comparison purpose)

sample_normalized = [ones(200,1) rand(200,5)];
samples = repmat(mi,200,1) + repmat((ma-mi),200,1).*sample_normalized;
% The samples will be saved into a txt file (adding 0 at the first line)

general_train = samples(1:100,:);
general_train_norm = sample_normalized(1:100,:);
save('Samples_general_train.mat','general_train','general_train_norm','mi','ma')

general_test = samples(101:200,:);
general_test_norm = sample_normalized(101:200,:);
save('Samples_general_test.mat','general_test','general_test_norm','mi','ma')

