function [simdata, simresults] = sim_gng(model,data,results)

% PURPOSE: simulate go-nogo experiment for diff controllabilities
% INPUT:
% Written by: Lucy Lai

rng(0);    % set random seed for reproducibility
prettyplot

if nargin < 2; load gng_data.mat; end
if nargin < 3; load model_fits.mat; end

results = results(model);

for s = 1:length(data)
    agent.m = model;
    if agent.m == 1 % no cost
        agent.C = [];
        agent.beta0 = 1;
        agent.lrate_beta = 0;
        agent.lrate_p = 0;
        agent.lrate_e = 0.1;
        agent.b = 0.5;
    else % cost
        agent.C = 1;
        agent.beta0 = 1;
        agent.lrate_p = 0;
        agent.lrate_e = 0.1;
        agent.b = 0.5;
    end
    
    for k = 1:length(results.param)
        agent.(results.param(k).name) = results.x(s,k);
    end
        
    simdata(s) = actor_critic_gng(agent,data(s));
end

simresults = analyze_gng(simdata);
end

