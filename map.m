close all;clear all;clc;
addpath m_map
load('GlobalCluster.mat')
figure(1); 
plot(Areaper*100);
xlabel('Number of Clusters','fontsize',20);
ylabel('Percent Area Covered','fontsize',20);
print -dpdf -r600 Area.pdf


%% load grid formation
x = rdmds('XC');
y = rdmds('YC');
z = rdmds('RC');
z = squeeze(z);
dx = rdmds('DXG');
dy = rdmds('DYG');
dz = rdmds('DRF');
da = rdmds('RAC');
hc = rdmds('hFacC');
dz3d = repmat(dz,[360 160 1]).*hc;
dv = repmat(da,[1 1 23]).*repmat(dz,[360 160 1]).*hc;
x2 = x;
y2 = y;
x2(end+1,:)= x2(end,:)+1;
y2(end+1,:)= y2(1,:);


Cumul_Area(1) = 0;
for i = 1:50
 Cumul_Area(i+1) = Cumul_Area(i) + Areaper(i)*100 
end
figure(2); 
plot(Cumul_Area(2:51));
xlabel('Numbers of Cluster','fontsize',20);
ylabel('Cumulative Percent Area Covered','fontsize',20);
% xlim([1 50])
print -dpdf -r600 Cum_Area.pdf




figure(3);
pcolor(map'); shading flat; colorbar;
caxis([1 8])

figure(4);
pcolor(map'); shading flat; colorbar;
caxis([1 10])

figure(5);
pcolor(map'); shading flat; colorbar;
caxis([1 36])
% colormap parula
print -dpdf -r600 map1000_5.pdf
print -djpeg -r600 map1000_5.jpg



figure(6);
a = [15:1:21];
bar(a,C2(15:21,:),'grouped'); legend(lab);
ylabel('Normalized magnitude of the dFe flux','fontsize',20);
xlabel('Cluster','fontsize',20);
print -dpdf -r600 Cluster1000_6.pdf
print -djpeg -r600 Cluster1000_5.jpg


load('Criteria.mat');
plot(BIC);
xlabel('Numbers of Cluster','fontsize',20);
ylabel('BIC score','fontsize',20);
print -dpdf -r600 BIC.pdf
print -djpeg -r600 BIC.jpg


%% show the cruise track, dotted region is where I'm extracting 
%  the model data for interpolation later
c = map;
c(end+1,:)= c(1,:);
figure(1);
m_proj('miller','lat',[-70 70],'lon',[0 360]);
m_pcolor(x2,y2,c);
shading flat;
m_coast('patch',[.5 .5 .5]);
m_grid('xaxis','bottom','box','fancy');
caxis([1 22]);
drawnow;
%% make colorbar at the bottom
cmp=colormap('jet');
colorbartype([.1 .05 .8 .025],1:.3:22,81,[1 22],cmp,0);
ax=get(gcf,'currentaxes');
set(ax,'xtick',1:10:81);
set(ax,'xticklabel',{'1' '4' '7' '10' '13' '16' '19' '22'},'FontName','Times New Roman','FontSize',12);
title(' Cluster','FontName', 'Times New Roman','FontName','Times New Roman', 'fontsize',16); 
print -dpdf -r600 Map3_beauty.pdf


