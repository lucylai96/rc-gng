function [simdata, simresults] = sim_negauto(m)
% PURPOSE: simulate negative automaintence experiment for different
% capacities
% INPUT: m = model (m1 = policy cost, m2 - no cost)
% Written by: Lucy Lai

rng(1); % set random seed for reproducibility
prettyplot
close all;

legStr = {'Control, S = 2'};
n = 100;
data = generate_negauto(n,legStr); % number of simulated subjects

for s = 1:length(data)
    agent(s).lrate_theta = 0.7;
    agent(s).lrate_V = 0.5;
    agent(s).lrate_p = 0;
    agent(s).lrate_e = 0.01;
    agent(s).m = m;
    agent(s).b = 1;
    switch agent(s).m
        case 1 % no cost
            agent(s).lrate_beta = 0;
            agent(s).beta0 = 3;
            
        case 2 % cost
            agent(s).C = rand;
            agent(s).lrate_beta = 1;
            agent(s).beta0 = 1;
            
        case 3 % using the fitted models
            x = results(2).x(s,:);
            agent(s).C = x(1);
            agent(s).lrate_theta = x(2);
            agent(s).lrate_V = x(3);
            agent(s).lrate_beta = 1;
            agent(s).beta0 = 1;
    end
    simdata(s) = actor_critic_gng(agent(s),data(s));
end

%simresults = analyze_gng(simdata);
simdata(1).legStr = legStr;

% plots
map = brewermap(n,'*Reds');
%map = map(11:end,:);

% cumulative presses,
figure; hold on;

subplot 131; hold on;
imagesc(sort([agent.C])); colormap(map)
ct = colorbar; axis square; xlabel('Agents')
title(ct,'Capacity')
set(gca,'ytick',[])

subplot 132; hold on;
for s = 1:length(data)
    simdata(s).cs = cumsum(simdata(s).a==2); % a = 2 is peck
    plot(simdata(s).cs,'Color',map(ceil(n*agent(s).C/max([agent.C])),:),'LineWidth',2);
    %xplot = find(simdata(s).r==1);
    %line([xplot' xplot'+10]',[simdata(s).cs(xplot)' simdata(s).cs(xplot)']','LineWidth',2,'Color','k');
end
axis([0 length(simdata(s).s) 0 length(simdata(s).s)]);
axis square; dline
ylabel('Cumulative presses');
xlabel('Trials');

% capacity
subplot 133; hold on;
for s = 1:length(data)
    plot(sum(simdata(s).a==2),agent(s).C,'o','Color',map(ceil(n*agent(s).C/max([agent.C])),:))
end
%sum(simdata(s).a==2)/length(simdata(s).a)
ylabel('Capacity');
xlabel('Total Pecks');
box off
axis square
set(gcf, 'Position',  [400, 100, 1200, 500])

%%
C =1;
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
%movtheta(movtheta==0) = NaN;

% beta
subplot 111; hold on;
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
str = {'\theta_1 (Instrumental)','\theta_2 (Pavlovian)'}
for th = 1:2
    mt = movtheta(th:2:end,:);
    subplot(1,2,th); hold on;  title(str{th})
    for s = 1:length(simdata)
        plot(1:size(mt,2),mt(s,:),'Color',map(ceil(n*agent(s).C/max([agent.C])),:),'LineWidth',3)
    end
end
ylabel('\theta');
xlabel('Trials');
set(gcf, 'Position',  [400, 100, 1000, 300])

% value of state
figure; hold on;
subplot 211; hold on;
for s = 1:length(simdata)
    plot(simdata(s).V(:,2),'Color',map(ceil(n*agent(s).C/max([agent.C])),:))
end
ylabel('\theta');
xlabel('Trials');

end

