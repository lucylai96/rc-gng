function sim_gng(m)
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

%legStr = {'Control, S = 2','HiSim, LC, S = 4','HiSim, HC, S = 4','MedSim, LC, S = 4','MedSim, HC, S = 4', 'LowSim, LC, S = 4','LowSim, HC, S = 4'};
legStr = {'Control, S = 2','HiSim, LC, S = 4','HiSim, HC, S = 4', 'LowSim, LC, S = 4','LowSim, HC, S = 4'};
data = generate_task(100,legStr); % number of simulated subjects

%legStr = {'Low control','High control'};
%data = generate_dorfman(100); % number of simulated subjects

for s = 1:length(data)
    agent.lrate_theta = 0.2;
    agent.lrate_V = 0.2;
    agent.lrate_p = 0;
    agent.C = 0.8;
    agent.p = [0.5 0.5];
    agent.m = m;
    agent.b = 2;
    switch agent.m
        case 1
            agent.lrate_beta = 0.1;
            agent.beta0 = 1;
        case 2
            agent.lrate_beta = 0;
            agent.beta0 = 3;
    end
    %agent.lrate_beta = 0.1;
    %agent.beta0 = 1;
    agent.lrate_beta = 0;
    agent.beta0 = 3;
    %for k = 1:length(results.param)
    %    agent.(results.param(k).name) = results.x(s,k);
    %end
    
    simdata(s) = actor_critic_gng(agent,data(s));
end

simresults = analyze_gng(simdata);

%% eventually put this in a separate "plot_figures" thing
%data = load_data('data2.csv');
%load results2

data = simdata;
movbeta = zeros(length(data),length(data(1).beta(data(1).cond==2)));
movtheta = zeros(length(data)*2,length(data(1).theta(data(1).cond==2)));
C = length(unique(data(s).cond));
map = gngColors(C);

for s = 1:length(data)
    for c = 1:C
        acc(s,c) = mean(data(s).acc(data(s).s==1 & data(s).cond==c)) - mean(data(s).acc(data(s).s==2 & data(s).cond==c)); %go - nogo
        
        % dynamic go bias
        go = data(s).acc(data(s).s==1 & data(s).cond==c);
        nogo = data(s).acc(data(s).s==2 & data(s).cond==c);
        gobias(s,1:length(go),c) = movmean(go-nogo,10);
        
        % beta and theta
        movbeta(s,1:length(data(s).beta(data(s).cond==c)),c) = movmean(data(s).beta(data(s).cond==c),10);
        movtheta(s*2-1:s*2,1:length(data(s).theta(data(s).cond==c,:)),c) = data(s).theta(data(s).cond==c,:)';
    end
end

movbeta(movbeta==0) = NaN;


err = sem(acc,1);
m = mean(acc);

figure; hold on;
subplot 311; hold on; % go bias bar
[h] = barwitherr(err,m,'FaceColor','flat');
for c = 1:C
    h.CData(c,:) = map(c,:);
end
ylabel('Go bias');
ylim([0 1])

subplot 312; hold on; % dynamic go bias
for c = 1:C
    l(c,:) = shadedErrorBar(1:size(gobias,2),mean(gobias(:,:,c)),sem(gobias(:,:,c),1),{'Color',map(c,:)},1);
end

for c = 1:C
    handles(c) = l(c).mainLine;
end
legend(handles,legStr)
ylabel('Go bias');
xlabel('Trials');
ylim([0 1])
xlim([0 length(go)])

subplot 313; hold on; % beta
for c = 1:C
    l(c,:) = shadedErrorBar(1:size(movbeta,2),mean(movbeta(:,:,c)),sem(movbeta(:,:,c),1),{'Color',map(c,:)},1);
end
ylabel('\beta');
xlabel('Trials');

set(gcf, 'Position',  [400, 100, 400, 900])

%% theta
figure; hold on;
for c = 1:C
    subplot(1,C,c); hold on;
    title(legStr{c})
    for th = 1:2
        t(th) = shadedErrorBar(1:size(movtheta,2),mean(movtheta(th:2:length(movtheta),:,c)),sem(movtheta(th:2:length(movtheta),:,c),1),{'Color',map(th,:)},1);
        handles(th) = t(th).mainLine;
    end
    dtheta = movtheta(1:2:length(movtheta),:,c)-movtheta(2:2:length(movtheta),:,c);
    t(3) = shadedErrorBar(1:size(dtheta,2),mean(dtheta),sem(dtheta,1),{'Color',[0 0 0]},1);
    handles(3) = t(3).mainLine;
end
subplot(1,C,1)
legend(handles,{'\theta_1 (Instrumental)','\theta_2 (Pavlovian)','\theta_1-\theta_2'})
ylabel('\theta');
xlabel('Trials');
equalabscissa(1,C)
set(gcf, 'Position',  [400, 200, 1000, 400])

%% plots with data points

results = simresults;
% theoretical curves
figure; hold on;
plot(squeeze(nanmean(results.R)),squeeze(nanmean(results.V)))
legend(legStr)
xlabel('Policy complexity')
ylabel('Average reward')

for c = 1:length(unique(data(s).cond))
    plot(results.R_data(:,c),results.V_data(:,c),'.','MarkerSize',30)
end

%plot_figures('fig2',simresults,simdata);
%plot_figures('fig3',simresults,simdata);

end