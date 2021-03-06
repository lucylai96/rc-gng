function analyze_dorfman19

data = load_data('dorfman_data.csv');

prettyplot
map = gngColors(6);

% optimal R-C curves for her task
beta = linspace(0.1,15,50);
Ps = ones(1,2)/2;
Q = [0.2 0.8; 0.8 0.2];
[R(1,:),V(1,:)] = blahut_arimoto(Ps,Q,beta);


Ps = ones(1,4)/4;
Q = [0.2 0.8; 0.2 0.8; 0.8 0.2; 0.8 0.2]; % distance is 0
[R(2,:),V(2,:)] = blahut_arimoto(Ps,Q,beta); 

Q = [0.25 0.75; 0.2 0.8; 0.8 0.2; 0.75 0.25]; % distance is 0.05
[R(3,:),V(3,:)] = blahut_arimoto(Ps,Q,beta);

Q = [0.3 0.7; 0.2 0.8; 0.8 0.2; 0.7 0.3]; % distance is 0.1
[R(4,:),V(4,:)] = blahut_arimoto(Ps,Q,beta);

Q = [0.35 0.65; 0.8 0.2; 0.2 0.8; 0.65 0.35]; % distance is 0.15
Q = [0.3 0.7; 0.9 0.1; 0.1 0.9; 0.7 0.3]; % distance is 0.2: manipulate similarity without decreasing controllability
[R(5,:),V(5,:)] = blahut_arimoto(Ps,Q,beta);

Q = [0.4 0.6; 0.8 0.2; 0.2 0.8; 0.6 0.4]; % distance is 0.2
[R(6,:),V(6,:)] = blahut_arimoto(Ps,Q,beta);

% theoretical curves
figure; hold on;
plot(R',V')
%legend('Control, S = 2','High similarity, S = 4','Med similarity, S = 4','Low similarity, S = 4')
xlabel('Policy complexity')
ylabel('Average reward')

% Question: was p(A) actually high in LC even though optimally it should be
% equal?

for c = 1:2 % condition
    for s = 1:length(data) % subject
        ix = data(s).cond == c;
        for a = 1:2 % action
            p(s,a,c) = sum(data(s).a(ix)==a)/length(data(s).a(ix));
        end
        movp(s,:,c) = movmean(data(s).a(ix),5);
    end
end

pause(.1)

figure; hold on;
barwitherr(squeeze(sem(p,1))',squeeze(mean(p))')
ylabel('Proportion of trials')
xticks([1 2])
xticklabels({'LC','HC'})
l = legend('No-Go','Go');
title(l,'Action')


figure; hold on;
map = gngColors(2);
p = shadedErrorBar(1:size(movp,2), mean(movp(:,:,1)), sem(movp(:,:,1),1),{'Color',map(1,:)},1);
pp = shadedErrorBar(1:size(movp,2), mean(movp(:,:,2)), sem(movp(:,:,2),1),{'Color',map(2,:)},1);

axis([0 120 1 2]);
yticks([1 2])
yticklabels({'No-Go','Go'})
ylabel('Action')

legend('Low control','High control');
xlabel('Trials')

%% data
alpha = 0.1;
C = unique(data(s).cond);        % condition
R_data = zeros(length(data),length(C));
V_data = zeros(length(data),length(C));
Ps = [0.33 0.33 0.33];
for s = 1:length(data)
    for c = 1:length(C)
        ix = data(s).cond==C(c);
        state = data(s).s(ix);
        if state(1)>3
            state = state-3;
        end
        action = data(s).a(ix);
        r = data(s).r(ix);

        if c ==1
            Q = [0.75 0.25; 0.25 0.75; 0.5 0.5];
        elseif c == 2
            Q = [0.25 0.75; 0.75 0.25; 0.2 0.8];
        end
        R_data(s,c) = mutual_information(state,action,0.1);
        V_data(s,c) = mean(data(s).r(ix));
        
        [R(c,:),V(c,:)] = blahut_arimoto(Ps,Q,beta);
        
        
        results.R(s,:,c) = R(c,:); % 129 subjects x 50 betas x 2 conditions
        results.V(s,:,c) = V(c,:);
    end
    
    clear R V
end

% store data
%results.R = R;
%results.V = V;
%results.R_data = R_data;
%results.V_data = V_data;


%% plots

% theoretical curves
figure; hold on;
plot(squeeze(nanmean(results.R)),squeeze(nanmean(results.V)))
legend('Low control','High control')

for c = 1:2
    plot(R_data(:,c),V_data(:,c),'.','MarkerSize',20)
end
xlabel('Policy complexity')
ylabel('Average reward')

% Go bias for experiment 2
for s = 1:length(data)
    acc(s,1) = mean(data(s).acc(data(s).s==1)) - mean(data(s).acc(data(s).s==2));
    acc(s,2) = mean(data(s).acc(data(s).s==4)) - mean(data(s).acc(data(s).s==5));
    %macc(s,1) = mean(results(3).latents(s).acc(data(s).s==1)) - mean(results(3).latents(s).acc(data(s).s==2));
    %macc(s,2) = mean(results(3).latents(s).acc(data(s).s==4)) - mean(results(3).latents(s).acc(data(s).s==5));
end

d = acc(:,1) - acc(:,2);
%err = zeros(2);
err = sem(acc,1);
m = mean(acc);
figure;
barerrorbar(m',err');
set(gca,'XTickLabel',{'Data' 'Model'},'FontSize',25,'XLim',[0.5 2.5],'YLim',[0 0.55]);
ylabel('Go bias','FontSize',25);

d = macc(:,1) - macc(:,2);
err(:,2) = std(d)./sqrt(length(d));
m(:,2) = mean(acc);

barerrorbar(m',err');
set(gca,'XTickLabel',{'Data' 'Model'},'FontSize',25,'XLim',[0.5 2.5],'YLim',[0 0.55]);
ylabel('Go bias','FontSize',25);

[~,p,~,stat] = ttest(acc(:,1),acc(:,2));
d = mean(acc(:,1)-acc(:,2))./std(acc(:,1)-acc(:,2));
disp(['go bias (experiment 2): t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p),', d = ',num2str(d)]);

end