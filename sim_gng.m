function [simdata, simresults] = sim_gng(data,results)

% PURPOSE: simulate go-nogo experiment for diff controllabilities
% INPUT:
% Written by: Lucy Lai

rng(0);    % set random seed for reproducibility
close all; prettyplot

if nargin < 1; load gng_data.mat; end
if nargin < 2; load model_fits; end

for s = 1:length(data)
    agent.lrate_beta = 0;
    agent.beta0 = 1;
    agent.lrate_p = 0;
    agent.C = [];
    for k = 1:length(results.param)
        agent.(results.param(k).name) = results.x(s,k);
    end
    simdata(s) = actor_critic_gng(agent,data(s));
end

simresults = analyze_gng(simdata);

plot_figures('reward-complexity',simresults,simdata);
plot_figures('bias-complexity',simresults,simdata);
plot_figures('conditions',simresults,simdata);
plot_figures('gobias',simresults,simdata);
plot_figures('beta-complexity',simresults,simdata);
pause(1);
plot_figures('mov_params',simresults,simdata);
end

function [simdata, simresults] = sim_gng0(m)
% function sim_gng(data,results)

% PURPOSE: simulate go-nogo experiment for diff controllability and set sizes?
% INPUT: m = model (m1 = policy cost, m2 - no cost)
% Written by: Lucy Lai

addpath('/Users/lucy/Google Drive/Harvard/Projects/rc-behav/code/GoNogo-control/')
rng(0); % set random seed for reproducibility
close all
prettyplot

% if nargin < 2
%     load model_fits;
%     results = results(1);
% end

prettyplot;

% legStr = {'Control, S = 2','HiSim, LC, S = 4','HiSim, HC, S = 4','MedSim, LC, S = 4','MedSim, HC, S = 4', 'LowSim, LC, S = 4','LowSim, HC, S = 4'};
legStr = {'Control, S = 2','HiSim, LC, S = 4','HiSim, HC, S = 4', 'LowSim, LC, S = 4','LowSim, HC, S = 4'};
data = generate_task(40,legStr); % number of simulated subjects

% legStr = {'Low control','High control'};
% data = generate_dorfman(100); % number of simulated subjects

for s = 1:length(data)
    agent.lrate_theta = 0.3;
    agent.lrate_V = 0.3;
    agent.lrate_p = 0;
    agent.lrate_e = 0.1;
    agent.C = 0.8;
    agent.m = m;
    agent.b = 1;
    switch agent.m
        case 1
            agent.lrate_beta = 0.1;
            agent.beta0 = 1;
        case 2
            agent.lrate_beta = 0;
            agent.beta0 = 3;
    end
    % for k = 1:length(results.param)
    %    agent.(results.param(k).name) = results.x(s,k);
    % end
    
    simdata(s) = actor_critic_gng(agent,data(s));
end

simresults = analyze_gng(simdata);
simdata(1).legStr = legStr;

plot_figures('reward-complexity',simresults,simdata);
plot_figures('bias-complexity',simresults,simdata);
plot_figures('conditions',simresults,simdata);
plot_figures('gobias',simresults,simdata);
plot_figures('beta-complexity',simresults,simdata);
pause(1);
plot_figures('mov_params',simresults,simdata);
end