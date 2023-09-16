clear;clc;close all;
table2 = readtable('Prediction_data.csv');
Table2 = table2array(table2(:,2:end));

Myfontsize = 15;
Myfontsize2 = 10;

f = figure(1);
f.Position = [2031,-435,901,1405];
% tiledlayout(3,2, 'Padding', 'compact', 'TileSpacing', 'loose'); 
% nexttile
subplot(3,2,1);
plot(Table2(:,3),Table2(:,1),'black.','Marker','.','MarkerSize',25);grid on
xticks(0:0.2:1);
yticks(0:0.2:1);
xlim([-0.05 1.05]);
ylim([-0.05 1.05]);
xlabel('P_m(EAD)','FontSize',Myfontsize);ylabel('30-year event rate','FontSize',Myfontsize);
mdl = fitlm(Table2(:,3),Table2(:,1));
r2data = mdl.Rsquared.Ordinary;
p = mdl.Coefficients.pValue(2);
% text(0.1,0.85,strcat('R^2 = ',num2str(r2data,3)),'FontSize',Myfontsize);
% text(0.1,0.7,strcat('P = ',num2str(p,3)),'FontSize',Myfontsize);
variants = {'D611Y';'Y315C';'W305S';'G269S';'G168R';'A341E';'R591H';'T312I';'S225L';'L266P';'S349W';'Y184S';'R594Q';'R243C';'V254M';'G314S';'A341V';'WT'};
for i=1:18
    text(Table2(i,3),Table2(i,1)+0.03,variants{i},'HorizontalAlignment','center','VerticalAlignment','baseline');
end
text(1.05,1.12,'R^2 = 0.11,  p = 0.17','FontSize',Myfontsize,'HorizontalAlignment','right');
set(gca,"fontsize",Myfontsize2)
%%
subplot(3,2,2);
% nexttile
plot(Table2(:,5),Table2(:,1),'black.','Marker','.','MarkerSize',25);grid on
xlabel('P_m(EAD)_G');ylabel('30-year event rate');
mdl = fitlm(Table2(:,5),Table2(:,1));
r2data = mdl.Rsquared.Ordinary;
p = mdl.Coefficients.pValue(2);
xticks(0:0.2:1);
xlim([-0.05 1.05]);
ylim([-0.05 1.05]);

% text(0.1,0.85,strcat('R^2 = ',num2str(r2data,3)),'FontSize',Myfontsize);
% text(0.1,0.7,strcat('P = ',num2str(p,3)),'FontSize',Myfontsize);
text(1.05,1.12,'R^2 = 0.09,  p = 0.24','FontSize',Myfontsize,'HorizontalAlignment','right');
for i=1:18
    text(Table2(i,5),Table2(i,1)+0.03,variants{i},'HorizontalAlignment','center','VerticalAlignment','baseline');
end
set(gca,"fontsize",Myfontsize2)
%%
subplot(3,2,3);
% nexttile    
plot(Table2(:,7),Table2(:,1),'black.','Marker','.','MarkerSize',25);grid on
xlabel('AP morphology');ylabel('30-year event rate');
mdl = fitlm(Table2(:,7),Table2(:,1));
r2data = mdl.Rsquared.Ordinary;
p = mdl.Coefficients.pValue(2);

text(6.3,1.12,'R^2 = 0.04,  p = 0.44','FontSize',Myfontsize,'HorizontalAlignment','right');
for i=1:18
    text(Table2(i,7),Table2(i,1)+0.03,variants{i},'HorizontalAlignment','center','VerticalAlignment','baseline');
end
xticks(0:1:6);
yticks(0:0.2:1);
ylim([-0.05 1.05]);
xlim([-0.3 6.3]);
set(gca,"fontsize",Myfontsize2)
box on
%%
subplot(3,2,4);
% nexttile    
plot(Table2(:,9),Table2(:,1),'black.','Marker','.','MarkerSize',25);grid on
xlabel('TRP');ylabel('30-year event rate');
mdl = fitlm(Table2(:,9),Table2(:,1));
r2data = mdl.Rsquared.Ordinary;
p = mdl.Coefficients.pValue(2);
% text(0.1,0.85,strcat('R^2 = ',num2str(r2data,3)),'FontSize',Myfontsize);
% text(0.1,0.7,strcat('P = ',num2str(p,3)),'FontSize',Myfontsize);
text(53,1.12,'R^2 = 0.30,  p = 0.02','FontSize',Myfontsize,'HorizontalAlignment','right');
for i=1:18
    text(Table2(i,9),Table2(i,1)+0.03,variants{i},'HorizontalAlignment','center','VerticalAlignment','baseline');
end
xticks(-10:10:50);
yticks(0:0.2:1);
xlim([-13 53]);
ylim([-0.05 1.05]);
set(gca,"fontsize",Myfontsize2)

%% small regression model
mdl = fitlm([Table2(:,3) Table2(:,5) Table2(:,7) Table2(:,9)],Table2(:,1));

subplot(3,2,5);hold on
plot(mdl.Fitted,Table2(:,1),'black.','Marker','.','MarkerSize',25);%grid on
for i=1:18
    text(mdl.Fitted(i)+0.01,Table2(i,1),variants{i});
end
xlabel('Fitted 30-year event rate');ylabel('30-year event rate');
mdl = fitlm(mdl.Fitted,Table2(:,1));
r2data = mdl.Rsquared.Ordinary;
p = mdl.Coefficients.pValue(2);

text(1.05,1.12,'R^2 = 0.90,  p < 0.001','FontSize',Myfontsize,'HorizontalAlignment','right');  
xticks(0:0.2:1);
yticks(0:0.2:1);
xlim([-0.05 1.05]);
ylim([-0.05 1.05]);grid on
set(gca,"fontsize",Myfontsize2)
box on;

%%
annotation('textbox',[.0718  .918 .04 .04],'String','a','EdgeColor','none','FontSize',25,'FontWeight','bold');
annotation('textbox',[.5106  .918 .04 .04],'String','b','EdgeColor','none','FontSize',25,'FontWeight','bold');
annotation('textbox',[.0674  .619 .04 .04],'String','c','EdgeColor','none','FontSize',25,'FontWeight','bold');
annotation('textbox',[.5062  .619 .04 .04],'String','d','EdgeColor','none','FontSize',25,'FontWeight','bold');
annotation('textbox',[.0674  .319 .04 .04],'String','e','EdgeColor','none','FontSize',25,'FontWeight','bold');
% annotation('textbox',[.084+0.44  .93-.47 .04 .04],'String','d','EdgeColor','none','FontSize',25,'FontWeight','bold');

% exportgraphics(gcf,'fig3.tiff','Resolution',300);


