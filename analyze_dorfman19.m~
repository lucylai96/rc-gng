function analyze_dorfman19

data = load_data('data2.csv');
%load results2


% optimal R-C curves for her task
beta = linspace(0.1,15,50);
Ps = [0.33 0.33 0.33];
Q = [0.75 0.25;0.25 0.75; 0.5 0.5];
[R(1,:),V(1,:)] = blahut_arimoto(Ps,Q,beta);

Q = [0.75 0.25;0.25 0.75; 0.8 0.2];
[R(2,:),V(2,:)] = blahut_arimoto(Ps,Q,beta);

plot(R',V','-o')
legend('Low control','High control')


% Question: was p(A) actually high in LC even though optimally it should be
% equal?

for c = 1:2
    for s = 1:length(data)
        ix = data(s).cond == c;
        for a = 1:2
            p(s,a,c) = sum(data(s).a(ix)==a)/length(data(s).a(ix));
        end
    end
end

figure; hold on;
barwitherr(squeeze(sem(p,1))',squeeze(mean(p))')
xticks([1 2])
xticklabels({'LC','HC'})
l = legend('no-go','go')
title(l,'action')

% Go bias for experiment 2
for s = 1:length(data)
    acc(s,1) = mean(data(s).acc(data(s).s==1)) - mean(data(s).acc(data(s).s==2));
    acc(s,2) = mean(data(s).acc(data(s).s==4)) - mean(data(s).acc(data(s).s==5));
    macc(s,1) = mean(results(3).latents(s).acc(data(s).s==1)) - mean(results(3).latents(s).acc(data(s).s==2));
    macc(s,2) = mean(results(3).latents(s).acc(data(s).s==4)) - mean(results(3).latents(s).acc(data(s).s==5));
end

d = acc(:,1) - acc(:,2);
err = zeros(2);
err(:,1) = std(d)./sqrt(length(d));
m(:,1) = mean(acc);

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