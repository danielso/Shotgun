function [ Y,spikes,relative_std_cell] = Spikes2Calcium2Spikes( true_spikes,calcium_model)
%SPIKES2CALCIUM2SPIKES Summary of this function goes here
%   Detailed explanation goes here

% observation model
sn=calcium_model.sn;
amp=calcium_model.amp;
b=calcium_model.baseline; 
g=calcium_model.g;
noise_mode=0;
Y = Spikes2Calcium(true_spikes,g,b,amp,sn,noise_mode);

order=1;
% P=GetParams(Y,order,'keep','arpfit');
P= GetParams(Y,order,'psd','arpfit');
[N,T]=size(Y);

% [spikes_cont,b] = Calcium2Spikes(Y,P);
%         thresh=max(spikes_cont,[],2)/2;
%         spikes=double(bsxfun(@gt,spikes_cont,thresh));
T_split=1e4; %split time if larger then this

splits=ceil(T/T_split)
spikes=Y*0;
relative_std_cell=cell(N,1);
for iter=1:splits
    ind_start=(iter-1)*T_split+1;
    if iter<splits
        ind_end=iter*T_split;
    else
        ind_end=T;
    end
    indices=ind_start:ind_end;
    switch calcium_model.est_type
        case 'FOOPSI'
              [spikes_temp, ~ ] = Calcium2Spikes(Y(:,indices),P); relative_std_cell_temp=cell(N,1);
        case 'GreedyAccurate'
                [spikes_temp,relative_std_cell_temp] = Calcium2Spikes_GreedyAccurate(Y(:,indices),P);
        case 'GreedyFast'
             [spikes_temp,relative_std_cell_temp] = Calcium2Spikes_GreedyFast(Y(:,indices),P);
    end
    spikes(:,indices)=spikes_temp;
    for nn=1:N
        temp=relative_std_cell{nn};
        temp=[temp relative_std_cell_temp{nn}]; %#ok
        relative_std_cell{nn}=temp;
    end
    if ~mod(iter,floor(splits/100))
        disp([num2str(100*iter/splits,2) '%'])
    end
end

end

