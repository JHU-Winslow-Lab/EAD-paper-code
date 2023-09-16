load('General_train_EAD_summary_sim38.mat');

%% load parameters the 1st round parameters
load('Samples_general_train.mat')

%%
mdl_Gen = fitglm(general_train_norm,[EAD N],'linear','Distribution','binomial');
b_Gen = table2array(mdl_Gen.Coefficients(:,1));
P_EAD_est = 1./(1+exp(-[ones(100,1) general_train_norm]*b_Gen));

%% TRAIN
figure;hold on
plot(PEAD,P_EAD_est,'r*');
plot([0 1],[0 1],'black');
xlabel('P(EAD) from MM');ylabel('P(EAD) from LRM');
mdl = fitlm(PEAD,P_EAD_est);
r2data = mdl.Rsquared.Ordinary;
text(0.1,0.9,strcat('R^2 = ',num2str(r2data)));
I = find(PEAD>0 & PEAD<1);
mdl2 = fitlm(PEAD(I),P_EAD_est(I));
r2data2 = mdl2.Rsquared.Ordinary;
text(0.1,0.8,strcat('R^2(0<P(EAD)<1) = ',num2str(r2data2)));

%% generate parameter sets in transition domain
lb=0.01;
ub=0.99;
x_s = Rand_region(100,b_Gen,lb,ub);
figure;histogram(1./(1+exp(-[ones(100,1) x_s]*b_Gen)));
x_s_real = [ones(100,1) x_s].*repmat(ma-mi,100,1)+repmat(mi,100,1);

%%
trans_train_norm = x_s;
trans_train = x_s_real;
save('Samples_trans_train.mat','trans_train','trans_train_norm','mi','ma')

%%
function x_s = Rand_region(n,b,lb,ub)
    i=1;
    x_s=nan(n,5);
    %decide if we are in the 25-75% 
    while(i<=n)
        tmp = rand(1,5);
        if([1 tmp]*b>log(lb/(1-lb)) && [1 tmp]*b<log(ub/(1-ub)))
            x_s(i,:) = tmp;
            i=i+1;
            display(num2str(i));
        end
    end   
end

