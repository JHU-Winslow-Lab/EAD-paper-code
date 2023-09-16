%% load the simulation data and estimate the P(EAD) based on realizations.
% load data
num_sample = 100;
data = readtable('df_V_sim42.csv');
df_Vs = table2array(data(2:end,2:end));
fs = data.Var1(2:end);
fs_num =  nan(size(fs));
for i = 1:numel(fs_num)
    fs_num(i) = str2double(fs{i}(29:31));
end

EAD_ind = nan(size(fs_num));
for i=1:numel(fs_num)
    EAD_ind(i) = df_Vs(i,500)>-40;% criteria for defining EAD occurence
end

N_persample = 100;
N = nan(num_sample,1);
EAD = nan(num_sample,1);
for i=1:num_sample
    I = find(fs_num==(i-1));
    I = I(1:N_persample);
    N(i) = N_persample;%sum(fs_num==(i-1));
    EAD(i) = sum(EAD_ind(I));

end

PEAD = EAD./N;

figure;hold on
for i=1:numel(fs_num)
    if EAD_ind(i)==0
        plot(df_Vs(i,:),'b')
    else
        plot(df_Vs(i,:),'r')
    end
end


save('General_train_EAD.mat','PEAD','EAD','N');