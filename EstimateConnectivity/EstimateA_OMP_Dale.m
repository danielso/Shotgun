function X=EstimateA_OMP_Dale(A_,B,spar,tol,lambda,M,rates,identities)
% Does (penalized) orthogonal matching pursuit until sparsity tolerance is
% reached. Diagonal entries are always selected, as we know they're
% activated and negative if we're using Dale's law.
% Inputs:
% A_ - Cxx
% B - Cxy
% spar - sparsity level
% tol - sparsity tolerance
% lambda - quadratic penalty coefficient for deviation from means
% M - mean matrix
% rates - firing rates for each neuron
% Outputs:
% X - final weight matrix estimate
    
    N=size(A_,2);
    X=zeros(N);
    
    ATA=A_'*A_; %precompute
    d=diag(ATA);
    
    %loop over each row of W, i.e. x
    for i=1:N
        x=zeros(N,1);
        S=[]; %columns of A/elements of x we've used so far
        Sc=(1:N)'; %columns of A/elements of x we can select from

        b=B(:,i);
        r=b; %residuals
        
        A=A_*rates(i); %apply spiking rate scaling for logistic
        while (mean(~~x)-spar)<tol

            AA=A(:,Sc); %A with cols we haven't selected yet
            col_norms=sqrt(d(Sc))*rates(i); %norm of each column
            AAn=AA*diag(1./col_norms); % column-normalized version of AA

            prods=(AAn'*r).^2; %dot product between cols of AAn and residuals is regular objective
            zs=diag(col_norms.^(-2))*AA'*r; %values of x_i that maximize the above product
%             obj=prods-lambda*(zs-M(i,Sc)').^2; %penalize optimal values that are farther away from our means

            obj=prods-lambda*(zs-M(i,Sc)')-(10^50*(sign(zs)~=repmat(identities(i),[length(Sc),1])).^2);

            [~,idx]=max(obj);
            
            if ismember(i,Sc) %if a diagonal weight remains, pick it instead
                idx=find(i==Sc); %since we know it's negative (and on).
            end

            S=sort([S;Sc(idx)]); %add the new dimension to the list.
            Sc(idx)=[]; %delete it from our list of available dimensions
            
            %calculate ls x
            xx=(ATA(S,S)*rates(i)^2)\A(:,S)'*b;
            x(S)=xx;
            
            r=b-A*x; %update residual

        end

        X(i,:)=x;
    end



end
