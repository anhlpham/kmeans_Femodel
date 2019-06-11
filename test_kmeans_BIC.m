close all
clear all
clc;

%% load the model Fe sources and sinks
load adv_diff.mat %% advection and diffusion
load bio_sinks.mat %% biological sinks
load bio_sources.mat %% biological sources
z=rdmds('grid/RC'); %% model grid
da=rdmds('grid/RAC'); %% model grid

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% select depth level %%%
zlev=[0 -1000];
%%%%%%%%%%%%%%%%%%%%%%%%%%
K=find(z>=zlev(2)&z<=zlev(1));

%%% select basin %%%
mask=loadbin('grid/Mask-Oce-Pac.bin',[360 160]);
%%%%%%%%%%%%%%%%%%%%

% make a 1D vector
cnt=0;
for i=1:360
   for j=1:160
      if mask(i,j)==1
         cnt=cnt+1;
         xind(cnt)=i;
         yind(cnt)=j;
         area(cnt)=da(i,j);
      end
   end
end
Nb=cnt;

% make the input matrix
scav = scav+loss;
remin= FEremin + rem;
for i=1:Nb
   X(i,1)=sum(src_adv(xind(i),yind(i),K),3);
   X(i,2)=sum(src_dif(xind(i),yind(i),K),3);
   X(i,3)=sum(bio(xind(i),yind(i),K),3);
   X(i,4)=sum(scav(xind(i),yind(i),K),3);
   X(i,5)=sum(remin(xind(i),yind(i),K),3);
   X(i,6)=sum(sed(xind(i),yind(i),K),3);
   X(i,7)=sum(hyd(xind(i),yind(i),K),3);
   X(i,8)=sum(dust3d(xind(i),yind(i),K),3);
end
lab={'adv' 'dif' 'bio' 'scav' 'remin' 'sed' 'hydro' 'dust'}

% standardize the data
for i=1:8
   tmp = X(:,i);
   mu(i)=mean(tmp);
   sd(i)=std(tmp);
   Xn(:,i) = (tmp-mu(i))/sd(i);
end 

%%% Use AIC/BIC to determine the number of clusters
%%% Following Sonnewald et al., 2019 and Jones et al., 2019
%%%%%%%%%%%%%%%%%%%%
temp = 1; 
for Ncluster = 2:80;
 disp(['working on Ncluster = ',num2str(Ncluster)])
  % cluster the data
 [IDX,C]=kmeans(Xn,Ncluster,'MaxIter',500,'Replicates',5,'Display','final');
 RS1 = 0;RS2 = 0;RS3 = 0; RS4 = 0;RS5 = 0;RS6 = 0; RS7 = 0;RS8 = 0;
% RS - Residual square
 for i=1:Nb
   RS1 = RS1 + (Xn(i,1)-C(IDX(i),1))^2;
   RS2 = RS2 + (Xn(i,2)-C(IDX(i),2))^2;
   RS3 = RS3 + (Xn(i,3)-C(IDX(i),3))^2;
   RS4 = RS4 + (Xn(i,4)-C(IDX(i),4))^2;
   RS5 = RS5 + (Xn(i,5)-C(IDX(i),5))^2;
   RS6 = RS6 + (Xn(i,6)-C(IDX(i),6))^2;
   RS7 = RS7 + (Xn(i,7)-C(IDX(i),7))^2;
   RS8 = RS8 + (Xn(i,8)-C(IDX(i),8))^2;                 
 end
 RS1 = RS1/(2*sd(1)^2);RS2 = RS2/(2*sd(2)^2);
 RS3 = RS3/(2*sd(3)^2);RS4 = RS4/(2*sd(4)^2);
 RS5 = RS5/(2*sd(5)^2);RS6 = RS6/(2*sd(6)^2);
 RS7 = RS7/(2*sd(7)^2);RS8 = RS8/(2*sd(8)^2);
 L1 = -RS1+log((1/sqrt(2*pi*(sd(1)^2)))); % L - log likelihood
 L2 = -RS2+log((1/sqrt(2*pi*(sd(2)^2))));
 L3 = -RS3+log((1/sqrt(2*pi*(sd(3)^2))));
 L4 = -RS4+log((1/sqrt(2*pi*(sd(4)^2))));
 L5 = -RS5+log((1/sqrt(2*pi*(sd(5)^2))));
 L6 = -RS6+log((1/sqrt(2*pi*(sd(6)^2))));
 L7 = -RS7+log((1/sqrt(2*pi*(sd(7)^2))));
 L8 = -RS8+log((1/sqrt(2*pi*(sd(8)^2))));
 L=L1+L2+L3+L4+L5+L6+L7+L8; 
 AIC(temp)= 2*Ncluster - 2*L;
 BIC(temp)= Ncluster*log(Nb) - 2*L;
 temp=temp+1;
end

%% Following Sonnewald et al., 2019
Ncluster = 50; % for now
clear IDX C temp
[IDX,C]=kmeans(Xn,Ncluster,'MaxIter',500,'Replicates',5,'Display','final');
	
% calculate area covered by each cluster
for i=1:Ncluster
   tmp=zeros(Nb,1);
   tmp(IDX==i)=1;
   Area(i)=tmp'*area';
end

[Area1,index]=sort(Area,'descend');
Areaper = Area1./(sum(Area1));
plot(Areaper);

% Ncluster = 8;
% clear IDX C tmp Area Area1 index Areaper
% [IDX,C]=kmeans(Xn,Ncluster,'MaxIter',500,'Replicates',5,'Display','final');
% 
% % calculate area covered by each cluster
% for i=1:Ncluster
%    tmp=zeros(Nb,1);
%    tmp(IDX==i)=1;
%    Area(i)=tmp'*area';
% end
% [Area1,index]=sort(Area,'descend');

%% Arrange the clusters based on percent of area covered

IDX1 = IDX;	
for i=1:Ncluster
  C1(i,:)=C(index(i),:);
  IDX1(IDX==index(i))=i;
end

for i=1:8
  C2(:,i)=mu(i)+sd(i)*C1(:,i);
end

% make the cluster map
map=zeros(360,160)*NaN;
for i=1:Nb
 map(xind(i),yind(i))=IDX1(i);
end

% quick look
figure(1);
pcolor(map'); shading flat; colorbar; caxis([1 5]);

figure(2);
bar(C2(1:5,:),'grouped'); legend(lab);



