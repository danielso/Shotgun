function W = GetWeights( N,network_type,spar, seed,scale,N_stim,sbmparams)
%GetWeights Summary of this function goes here
% N - number of neurons
% network_type - what kind of connectivity to use (note each connectivity has additional parameters)
% spar - sparsity level
% seed - seed used to generate the random connections
% scale - weights are multiplied by this constant

if ~isempty(seed)
    stream = RandStream('mt19937ar','Seed',seed);
    RandStream.setGlobalStream(stream);
end

switch network_type
    case 'combi'
        lr_conn = 0.1;
        A=construct_weights_combi(N, spar,lr_conn);
    case 'balanced'   
        lr_conn = 0.1;
        A = construct_bal_weights(N,spar,lr_conn);
    case 'circular'
        NN_range=5;
        A = construct_weights_circ_NN(N,NN_range);
    case 'rand'
        A=randn(N).*(rand(N)<spar)/(sqrt(N*spar));
    case 'block'
        nTypes=length(sbmparams.blockFracs);
        str_var=sbmparams.str_var*ones(nTypes);
        seed=randi(1000);
        if sbmparams.DistDep
            A=construct_block_weights(N,sbmparams.blockFracs,sbmparams.block_means,str_var,ones(sbmparams.nblocks),seed); %delete connections later on
        else
            A=construct_block_weights(N,sbmparams.blockFracs,sbmparams.block_means,str_var,sbmparams.pconn,seed);
        end
    otherwise
        error('unknown connectivity type!')
end

    A=A*scale;
    G=rand(N,N_stim);
    W=[A, G; zeros(N_stim,N_stim+N)]; 

end

