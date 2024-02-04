%function to compute p riccati matrix and k control matrix for LQR
%A,B matrixes of linear state dynamics, 
%Q, Qf cost of the state; R cost of the control;
%N number of time intervals; N+1 samples

function  [P, K]=pk_riccati(A,B,C,Q,Qf,R,N)

P(:,:,N+1)=C(:,:,length(C))'*Qf*C(:,:,length(C));

for i=N:-1:1
    V=C(:,:,i)'*Q(:,:,i)*C(:,:,i);
    P(:,:,i)=A(:,:,i)'*P(:,:,i+1)*A(:,:,i)-A(:,:,i)'*P(:,:,i+1)*B(:,:,i)*...
         (inv(R(:,i)+B(:,:,i)'*P(:,:,i+1)*B(:,:,i)))*B(:,:,i)'*P(:,:,i+1)*A(:,:,i) +V;
end

for i=1:N
    K(:,:,i)=inv(R(:,i)+B(:,:,i)'*P(:,:,i+1)*B(:,:,i))*...
               B(:,:,i)'*P(:,:,i+1)*A(:,:,i);
end
end