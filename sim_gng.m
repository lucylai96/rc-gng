function sim_gng
% function sim_gng(data,results)
% PURPOSE: simulate go-nogo experiment for diff controllability and set sizes?

% Written by: Lucy Lai

addpath('/Users/lucy/Google Drive/Harvard/Projects/rc-behav/code/GoNogo-control/')
%rng(1); % set random seed for reproducibility
close all

% if nargin < 2
%     load model_fits;
%     results = results(1);
% end

prettyplot;

legStr = {'Control, S = 2','HiSim, S = 4','MedSim, LC, S = 4','MedSim, HC, S = 4', 'LowSim, LC, S = 4','LowSim, HC, S = 4'};
data = generate_task(100,legStr); % number of simulated subjects

% legStr = {'Low control','High control'};
% data = generate_dorfman(100); % number of simulated subjects

for s = 1:length(data)
    agent.lrate_beta = 0.5;
    agent.beta0 = 1;
    agent.lrate_theta = 0.2;
    agent.lrate_V = 0.2;
    agent.lrate_p = 0.02;
    agent.C = 0.6;
    
    agent.p = [0.2 0.8];
    
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
C = length(unique(data(s).cond));
map = gngColors(C);

for s = 1:length(data)
    for c = 1:C
        acc(s,c) = mean(data(s).acc(data(s).s==1 & data(s).cond==c)) - mean(data(s).acc(data(s).s==2 & data(s).cond==c)); %go - nogo
        
        % dynamic go bias
        go = data(s).acc(data(s).s==1 & data(s).cond==c);
        nogo = data(s).acc(data(s).s==2 & data(s).cond==c);
        
        gobias(s,1:length(go),c) = movmean(go-nogo,10);
        movbeta(s,1:length(data(s).beta(data(s).cond==c)),c) = movmean(data(s).beta(data(s).cond==c),10);
    end
end

movbeta(movbeta==0) = NaN;

err = sem(acc,1);
m = mean(acc);

figure; hold on;
subplot 311; hold on; % go bias bar
barerrorbar(m',err');
%set(gca,'XTick',[1 2],'XTickLabel',{'LC','HC'});%,'FontSize',25,'XLim',[0.5 2.5],'YLim',[0 0.55]);
set(gca,'XTick',[1:C],'XTickLabel',legStr);%,'FontSize',25,'XLim',[0.5 2.5],'YLim',[0 0.55]);
ylabel('Go bias');
ylim([0 1])

subplot 312; hold on; % dynamic go bias
for c = 1:C
    l(c,:) = shadedErrorBar(1:size(gobias,2),mean(gobias(:,:,c)),sem(gobias(:,:,c),1),{'Color',map(c,:)},1);
end
%legend([l(1).mainLine l(2).mainLine],{'LC','HC'})
for c = 1:C
    handles(c) = l(c).mainLine;
end
legend(handles,legStr)
ylabel('Go bias');
xlabel('Trials');
ylim([0 1])

subplot 313; hold on; % beta
for c = 1:C
    l(c,:) = shadedErrorBar(1:size(movbeta,2),mean(movbeta(:,:,c)),sem(movbeta(:,:,c),1),{'Color',map(c,:)},1);
end
ylabel('\beta');
xlabel('Trials');

%% plots

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