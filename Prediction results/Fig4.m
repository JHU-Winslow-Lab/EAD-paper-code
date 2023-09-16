clear;clc;close all;
table2 = readtable('Prediction_data.csv');
Table2 = table2array(table2(:,2:end));
variants = {'D611Y';'Y315C';'W305S';'G269S';'G168R';'A341E';'R591H';'T312I';'S225L';'L266P';'S349W';'Y184S';'R594Q';'R243C';'V254M';'G314S';'A341V';'WT'};

%%
Myfontsize = 15;
Myfontsize2 = 10;

%% leave-one-out cross validation
f = figure(1);
f.Position = [-1391,70,1095,909];

mdl_pred = nan(18,1);
for i=1:18
    X = [Table2(:,3) Table2(:,5) Table2(:,7) Table2(:,9)];
    Y = Table2(:,1);
    
    X(i,:) = [];
    Y(i) = [];
    X_pred = [1 Table2(i,3) Table2(i,5) Table2(i,7) Table2(i,9)];
    mdl = fitlm(X,Y);
    mdl_pred(i) = X_pred*mdl.Coefficients.Estimate;
end
subplot(2,2,1);
plot(mdl_pred,Table2(:,1),'black.','Marker','.','MarkerSize',25);grid on
for i=1:18
    text(mdl_pred(i)+0.02,Table2(i,1)+0.01,variants{i});
end
xlabel('Predicted 30-year event rate');ylabel('30-year event rate');
[r,p] = corr(mdl_pred,Table2(:,1),'Type','Spearman');

mdl = fitlm(mdl_pred,Table2(:,1));
r2data = mdl.Rsquared.Ordinary;
p = mdl.Coefficients.pValue(2);
errmean = sum(abs(mdl_pred-Table2(:,1)))/18;
errsd = std(abs(mdl_pred-Table2(:,1)));
sem = std(abs(mdl_pred-Table2(:,1)))/sqrt(length(mdl_pred));
text(0,0.97,'Err = 0.079 ± 0.014','FontSize',Myfontsize,'HorizontalAlignment','left');
text(0,0.9,'Spearman rank = 0.84','FontSize',Myfontsize,'HorizontalAlignment','left');

xticks(0:0.2:1);
yticks(0:0.2:1);
xlim([-0.05 1.05]);
ylim([-0.05 1.05]);
text(1.05,1.12,'Pearson R^2 = 0.83, P < 0.001','FontSize',Myfontsize,'HorizontalAlignment','right');

set(gca,"fontsize",Myfontsize2)

err_full = abs(mdl_pred-Table2(:,1));
%%
mdl_pred = nan(18,1);
for i=1:18
    X = [Table2(:,7) Table2(:,9)];
    Y = Table2(:,1);
    
    X(i,:) = [];
    Y(i) = [];
    X_pred = [1 Table2(i,7) Table2(i,9)];
    mdl = fitlm(X,Y);
    mdl_pred(i) = X_pred*mdl.Coefficients.Estimate;
    
end

subplot(2,2,2);
plot(mdl_pred,Table2(:,1),'black.','Marker','.','MarkerSize',25);grid on
for i=1:18
    text(mdl_pred(i)+0.02,Table2(i,1)+0.01,variants{i});
end
xlabel('Predicted 30-year event rate');ylabel('30-year event rate');
[r,p] = corr(mdl_pred,Table2(:,1),'Type','Spearman');

mdl = fitlm(mdl_pred,Table2(:,1));
r2data = mdl.Rsquared.Ordinary;
p = mdl.Coefficients.pValue(2);

errmean = sum(abs(mdl_pred-Table2(:,1)))/18;
errsd = std(abs(mdl_pred-Table2(:,1)));
sem = std(abs(mdl_pred-Table2(:,1)))/sqrt(length(mdl_pred));

text(0,0.97,'Err = 0.132 ± 0.018','FontSize',Myfontsize,'HorizontalAlignment','left');
text(0,0.9,'Spearman rank = 0.75','FontSize',Myfontsize,'HorizontalAlignment','left');

xticks(0:0.2:1);
yticks(0:0.2:1);
xlim([-0.05 1.05]);
ylim([-0.05 1.05]);
text(1.05,1.12,'Pearson R^2 = 0.60, P < 0.001','FontSize',Myfontsize,'HorizontalAlignment','right');

set(gca,"fontsize",Myfontsize2)
err_pead = abs(mdl_pred-Table2(:,1));
%%
mdl_pred = nan(18,1);
for i=1:18
    X = [Table2(:,3) Table2(:,5) Table2(:,9)];
    Y = Table2(:,1);
    
    X(i,:) = [];
    Y(i) = [];
    X_pred = [1 Table2(i,3) Table2(i,5) Table2(i,9)];
    mdl = fitlm(X,Y);
    mdl_pred(i) = X_pred*mdl.Coefficients.Estimate;
end
subplot(2,2,3);
plot(mdl_pred,Table2(:,1),'black.','Marker','.','MarkerSize',25);grid on
for i=1:18
    text(mdl_pred(i)+0.02,Table2(i,1)+0.01,variants{i});
end
xlabel('Predicted 30-year event rate');ylabel('30-year event rate');
[r,p] = corr(mdl_pred,Table2(:,1),'Type','Spearman');

mdl = fitlm(mdl_pred,Table2(:,1));
r2data = mdl.Rsquared.Ordinary;
p = mdl.Coefficients.pValue(2);
% text(0.1,0.85,strcat('R^2 = ',num2str(r2data,3)),'FontSize',Myfontsize);
% text(0.1,0.7,strcat('p value = ',num2str(p,3)),'FontSize',Myfontsize);

errmean = sum(abs(mdl_pred-Table2(:,1)))/18;
errsd = std(abs(mdl_pred-Table2(:,1)));
sem = std(abs(mdl_pred-Table2(:,1)))/sqrt(length(mdl_pred));

text(0,0.97,'Err = 0.135 ± 0.026','FontSize',Myfontsize,'HorizontalAlignment','left');

xticks(0:0.2:1);
yticks(0:0.2:1);
xlim([-0.05 1.05]);
ylim([-0.05 1.05]);
text(1.05,1.12,'R^2 = 0.48, P = 0.001','FontSize',Myfontsize,'HorizontalAlignment','right');

set(gca,"fontsize",Myfontsize2)
err_ap = abs(mdl_pred-Table2(:,1));

%%
mdl_pred = nan(18,1);
for i=1:18
    X = [Table2(:,3) Table2(:,5) Table2(:,7)];
    Y = Table2(:,1);
    
    X(i,:) = [];
    Y(i) = [];
    X_pred = [1 Table2(i,3) Table2(i,5) Table2(i,7)];
    mdl = fitlm(X,Y);
    mdl_pred(i) = X_pred*mdl.Coefficients.Estimate;
end
subplot(2,2,4);
plot(mdl_pred,Table2(:,1),'black.','Marker','.','MarkerSize',25);grid on
for i=1:18
    text(mdl_pred(i)+0.02,Table2(i,1)+0.01,variants{i});
end
xlabel('Predicted 30-year event rate');ylabel('30-year event rate');
[r,p] = corr(mdl_pred,Table2(:,1),'Type','Spearman');

mdl = fitlm(mdl_pred,Table2(:,1));
r2data = mdl.Rsquared.Ordinary;
p = mdl.Coefficients.pValue(2);
errmean = sum(abs(mdl_pred-Table2(:,1)))/18;
errsd = std(abs(mdl_pred-Table2(:,1)));
sem = std(abs(mdl_pred-Table2(:,1)))/sqrt(length(mdl_pred));

text(0,0.97,'Err = 0.197 ± 0.029','FontSize',Myfontsize,'HorizontalAlignment','left');

xticks(0:0.2:1);
yticks(0:0.2:1);
xlim([-0.05 1.05]);
ylim([-0.05 1.05]);
text(1.05,1.12,'R^2 = 0.16, P = 0.10','FontSize',Myfontsize,'HorizontalAlignment','right');

set(gca,"fontsize",Myfontsize2)
err_tpr = abs(mdl_pred-Table2(:,1));

annotation('textbox',[.0809  .9356 .04 .04],'String','a','EdgeColor','none','FontSize',25,'FontWeight','bold');
annotation('textbox',[.5206  .9356 .04 .04],'String','b','EdgeColor','none','FontSize',25,'FontWeight','bold');
annotation('textbox',[.0809  .4606 .04 .04],'String','c','EdgeColor','none','FontSize',25,'FontWeight','bold');
annotation('textbox',[.5206  .4606 .04 .04],'String','d','EdgeColor','none','FontSize',25,'FontWeight','bold');
% exportgraphics(gcf,'fig4.tiff','Resolution',300);
%%
ranksum(err_full,err_pead)
ranksum(err_full,err_ap)
ranksum(err_full,err_tpr)



