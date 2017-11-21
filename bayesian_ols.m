clear all
close all
clc
%Import Data
DATA=importdata('data.csv',',',1);
data=DATA.data;
%Parameters
[N,k]=size(data);
df=N-k;
iter=10000;
r=0.12;

%Initial OLS
iota=ones(N,1); %constant
X=[iota,data(:,2:k)]; %regressor matrix 
Y=data(:,1);                              %dependent variable
beta_ini=inv(X'*X)*X'*Y;              %beta_ols
res=Y-X*beta_ini;                     %residal
RSS=sum(res'*res);                    %residual sum of square
sigma_ini=RSS/df;                     %MSE/df=sigma^2 hat
vcv_beta_ini=inv(X'*X)*sigma_ini;     %Homoske VCV estimates
var_beta_ini=diag(vcv_beta_ini);      %variance of beta_ols
se_beta_ini=sqrt(var_beta_ini);       %standard error of beta_ols
s0=sqrt(sigma_ini);                   %sigma epsilon hat
sigmaVar=2/df*(sigma_ini^2);       %variance of sigma
                           
%Metropolis-Hastings algorithm
theta=[beta_ini',sigma_ini];
Sigma=[var_beta_ini;sigmaVar];
Sigma=diag(Sigma);                    %VCV of all estimators
mu = zeros(1,length(theta));
Sigma_adj=Sigma*r;

%Postier
THETA=zeros(iter,length(theta));
THETA(1,:)=theta;
accp=zeros(iter,1);
prop=zeros(iter,length(theta));
prop(1,:)=theta;

%Flat prior
for ii=1:(iter-1)
 prop(ii+1,:)=THETA(ii,:)+mvnrnd(mu,Sigma_adj);
 while prop(ii+1,length(theta))<=0
     prop(ii+1,:)=THETA(ii,:)+mvnrnd(mu,Sigma_adj);
 end
 ratio=exp(logL(Y,X,THETA(ii,1:6)',THETA(ii,7))-logL(Y,X,prop(ii+1,1:6)',prop(ii+1,7)));
 u=rand;
 if u<ratio
     accp(ii+1)=1;
     THETA(ii+1,:)=prop(ii+1,:);
 else accp(ii+1)=0; THETA(ii+1,:)=THETA(ii,:);
 end
end

r_acc=sum(accp)/iter;        %accpet rate

figure(1)
subplot(2,4,1)
histfit(THETA(:,1),100,'kernel')
hold on
line([theta(1) theta(1)],ylim,'Color','c','LineWidth',1)
title('\beta_0')
hold off
 
subplot(2,4,2)
histfit(THETA(:,2),100,'kernel')
hold on
line([theta(2) theta(2)],ylim,'Color','c','LineWidth',1)
title('\beta_{educ}')
hold off

subplot(2,4,3)
histfit(THETA(:,3),100,'kernel')
hold on
line([theta(3) theta(3)],ylim,'Color','c','LineWidth',1)
title('\beta_{exp}')
hold off

subplot(2,4,4)
histfit(THETA(:,4),100,'kernel')
hold on
line([theta(4) theta(4)],ylim,'Color','c','LineWidth',1)
title('\beta_{SMSA}')
hold off

subplot(2,4,5)
histfit(THETA(:,5),100,'kernel')
hold on
line([theta(5) theta(5)],ylim,'Color','c','LineWidth',1)
title('\beta_{black}')
hold off

subplot(2,4,6)
histfit(THETA(:,6),100,'kernel')
hold on
line([theta(6) theta(6)],ylim,'Color','c','LineWidth',1)
title('\beta_{south}')
hold off
 
subplot(2,4,7)
histfit(THETA(:,7),100,'kernel')
hold on
line([theta(7) theta(7)],ylim,'Color','c','LineWidth',1)
title('\sigma_{\epsilon}^2')
hold off
