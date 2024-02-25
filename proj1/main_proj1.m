%%
% es 1.1
clc;
clear all;
A = [0.5 0 0 0;
    0 0.01 0 0;
    0 0 1 0;
    0 0 0 2];
B = [1 ;1 ;1 ;1];
C = eye(4);
D = zeros(4,1);
x_zero=[-0.1,0.1,0.2,-0.2]';


Q = [20 0 0 0;
    0 0.7 0 0;
    0 0 1 0;
    0 0 0 1];
R =0.001;
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
z = [3*sin(0.05*t); 5*square(0.1*t); 2*sawtooth(0.05*t); ones(1,N+1)*2];
z_sim = [t' z'];
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
plot(t(1:N+1),x(1,:));
title('state x1 vs z1');
hold on
plot(t(1:N+1),z(1,:));
hold off

subplot(5,1,2);
plot(t(1:N+1),x(2,:));
title('state x2 vs z2');
hold on
plot(t(1:N+1),z(2,:));
hold off

subplot(5,1,3);
plot(t(1:N+1),x(3,:));
title('state x3 vs z3');
hold on
plot(t(1:N+1),z(3,:));
hold off

subplot(5,1,4);
plot(t(1:N+1),x(4,:));
title('state x4 vs z4');
hold on
plot(t(1:N+1),z(4,:));
hold off

subplot(5,1,5);
plot(t(1:N),u);
title('control');

%%
%es 1.2
clc;
clear all;
A = [0.5 0 0 0;
    0 0.01 0 0;
    0 0 1 0;
    0 0 0 2];
B = [1 ;1 ;1 ;1];
C = eye(4);
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
z_sim = [t' z'];
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
plot(t(1:N+1),x(1,:));
title('state x1 vs z1');
hold on
plot(t(1:N+1),z(1,:));
hold off

subplot(5,1,2);
plot(t(1:N+1),x(2,:));
title('state x2 vs z2');
hold on
plot(t(1:N+1),z(2,:));
hold off

subplot(5,1,3);
plot(t(1:N+1),x(3,:));
title('state x3 vs z3');
hold on
plot(t(1:N+1),z(3,:));
hold off

subplot(5,1,4);
plot(t(1:N+1),x(4,:));
title('state x4 vs z4');
hold on
plot(t(1:N+1),z(4,:));
hold off

subplot(5,1,5);
plot(t(1:N),u);
title('control');

%%
%time variant

clc;
clear all;

sample=1;
horizon=1000;
t=0:sample:horizon;
A=[];
B=[];
C=[];
D=[];
Q=[];
R=[];
for i=1:horizon
    A(:,:,i) = [sin(0.5*i) 0 0 0;
                        0 0.01 0 0;
                        0 0 1 0;
                        0 0 0 2];
    B(:,:,i) = [1 ;1 ;sin(i) ;1];
    C(:,:,i) = [1 0 0 0;
                0 1 0 0;
                0 0 1 0;
                0 0 0 1*i];
    D(:,:,i) = zeros(4,1);
    Q(:,:,i) = [sin(i) 0 0 0;
                0 0.8 0 0;
                0 0 0.1 0;
                0 0 0 0.7];
    R(:,i) = sin(i);
end


x_zero=[-0.1,0.1,0.2,-0.2]';

Qf=Q(:,:,length(Q));


N=length(t)-1;
sysc=ss(A,B,C,D);
sysd=c2d(sysc,sample);
Ad=sysd.a;
Bd=sysd.b;

[P, K]=riccati_track_timevariant(Ad,Bd,C,Q,Qf,R,N);
z = [square(0.1*t); 5*square(0.1*t);5*square(0.1*t); 5*square(0.1*t)];
z_sim = [t' z'];
[g, Lg]=LQT_timevariant(Ad,Bd,C,Q,Qf,R,N,P,z);



x(:,1)=x_zero;
y(:,1)=C(:,:,1)*x_zero;


for i=1:N
    %optimal control
    u(:,i)=-K(:,:,i)*x(:,i)+Lg(:,:,i)*g(:,:,i+1);
    %optimal state for LQT to track z
    x(:,i+1)=Ad(:,:,i)*x(:,i)+Bd(:,:,i)*u(:,i);
     y(:,i+1)=C(:,:,i)*x(:,i+1);
end

subplot(5,1,1);
plot(t(1:N+1),x(1,:));
title('state x1 vs z1');
hold on
plot(t(1:N+1),z(1,:));
hold off

subplot(5,1,2);
plot(t(1:N+1),x(2,:));
title('state x2 vs z2');
hold on
plot(t(1:N+1),z(2,:));
hold off

subplot(5,1,3);
plot(t(1:N+1),x(3,:));
title('state x3 vs z3');
hold on
plot(t(1:N+1),z(3,:));
hold off

subplot(5,1,4);
plot(t(1:N+1),x(4,:));
title('state x4 vs z4');
hold on
plot(t(1:N+1),z(4,:));
hold off

subplot(5,1,5);
plot(t(1:N),u);
title('control');

%%
% sys with noise

clc;
clear all;
A = [0.5 0 0 0;
    0 0.01 0 0;
    0 0 1 0;
    0 0 0 2];
B = [1 ;1 ;1 ;1];
C = eye(4);
D = zeros(4,1);
x_zero=[-0.1,0.1,0.2,-0.2]';


Q = [20 0 0 0;
    0 0.7 0 0;
    0 0 1 0;
    0 0 0 1];
R =0.001;
Qf=Q;

sample=1;
horizon=1000;
t=0:sample:horizon;
N=length(t)-1;
sysc=ss(A,B,C,D);
sysd=c2d(sysc,sample);
Ad=sysd.a;
Bd=sysd.b;

mucsi = [0 0 0 0];
Qv= [3 0 0 0;
    0 1 0 0;
    0 0 50 0;
    0 0 0 2];
mueta=[0];
Rv=[20];
rng default 
csi = mvnrnd(mucsi,Qv,N)';
eta= mvnrnd(mueta,Rv,N+1)';

[P, K]=riccati_track(Ad,Bd,C,Q,Qf,R,N);
z = [3*sin(0.05*t); 5*square(0.1*t); 2*sawtooth(0.05*t); ones(1,N+1)*2];
z_sim = [t' z'];
[g, Lg]=LQT(Ad,Bd,C,Q,Qf,R,N,P,z);

alfa=[-1,0.5,0.1,0]'; 
sigma0=[ 0.6796   -0.1388   -0.3735   -1.0152;
   -0.1388    0.2551   -0.2288   -0.6219;
   -0.3735   -0.2288    1.8473   -1.6738;

   -1.0152   -0.6219   -1.6738   13.6495];
[Kkalman]=kalman(Ad,C, Qv, Rv, alfa,sigma0,N);
y0=[-0.1;
0.1;
0.2;
-0.2];
mu0=alfa+Kkalman(:,:,1)*(y0-C*alfa)
x(:,1)=x_zero;
y(:,1)=C*x_zero;
mu(:,1)=mu0;


for i=1:N
    %optimal control
    u(:,i)=-K(:,:,i)*mu(:,i)+Lg(:,:,i)*g(:,:,i+1);
    %optimal state for LQT to track z
    x(:,i+1)=Ad*x(:,i)+Bd*u(:,i)+csi(:,i);
    y(:,i+1)=C*x(:,i+1)+eta(:,i+1);
    mu(:,i+1)=Ad*mu(:,i)+Bd*u(:,i)+...
    Kkalman(:,:,i+1)*(y(:,i+1)-C*(Ad*mu(:,i)+Bd*u(:,i)));
end

subplot(5,1,1);
plot(t(1:N+1),x(1,:));
title('state x1 vs z1');
hold on
plot(t(1:N+1),z(1,:));
plot(t(1:N+1),mu(1,:));
hold off


subplot(5,1,2);
plot(t(1:N+1),x(2,:));
title('state x2 vs z2');
hold on
plot(t(1:N+1),z(2,:));

plot(t(1:N+1),mu(2,:));
hold off

subplot(5,1,3);
plot(t(1:N+1),x(3,:));
title('state x3 vs z3');
hold on
plot(t(1:N+1),z(3,:));
plot(t(1:N+1),mu(3,:));
hold off

subplot(5,1,4);
plot(t(1:N+1),x(4,:));
title('state x4 vs z4');
hold on
plot(t(1:N+1),z(4,:));
plot(t(1:N+1),mu(4,:));
hold off

subplot(5,1,5);
plot(t(1:N),u);
title('control');

%%
% not controllable

clc;
clear all;
A = [0.002 0 0 0;
    0.4 0.01 2 0;
    4 0 1 4;
    4 0.3 1 0.001];
B = [0;1;1;1];
C = eye(4);
D = zeros(4,1);
x_zero=[-0.1,0.1,0.2,-0.2]';


Q = [2000 0 0 0;
    0 0.7 0 0;
    0 0 1 0;
    0 0 0 1];
R =0.001;
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
z = [3*sin(0.05*t); 5*square(0.1*t); 2*sawtooth(0.05*t); ones(1,N+1)*2];
z_sim = [t' z'];
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
plot(t(1:N+1),x(1,:));
title('state x1 vs z1');
hold on
plot(t(1:N+1),z(1,:));
hold off

subplot(5,1,2);
plot(t(1:N+1),x(2,:));
title('state x2 vs z2');
hold on
plot(t(1:N+1),z(2,:));
hold off

subplot(5,1,3);
plot(t(1:N+1),x(3,:));
title('state x3 vs z3');
hold on
plot(t(1:N+1),z(3,:));
hold off

subplot(5,1,4);
plot(t(1:N+1),x(4,:));
title('state x4 vs z4');
hold on
plot(t(1:N+1),z(4,:));
hold off

subplot(5,1,5);
plot(t(1:N),u);
title('control');