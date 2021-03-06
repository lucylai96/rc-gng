function plot_figures(fig, results, data, mresults)
% Plot figures for Pavlovian bias as policy compression
%
% USAGE: plot_figures(fig,[results],[data])

% INPUTS:
%   fig - {'fig2', 'fig3', 'fig4'}

if nargin < 2; load('gng_results.mat'); end
if nargin < 3; load('gng_data.mat'); end
if nargin < 4; model = load('model_fits12.mat'); mresults = model.results; end

if nargin < 1 % plot all figures
    fig = 1;
    plot_figures('all')
end

% plot_figures('capacity', results, data)
% plot_figures('bic', results, data)
% plot_figures('params_winmodel');
% plot_figures('params_altmodel');
% plot_figures('params_dorfman_adapt');
% plot_figures('params_dorfman_fix');


rng(1); % set random seed for reproducible bootstrapped confidence intervals
C = length(unique(data(1).cond));
map = gngColors(C);
legStr = data(1).legStr;

switch fig
    case 'all'
        plot_figures('capacity', results, data)
        plot_figures('reward-complexity', results, data);
        plot_figures('bias-complexity', results, data);pause(1)
        plot_figures('gobias', results, data); 
        plot_figures('bar-gb-pc', results, data);
        plot_figures('beta-complexity', results, data);
        %plot_figures('rt', results, data)
        
    case 'rt'
        figure; hold on;
          subplot 121; hold on;
        for c = 1:C
            scatter(c*ones(size(results.rt.mean,1),1),results.rt.mean(:,c),150,map(c,:),'filled','MarkerEdgeColor',[1 1 1],'LineWidth',1.5,'MarkerFaceAlpha',0.8','jitter','on','jitterAmount',0.15); hold on;
        end
        hold on;
        x = 1:C;
        [mu,~,ci] = normfit(results.rt.mean);
        err = diff(ci)/2;
        hBar = errorbar(x,mu,err,'Color','k','LineWidth',2,'CapSize',0);
        ylabel('Reaction time (ms)');
        xticks([1:C])
        xticklabels(legStr); xtickangle(45)
        xlim([0 6])
        
        subplot 122; hold on;
        plot(results.R_data,results.rt.mean,'.','MarkerSize',30)
        ylabel('Reaction time (ms)')
        xlabel('Policy complexity')
        
        
    case 'reward-complexity'
        
        % theoretical curves
        figure; hold on;
        subplot 231; hold on;
        plot(squeeze(nanmean(results.R)),squeeze(nanmean(results.V)),'LineWidth',3)
        legend(legStr,'Location','Best');
        xlabel('Policy complexity')
        ylabel('Average reward')
        title('Optimal trade-off curves')
        axis tight
        
        for c = 1:length(unique(data(1).cond))
            subplot(2,3,c+1); hold on;
            plot(results.R_data(:,c),results.V_data(:,c),'.','MarkerSize',20,'Color',map(c,:))
            plot(nanmean(results.R(:,:,c)),nanmean(results.V(:,:,c)),'LineWidth',3,'Color',map(c,:))
            title(legStr{c})
        end
        equalabscissa(2,3)
        set(gcf,'Position',[0 300 1000 700])
        
        % does each condition have diff learned policy complexities?
        figure; hold on;
        subplot 131; hold on;
        x = 1:C;
        for c = 1:C
            scatter(c*ones(size(results.R_data,1),1),results.R_data(:,c),150,map(c,:),'filled','MarkerEdgeColor',[1 1 1],'LineWidth',1.5,'MarkerFaceAlpha',0.8','jitter','on','jitterAmount',0.15); hold on;
        end
        hold on;
        [mu,~,ci] = normfit(results.R_data);
        err = diff(ci)/2;
        hBar = errorbar(x,mu,err,'Color','k','LineWidth',2,'CapSize',0);
        %ctr2 = bsxfun(@plus, hBar.XData, [hBar.XOffset]');
        %%hold on
        %plot(ctr2(1:2), [1 1]*x(1,2)*1.1, '-k', 'LineWidth',2)
        %plot(mean(ctr2(1:2)), x(1,2)*1.15, '*k')
        %hold off
        
        ylabel('Policy complexity');
        xticks([1:C])
        xticklabels(legStr); xtickangle(45)
        xlim([0 6])
        hold on;
        
        % how does empirical policy complexity change over time?
        subplot 132;  hold on;
        R_data_movmean = squeeze(nanmean(results.R_data_mov)); % avg over subject
        R_data_movmean(R_data_movmean==0) = NaN;
        plot(R_data_movmean,'LineWidth',3)
        ylabel('Empirical policy complexity');
        xlabel('Binned trials (bins of 10)');
        legend(legStr,'Location','Best');
        set(gcf,'Position',[0 300 1200 500])
        
        % does each condition have diff bias away from curve?
        subplot 133; hold on;
        
        for c = 1:C
            scatter(c*ones(size(results.bias,1),1),results.bias(:,c),150,map(c,:),'filled','MarkerEdgeColor',[1 1 1],'LineWidth',1.5,'MarkerFaceAlpha',0.8','jitter','on','jitterAmount',0.15); hold on;
        end
        hold on;
        [mu,~,ci] = normfit(results.bias);
        err = diff(ci)/2;
        errorbar(x,mu,err,'Color','k','LineWidth',2,'CapSize',0);
        xticks([1:C])
        xticklabels(legStr); xtickangle(45)
        ylabel('Deviation from optimality');
        xlim([0 6])
        
        
    case 'bias-complexity' % residuals vs complexity | go bias vs complexity
        
        % residuals vs complexity
        figure; hold on;
        subplot 121; hold on;
        x = results.R_data;
        y = results.bias;
        
        plot(x(:),y(:),'.'); hold on;
        H = lsline; set(H,'LineWidth',3,'Color','k');
        plot(results.R_data,results.bias,'.','MarkerSize',30)
        %         for c = 1:C
        %             y(c,:) = results.bias(:,c);
        %             x(c,:) = results.R_data(:,c);
        %             plot(x(c,:),y(c,:),'.','Color',map(c,:),'MarkerSize',30,'LineWidth',3);
        %
        %         end
        
        [r,p,rl,ru] = corrcoef(x(:),y(:));
        disp(['r = ',num2str(r(2,1)),', p = ',num2str(p(2,1)),', CI = [',num2str(rl(2,1)),',',num2str(ru(2,1)),']']);
        [r,p] = corr(x(:),y(:),'type','spearman');
        
        xlabel('Policy complexity');
        ylabel('Deviation from optimality');
        
        % go bias vs complexity
        x = results.R_data;
        y = results.gb;
        subplot 122; hold on;
        plot(x(:),y(:),'.','MarkerSize',30)
        H = lsline; set(H,'LineWidth',3,'Color','k');
        xlabel('Policy complexity');
        ylabel('Go bias');
        
        set(gcf,'Position',[0 300 1000 300])
        
    case 'bar-gb-pc'
        % bar plots for go bias and policy complexity grouped by control
        % and similarity
        
        % compare policy complexities between groups
        figure; hold on;
        pc = results.R_data;
        
        % separate by control and similarity
        ctrlpc = [[pc(:,2);pc(:,4)],[pc(:,3);pc(:,5)]]; % cluster by LC vs HC
        simpc = [[pc(:,4);pc(:,5)],[pc(:,2);pc(:,3)]]; % cluster by HS vs LS
        
        subplot 221; hold on;
        [h] = barwitherr(sem(ctrlpc,1),mean(ctrlpc),'FaceColor','flat');
        h.CData(1,:) = [0 0 0]; hold on;
        h.CData(2,:) = [1 1 1]; hold on;
        ylabel('Policy complexity');
        title('LowCtrl vs. HiCtrl')
        xlim([0 3])
        ylim([0 0.3])
        xticks([]);
        
        subplot 222; hold on;
        [h] = barwitherr(sem(simpc,1),mean(simpc),'FaceColor','flat');
        h.CData(1,:) = [0 0 0]; hold on;
        h.CData(2,:) = [1 1 1]; hold on;
        ylabel('Policy Complexity');
        title('LowSim vs. HiSim')
        xticks([]);
        yline = 0.32;
        %line([1 2],[yline yline],'LineWidth',3 ,'Color','black')
        %text(1.5, yline+0.01,'*','FontSize',30)
        %text(1.5, yline+0.02,'      p<0.05','FontSize',17)
        %axis tight
        xlim([0 3])
        ylim([0 0.3])
        
        % compare go bias between groups
        gb = results.gb;         % static
        gobias = results.gobias; % dynamic
        
        % separate by control and similarity
        ctrlgb = [[gb(:,2);gb(:,4)],[gb(:,3);gb(:,5)]]; % cluster by LC vs HC
        simgb = [[gb(:,4);gb(:,5)],[gb(:,2);gb(:,3)]]; % cluster by LS vs HS
        
        subplot 223; hold on;
        [h] = barwitherr(sem(ctrlgb,1),mean(ctrlgb),'FaceColor','flat');
        h.CData(1,:) = [0 0 0]; hold on;
        h.CData(2,:) = [1 1 1]; hold on;
        ylabel('Go bias');
        title('LowCtrl vs. HiCtrl')
        xlim([0 3])
        ylim([0 0.6])
        xticks([]);
        
        subplot 224; hold on;
        [h] = barwitherr(sem(simgb,1),mean(simgb),'FaceColor','flat');
        h.CData(1,:) = [0 0 0]; hold on;
        h.CData(2,:) = [1 1 1]; hold on;
        ylabel('Go bias');
        title('LowSim vs. HiSim')
        xticks([]);
        yline = 0.32;
        %line([1 2],[yline yline],'LineWidth',3 ,'Color','black')
        %text(1.5, yline+0.01,'*','FontSize',30)
        %text(1.5, yline+0.02,'      p<0.05','FontSize',17)
        %axis tight
        xlim([0 3])
        ylim([0 0.6])
        
        set(gcf,'Position',[300 500 800 800])
        
        disp('Setsize 2 vs. 4')
        [~,p,~,stat] = ttest(gb(:,1),gb(:,3));
        disp(['Baseline (Sz=2) vs. HS-HC (Sz=4): t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p),newline]);
        
        disp('Setsize 2 vs. 4')
        [~,p,~,stat] = ttest(gb(:,1),gb(:,3));
        disp(['Baseline (Sz=2) vs. HS-HC (Sz=4): t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p),newline]);
        
        disp('(AllSim) LowCtrl vs HiCtrl')
        [~,p,~,stat] = ttest([gb(:,2);gb(:,4)],[gb(:,3);gb(:,5)]);
        disp(['LC vs. HC: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p),newline]);
        
        disp('(HiSim) LowCtrl vs HiCtrl')
        [~,p,~,stat] = ttest(gb(:,2),gb(:,3));
        disp(['HS-LC vs. HS-HC: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p),newline]);
        
        disp('(LowSim) LowCtrl vs HiCtrl')
        [~,p,~,stat] = ttest(gb(:,4),gb(:,5));
        disp(['LS-LC vs. LS-HC: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p),newline]);
        
        disp('(AllCtrl) LowSim vs HiSim')
        [~,p,~,stat] = ttest([gb(:,2);gb(:,3)],[gb(:,4);gb(:,5)]);
        disp(['LS vs. HS: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p),newline]);
        
        disp('(HiCtrl) LowSim vs HiSim')
        [~,p,~,stat] = ttest(gb(:,3),gb(:,5));
        disp(['LS-HC vs. HS-HC: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p),newline]);
        
        disp('(LowCtrl) LowSim vs HiSim')
        [~,p,~,stat] = ttest(gb(:,2),gb(:,4));
        disp(['LS-LC vs. HS-LC: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p),newline]);
        
        % almost significant difference between low and high control for high similarity p = 0.07
        % almost significant difference between low and high similarity (all control) p = 0.07
        % significant difference between low and high similarity for low control
        
        
        
    case 'gobias'
        
        gb = results.gb;         % static
        gobias = results.gobias; % dynamic
        err = sem(gb,1);
        m = mean(gb);
        
        %[m,~,ci] = normfit(gb);
        %err = diff(ci)/2;
        
        
        % go biases
        figure; hold on;
        subplot 311; hold on; % go bias bar
        [h] = barwitherr(err,m,'FaceColor','flat');
        for c = 1:C
            h.CData(c,:) = map(c,:); hold on;
        end
        ylabel('Go bias');
        axis tight
        xlim([0 6])
        xticks([]);
        
        subplot 312; hold on; % go bias bar with indv subj
        [h] = barwitherr(err,m,'FaceColor','flat');
        for c = 1:C
            h.CData(c,:) = map(c,:); hold on;
            scatter(c*ones(size(gb,1),1),gb(:,c),100,map(c,:),'filled','MarkerEdgeColor',[1 1 1],'LineWidth',1.5,'MarkerFaceAlpha',0.75','jitter','on','jitterAmount',0.12); hold on;
        end
        ylabel('Go bias');
        axis tight
        xlim([0 6])
        xticks([]);
        
        subplot 313; hold on; % dynamic go bias
        for c = 1:C
            l(c,:) = shadedErrorBar(1:size(gobias,2),mean(gobias(:,:,c)),sem(gobias(:,:,c),1),{'Color',map(c,:)},1);
        end
        
        for c = 1:C
            handles(c) = l(c).mainLine;
        end
        legend(handles,legStr,'Location','Best');
        ylabel('Go bias');
        xlabel('Trials');
        axis tight
        xlim([0 size(gobias,2)])
        xlim([0 30])
        set(gcf,'Position',[200 200 500 1200])
        
        
    case 'beta-complexity'
        % what value of beta is needed to meet capacity constraint?
        figure; hold on;
        beta = linspace(0.1,15,50);
        R = squeeze(mean(results.R));
        m = mean(results.R_data);
        
        for c = 1:C
            h(c) = plot(R(:,c),beta','-','LineWidth',4,'Color',map(c,:));
            hold on;
            ix = find(R(:,c)>=m(c),1); % find the theoretical policy complexity that's at the mean of the empirical policy complexity
            plot(R(ix,c),beta(ix),'.','LineWidth',4,'Color',map(c,:),'MarkerSize',50);
            b(c) = beta(ix);
        end
        
        xlabel('Policy complexity');
        ylabel('\beta');
        legend(h,legStr,'Location','Best');
        disp(['beta: ',num2str(b)]);
        
    case 'param-corr'  % how do parameters explain go bias and complexity?\
        for m = 1:length(mresults)           % for each fitted model
            figure; hold on;
            for i = 1:size(mresults(m).x,2)  % for each parameter
                for c = 1:C                  % for each condition
                    subplot(2,size(mresults(m).x,2),i); hold on;
                    scatter(mresults(m).x(:,i),results.gb(:,c),100,map(c,:),'filled','MarkerEdgeColor',[1 1 1],'LineWidth',1.5,'MarkerFaceAlpha',0.75); hold on;
                end
                H = lsline; set(H,'LineWidth',3,'Color','k');
                title(mresults(m).param(i).label)
                ylabel('Go bias')
            end
        end
        
        for m = 1:length(mresults)           % for each fitted model
            %figure; hold on;
            for i = 1:size(mresults(m).x,2)  % for each parameter
                for c = 1:C                  % for each condition
                    subplot(2,size(mresults(m).x,2),i+size(mresults(m).x,2)); hold on;
                    scatter(mresults(m).x(:,i),results.R_data(:,c),100,map(c,:),'filled','MarkerEdgeColor',[1 1 1],'LineWidth',1.5,'MarkerFaceAlpha',0.75','jitter','on','jitterAmount',0.12); hold on;
                end
                H = lsline; set(H,'LineWidth',3,'Color','k');
                xlabel('Parameter value')
                ylabel('Complexity')
            end
        end
        
        set(gcf,'Position',[300 300 1200 600])
        
    case 'capacity'
        %correlation between agent's C parameter and policy complexity in each conditions
        
        figure; hold on;
        subplot 121;
        xlabel('Capacity (fitted)')
        ylabel('Policy complexity (empirical)')
        dline; axis square; axis equal; axis square;
        for c = 1:C
            subplot 121; hold on;
            plot(mresults(2).x(:,1),results.R_data(:,c),'.','Color',map(c,:),'MarkerSize',20);
            subplot 122; hold on;
            histogram(results.R_data(:,c),30,'FaceColor',map(c,:));axis square;
            xlabel('Policy complexity');
        end
        
        
    case 'params_winmodel' % only for winning model
        m = 2;
        figure; hold on;
        for i = 1:size(mresults(m).x,2)
            subplot(1,size(mresults(m).x,2),i); hold on;
            histogram(mresults(m).x(:,i),25,'FaceColor','k')
            title(mresults(m).param(i).label);
            if i ==1;xlabel('Parameter value');end
        end
        set(gcf, 'Position',  [0, 0, 1200, 400])
        
        [simdata, simresults] = sim_gng(m,data,mresults);
        
        
        
        pause(1)
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
        legend(handles,{'\theta_1 (Instrumental)','\theta_2 (Pavlovian)'},'Location','Best');
        ylabel('\theta');
        xlabel('Trials');
        equalabscissa(1,C)
        set(gcf, 'Position',  [0, 200, 1400, 300])
        
        
        plot_figures('all',simresults,simdata);
        
    case 'params_altmodel' % simulation for alternative model
        m = 1;
        figure; hold on;
        
        for i = 1:size(mresults(m).x,2)
            subplot(1,size(mresults(m).x,2),i); hold on;
            histogram(mresults(m).x(:,i),25,'FaceColor','k')
            %title(results(m).param(i).label)
            title(mresults(m).param(i).label);
            if i ==1;xlabel('Parameter value');end
        end
        set(gcf, 'Position',  [0, 0, 1200, 400])
        
        [simdata, simresults] = sim_gng(m,data,mresults);
        
        pause(1)
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
        legend(handles,{'\theta_1 (Instrumental)','\theta_2 (Pavlovian)'},'Location','Best');
        ylabel('\theta');
        xlabel('Trials');
        equalabscissa(1,C)
        set(gcf, 'Position',  [0, 200, 1400, 300])
        
        
        plot_figures('all',simresults,simdata);
        
        
    case 'params_dorfman_adapt'
        
        m = 3;
        figure; hold on;
        for i = 1:size(mresults(m).x,2)
            subplot(1,size(mresults(m).x,2),i); hold on;
            histogram(mresults(m).x(:,i),25,'FaceColor','k')
            title(mresults(m).param(i).label);
            if i ==1;xlabel('Parameter value');end
        end
        set(gcf, 'Position',  [0, 0, 1200, 400])
        
        
        for s = 1:length(data)
            
            param = mresults(3).x(s,:); % fitted parameters to hayley's model
            simdata(s) = sim_adaptive(param,data(s)); % condition
        end
        
        % add a calculation of go bias and policy complexity (from our
        % analysis)
        simresults = analyze_gng(simdata);
        
        
        movcost = zeros(length(simdata),length(simdata(1).cost(simdata(1).cond==2)));
        w = zeros(length(simdata),length(simdata(1).w(simdata(1).cond==2))); % subjects x trials x condition
        for s = 1:length(simdata)
            for c = 1:C
                w(s,1:length(simdata(s).w(simdata(s).cond==c)),c) = movmean(simdata(s).w(simdata(s).cond==c),10);
                movcost(s,1:length(simdata(s).cost(simdata(s).cond==c)),c) = movmean(simdata(s).cost(simdata(s).cond==c),20);
                
            end
        end
        w(w==0) = NaN;
        movcost(movcost==0) = NaN;
        
        
        % w - adaptive weight
        figure; hold on;
        subplot 121; hold on;
        
        for c = 1:C
            t = shadedErrorBar(1:size(w,2),mean(w(:,:,c)),sem(w(:,:,c),1),{'Color',map(c,:)},1);
            handles(c) = t.mainLine;
        end
        
        legend(handles,legStr,'Location','Best');
        ylabel('Adaptive weight')
        xlabel('Trials');
        
        % policy cost
        subplot 122; hold on;
        for c = 1:C
            shadedErrorBar(1:size(movcost,2),mean(movcost(:,:,c)),sem(movcost(:,:,c),1),{'Color',map(c,:)},1);
        end
        ylabel('Policy complexity');
        xlabel('Trials');
        set(gcf, 'Position',  [400, 100, 600, 400])
        
        
        plot_figures('all',simresults,simdata);
        
    case 'params_dorfman_fix'
        
        m = 4;
        figure; hold on;
        for i = 1:size(mresults(m).x,2)
            subplot(1,size(mresults(m).x,2),i); hold on;
            histogram(mresults(m).x(:,i),25,'FaceColor','k')
            title(mresults(m).param(i).label);
            if i ==1;xlabel('Parameter value');end
        end
        set(gcf, 'Position',  [0, 0, 1200, 400])
        
        for s = 1:length(data)
            param = mresults(4).x(s,:); % fitted parameters to hayley's model
            simdata(s) = sim_fixed(param,data(s)); % condition
        end
        
        % add a calculation of go bias and policy complexity (from our
        % analysis)
        simresults = analyze_gng(simdata);
        
        
        movcost = zeros(length(simdata),length(simdata(1).cost(simdata(1).cond==2)));
        w = zeros(length(simdata),length(simdata(1).w(simdata(1).cond==2))); % subjects x trials x condition
        for s = 1:length(simdata)
            for c = 1:C
                w(s,1:length(simdata(s).w(simdata(s).cond==c)),c) = movmean(simdata(s).w(simdata(s).cond==c),10);
                movcost(s,1:length(simdata(s).cost(simdata(s).cond==c)),c) = movmean(simdata(s).cost(simdata(s).cond==c),20);
                
            end
        end
        w(w==0) = NaN;
        movcost(movcost==0) = NaN;
        
        
        % w - adaptive weight
        figure; hold on;
        subplot 121; hold on;
        
        for c = 1:C
            t = shadedErrorBar(1:size(w,2),mean(w(:,:,c)),sem(w(:,:,c),1),{'Color',map(c,:)},1);
            handles(c) = t.mainLine;
        end
        
        legend(handles,legStr,'Location','Best');
        ylabel('Adaptive weight')
        xlabel('Trials');
        
        % policy cost
        subplot 122; hold on;
        for c = 1:C
            shadedErrorBar(1:size(movcost,2),mean(movcost(:,:,c)),sem(movcost(:,:,c),1),{'Color',map(c,:)},1);
        end
        ylabel('Policy complexity');
        xlabel('Trials');
        set(gcf, 'Position',  [400, 100, 600, 400])
        
        plot_figures('all',simresults,simdata);
        
        
        
        
    case 'bic'
        figure; hold on;
        for i = 1:length(mresults)
            histogram(mresults(i).bic,50)
        end
        xlabel('BIC')
        ylabel('count')
        legend('No cost model','Cost model','Dorfman & Gershman 2019', 'Location','Best')
end
end

function [se, m] = wse(X,dim)

% Within-subject error, following method of Cousineau (2005).
%
% USAGE: [se, m] = wse(X,dim)
%
% INPUTS:
%   X - [N x D] data with N observations and D subjects
%   dim (optional) - dimension along which to compute within-subject
%   variance (default: 2)
%
% OUTPUTS:
%   se - [1 x D] within-subject standard errors
%   m - [1 x D] means
%
% Sam Gershman, June 2015

if nargin < 2; dim = 2; end
m = squeeze(nanmean(X));
X = bsxfun(@minus,X,nanmean(X,dim));
N = sum(~isnan(X));
se = bsxfun(@rdivide,nanstd(X),sqrt(N));
se = squeeze(se);
end