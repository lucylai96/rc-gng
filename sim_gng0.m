function [simdata, simresults] = sim_gng0(m)
% function sim_gng(data,results)

% PURPOSE: simulate go-nogo experiment for diff controllability and set sizes?
% INPUT: m = model (m1 = policy cost, m2 - no cost)
% Written by: Lucy Lai

addpath('/Users/lucy/Google Drive/Harvard/Projects/rc-behav/code/GoNogo-control/')
rng(0); % set random seed for reproducibility
%close all
prettyplot

% if nargin < 2
%     load model_fits;
%     results = results(1);
% end

prettyplot;

% legStr = {'Control, S = 2','HiSim, LC, S = 4','HiSim, HC, S = 4','MedSim, LC, S = 4','MedSim, HC, S = 4', 'LowSim, LC, S = 4','LowSim, HC, S = 4'};
legStr = {'Control, S = 2','HiSim, LC, S = 4','HiSim, HC, S = 4', 'LowSim, LC, S = 4','LowSim, HC, S = 4'};
data = generate_task(78,legStr); % number of simulated subjects

% legStr = {'Low control','High control'};
% data = generate_dorfman(100); % number of simulated subjects

for s = 1:length(data)
    agent.lrate_theta = 0.3;
    agent.lrate_V = 0.3;
    agent.lrate_p = 0;
    agent.lrate_e = 0.1;
    agent.C = 1;
    agent.m = m;
    agent.b = 1;
    switch agent.m
        case 1 % no cost
            agent.lrate_beta = 0;
            agent.beta0 = 3;
            
        case 2 % cost
            agent.lrate_beta = 0.1;
            agent.beta0 = 1;
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

C = 5; map = gngColors(5);
figure; hold on;
movbeta = zeros(length(simdata),length(simdata(1).beta(simdata(1).cond==2)));
movcost = zeros(length(simdata),length(simdata(1).cost(simdata(1).cond==2)));
movtheta = zeros(length(simdata)*2,length(simdata(1).theta(simdata(1).cond==2)));

for s = 1:length(simdata)
    for c = 1:C
        movbeta(s,1:length(simdata(s).beta(simdata(s).cond==c)),c) = movmean(simdata(s).beta(simdata(s).cond==c),10);
        movcost(s,1:length(simdata(s).cost(simdata(s).cond==c)),c) = movmean(simdata(s).cost(simdata(s).cond==c),20);
        movtheta(s*2-1:s*2,1:length(simdata(s).theta(simdata(s).cond==c,:)),c) = simdata(s).theta(simdata(s).cond==c,:)';
    end
end
movbeta(movbeta==0) = NaN;
movcost(movcost==0) = NaN;
movtheta(movtheta==0) = NaN;

% beta
subplot 211; hold on;
for c = 1:C
    l(c,:) = shadedErrorBar(1:size(movbeta,2),mean(movbeta(:,:,c)),sem(movbeta(:,:,c),1),{'Color',map(c,:)},1);
end
ylabel('\beta');
xlabel('Trials');

% policy cost
subplot 212; hold on;
for c = 1:C
    l(c,:) = shadedErrorBar(1:size(movcost,2),mean(movcost(:,:,c)),sem(movcost(:,:,c),1),{'Color',map(c,:)},1);
end
ylabel('Policy complexity');
xlabel('Trials');
set(gcf, 'Position',  [400, 100, 400, 600])

% theta
figure; hold on;
for c = 1:C
    subplot(1,C,c); hold on;
    title(legStr{c})
    for th = 1:2
        t(th) = shadedErrorBar(1:size(movtheta,2),mean(movtheta(th:2:size(movtheta,1),:,c)),sem(movtheta(th:2:size(movtheta,1),:,c),1),{'Color',map(th,:)},1);
        handles(th) = t(th).mainLine;
    end
    dtheta = movtheta(1:2:size(movtheta,1),:,c)-movtheta(2:2:size(movtheta,1),:,c);
    %t(3) = shadedErrorBar(1:size(dtheta,2),mean(dtheta),sem(dtheta,1),{'Color',[0 0 0]},1);
    %handles(3) = t(3).mainLine;
end
subplot(1,C,1)
legend(handles,{'\theta_1 (Instrumental)','\theta_2 (Pavlovian)'})
ylabel('\theta');
xlabel('Trials');
equalabscissa(1,C)
set(gcf, 'Position',  [0, 200, 1400, 300])

end