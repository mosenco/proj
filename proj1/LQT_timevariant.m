%function to compute p riccati matrix and k control matrix for LQR
%A,B matrixes of linear state dynamics, 
%Q, Qf cost of the state; R cost of the control;
%N number of time intervals; N+1 samples

function  [g, Lg]=LgxLQT(A,B,C,Q,Qf,R,N,P,z)
%z is the vector to be tracked length N+1, dimension is the one y


g(:,:,N+1)=C(:,:,length(C))'*Qf*z(:,N+1);
for i=N:-1:1
    W=C(:,:,i)'*Q(:,:,i);
    E=B(:,:,i)*inv(R(:,i))*B(:,:,i)';
    g(:,:,i)=A(:,:,i)'*(eye(size(A(:,:,i),1))-inv(inv(P(:,:,i+1))+E)*E)*g(:,:,i+1)+W*z(:,i);

end

for i=1:N
    Lg(:,:,i)=inv(R(:,i)+B(:,:,i)'*P(:,:,i+1)*B(:,:,i))*B(:,:,i)';
end
end