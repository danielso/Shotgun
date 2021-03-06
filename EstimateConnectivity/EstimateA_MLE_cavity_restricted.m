function EW=EstimateA_MLE_cavity_restricted(alpha,beta,Cxx,Cxy,rates)

N=size(Cxx,1);

finv=@(x)log(x./(1-x));
m=rates;
Myx=Cxy'+m*m';
% remove zeros from Myx
temp = sort(Myx(:));
min2 = temp(2); %second smallest value in Myx
Myx(Myx==0)=min2;

Cxx_inv=inv(Cxx);

Fas=bsxfun(@plus,(1-m(beta)').^2,(pi/8)*((finv(bsxfun(@times,Myx(alpha,beta),1./m(beta)'))).^2)*diag(diag(Cxx(beta,beta))));
Bas=(1./Fas).*(finv(m(alpha))*(1-m(beta)'))*diag(diag(Cxx(beta,beta)));
Cas=(1./Fas).*(bsxfun(@plus,(finv(m(alpha))).^2,-(finv(bsxfun(@times,Myx(alpha,beta),1./m(beta)'))).^2))*diag(diag(Cxx(beta,beta)).^2);
Das=-Bas-sqrt(Bas.^2-Cas);
Aas=Das./sqrt(1-(pi/8)*Das*(Cxx_inv(beta,beta))*Das');
EW=Aas*Cxx_inv(beta,beta);
end
% imagesc(EW)
% colorbar