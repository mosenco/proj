%%
%es 1.2
clear all;
clc
A = [0.5 1 -0.2 0;
    0 0.01 0 0.5;
    2 0 1 0;
    0.1 0 0 2];
B = [1 ;1 ;1 ;1];
C = [1 1 0 0;
    0 1 0 1;
    0 0 1 0;
    1 1 0 1;
    ];
D = zeros(4,1);
x_zero=[-0.1,0.1,0.2,-0.2]';


Q = [10 0 0 0;
    0 0.8 0 0;
    0 0 0.1 0;
    0 0 0 0.7];
R =1;
Qf=Q;

sample=1;
horizon=1000;
t=0:sample:horizon;
N=length(t)-1;
sysc=ss(A,B,C,D);
sysd=c2d(sysc,sample);
Ad=sysd.a;
Bd=sysd.b;

[P, K]=riccati_track(Ad,Bd,C,Q,Qf,R,N);
z = [square(0.1*t); 5*square(0.1*t);5*square(0.1*t); 5*square(0.1*t)];
[g, Lg]=LQT(Ad,Bd,C,Q,Qf,R,N,P,z);



x(:,1)=x_zero;
y(:,1)=C*x_zero;


for i=1:N
    %optimal control
    u(:,i)=-K(:,:,i)*x(:,i)+Lg(:,:,i)*g(:,:,i+1);
    %optimal state for LQT to track z
    x(:,i+1)=Ad*x(:,i)+Bd*u(:,i);
     y(:,i+1)=C*x(:,i+1);
end

subplot(5,1,1);
plot(t(1:N+1),y(1,:));
title('state x1 vs z1');
hold on
plot(t(1:N+1),z(1,:));
hold off

subplot(5,1,2);
plot(t(1:N+1),y(2,:));
title('state x2 vs z2');
hold on
plot(t(1:N+1),z(2,:));
hold off

subplot(5,1,3);
plot(t(1:N+1),y(3,:));
title('state x3 vs z3');
hold on
plot(t(1:N+1),z(3,:));
hold off

subplot(5,1,4);
plot(t(1:N+1),y(4,:));
title('state x4 vs z4');
hold on
plot(t(1:N+1),z(4,:));
hold off

subplot(5,1,5);
plot(t(1:N),u);
title('control');