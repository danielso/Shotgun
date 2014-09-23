clear all
close all
clc

% Generate all figures for the paper
addpath('Results')
addpath('Misc')
addpath('GenerateSpikes');
set(0,'DefaultTextInterpreter', 'latex');

%% Figure 1 - Toy model 
% In this figure:
% N=50, 
% T=2e5 (~1 hour experiment, assuming 200ms bins)
% firing rate~0.2   (~1Hz firing rate)
% balanced network (no Dale's law yet)

% observations_ratios= [1,0.5,0.2,0.1,0.04,0.02];
observations_ratios= [1,0.2,0.1,0.04];
L=length(observations_ratios);
K=5; %width of subplots
x_ticks={'R','C','Z','S'};
fontsize=10;
fontsize2=1.5*fontsize;
    
% load(['Run_N=50_obs=' num2str(observations_ratios(1)) '_T=200000.mat']);
% neuron_type='logistic'  ;
% spikes=GetSpikes(W,bias,params.spike_gen.T,params.spike_gen.T0,params.spike_gen.seed_spikes,neuron_type,params.spike_gen.N_stim,params.spike_gen.stim_type);

figure
for ii=1:L
    load(['Run_N=50_obs=' num2str(observations_ratios(ii)) '_T=500000.mat']);
    
    mi=min(W(:));ma=max(W(:));
    subplot(L+1,K,[1 2 3])
    imagesc(W,[mi ma]); h=colorbar;
%     colormap('gray')
    ylabel('True W','fontsize',fontsize2)
    set(h, 'ylim', [mi ma])
    subplot(L+1,K,4)
    scatter(W(:),W(:),'b.')
    xlabel('W')
    ylabel('W')
    axis([mi ma mi ma])
    subplot(L+1,K,5)
    y_ticks=[1,1,1,1];   
    bar(y_ticks);    
    set(gca, 'XTickLabel', x_ticks,'fontsize',fontsize);
    
    subplot(L+1,K,K*ii+4)
    A_ind=linspace(mi,ma,100);
    plot(A_ind,A_ind,'r-');
    hold all
    scatter(W(:),EW2(:),'b.')
    axis([mi ma mi ma])
    hold off
%     legend('x=y','EW2','EW22')
    xlabel('W')
    ylabel('$\hat{W}$')

    
   subplot(L+1,K,K*ii+5)
     [R,correlation, zero_matching,sign_matching] = GetWeightsErrors( W,EW2 );
%     [MSE2,correlation2,SE2] = GetWeightsErrors( W,EW22 );

    bar( [R,correlation, zero_matching,sign_matching] );    
    ylim([0 1])
    set(gca, 'XTickLabel', x_ticks,'fontsize',fontsize);
%     title({[' EW2 corr =' num2str(correlation) ', EW22 corr =' num2str(correlation2)]; ...
%          [' EW2 MSE =' num2str(MSE) ', EW22 MSE =' num2str(MSE2)]; ...
%          [' EW2 SE =' num2str(SE) ', EW22 SE =' num2str(SE2) ]});
%     hold off

    
    subplot(L+1,K,K*ii+[1 2 3])    
    imagesc(EW2,[mi ma]); h=colorbar;
    set(h, 'ylim', [mi ma])
    ylabel(['$p_{\mathrm{obs}=}$' num2str(observations_ratios(ii))],'fontsize',fontsize2)
    
end

Export2Folder('Fig1.pdf','Figures') 