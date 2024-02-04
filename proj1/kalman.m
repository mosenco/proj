function  [k]=mykalman(A,C, Qv, Rv, alfa,sigma0,N)
%Qv and Rv covariance matrixes
%alfa average of x0, sigma 

sigma(:,:,1)=inv(inv(sigma0)+C'*inv(Rv)*C);

for i=1:N
sigma(:,:,i+1)=inv(inv(A*sigma(:,:,i)*A'+Qv)+C'*inv(Rv)*C);
k(:,:,i)=sigma(:,:,i)*C'*inv(Rv);
end
k(:,:,N+1)=sigma(:,:,N+1)*C'*inv(Rv);

end
