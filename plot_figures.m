function plot_figures(fig, results, data)
% Plot figures for Pavlovian bias as policy compression
%
% USAGE: plot_figures(fig,[results],[data])

% INPUTS:
%   fig - {'fig2', 'fig3', 'fig4'}

if nargin < 2; load gng_results.mat; end % results = analyze_gng(data)
if nargin < 3; load gng_data.mat; end %data = analyze_rawdata; end

if nargin < 1 % plot all figures
    fig = 1;
    plot_figures('params');
    plot_figures('reward-complexity');
    plot_figures('bias-complexity');
    plot_figures('gobias');
    plot_figures('beta-complexity');
    
end

rng(1); % set random seed for reproducibile bootstrapped confidence intervals
C = length(unique(data(1).cond));
map = gngColors(C);
legStr = data(1).legStr;

switch fig
    case 'reward-complexity'
        % theoretical curves
        figure; hold on;
        subplot 231; hold on;
        plot(squeeze(nanmean(results.R)),squeeze(nanmean(results.V)),'LineWidth',3)
        legend(legStr)
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
        subplot 121; hold on;
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
        
        % does each condition have diff bias away from curve?
        subplot 122; hold on;
        
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
        set(gcf,'Position',[0 300 1200 500])
        
        
        % compare policy complexities between groups
        % separate by control and similarity
        figure; hold on;
        pc = results.R_data;
        ctrlpc = [[pc(:,2);pc(:,4)],[pc(:,3);pc(:,5)]]; % cluster by LC vs HC
        simpc = [[pc(:,4);pc(:,5)],[pc(:,2);pc(:,3)]]; % cluster by HS vs LS
        
        subplot 121; hold on;
        [h] = barwitherr(sem(ctrlpc,1),mean(ctrlpc),'FaceColor','flat');
        h.CData(1,:) = [0 0 0]; hold on;
        h.CData(2,:) = [1 1 1]; hold on;
        ylabel('Policy complexity');
        title('LowCtrl vs. HiCtrl')
        xlim([0 3])
        xticks([]);
        
        subplot 122; hold on;
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
        equalabscissa(1,2)
        
        set(gcf,'Position',[300 500 900 300])
       
        
        
    case 'bias-complexity'
        
        figure; hold on;
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
        legend(H,legStr)
        
    case 'gobias'
        figure; hold on;
        gb=results.gb;
        gobias = results.gobias;
        err = sem(gb,1);
        m = mean(gb);
        
        %[m,~,ci] = normfit(gb);
        %err = diff(ci)/2;
        
        % separate by control and similarity
        ctrlgb = [[gb(:,2);gb(:,4)],[gb(:,3);gb(:,5)]]; % cluster by LC vs HC
        simgb = [[gb(:,4);gb(:,5)],[gb(:,2);gb(:,3)]]; % cluster by LS vs HS
        
        subplot 121; hold on;
        [h] = barwitherr(sem(ctrlgb,1),mean(ctrlgb),'FaceColor','flat');
        h.CData(1,:) = [0 0 0]; hold on;
        h.CData(2,:) = [1 1 1]; hold on;
        ylabel('Go bias');
        title('LowCtrl vs. HiCtrl')
        xlim([0 3])
        xticks([]);
        
        subplot 122; hold on;
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
        equalabscissa(1,2)
        
        set(gcf,'Position',[300 500 900 300])
        
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
        
        subplot 312; hold on; % go bias bar
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
        legend(handles,legStr)
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
        %             lgd = legend(h,{'2' '3' '4' '5' '6'},'FontSize',25,'Location','NorthWest');
        %             title(lgd,'Set size','FontSize',25);
        %             set(gca,'FontSize',25);
        xlabel('Policy complexity');
        ylabel('\beta');
        legend(h,legStr)
        disp(['beta: ',num2str(b)]);
        
    case 'params' % only for model
        load model_fits.mat
        
        for m = 1:length(results) % for each fitted model
            figure; hold on;
            subplot(size(results(m).x,2)+1,1,1); hold on;
            %plot(results(m).x','k.','MarkerSize',20)
            scatter([ones(size(results(m).x,1),1); 2*ones(size(results(m).x,1),1)],results(m).x(:),150,'k','filled','MarkerEdgeColor',[1 1 1],'LineWidth',1.5,'MarkerFaceAlpha',0.8','jitter','on','jitterAmount',0.1); hold on;
        
            xlim([0 size(results(m).x,2)+1])
            xticks([1:size(results(m).x,2)])
            xticklabels({results(m).param.name})
            
            for i = 1:size(results(m).x,2)
                subplot(size(results(m).x,2)+1,1,i+1); hold on;
                histogram(results(m).x(:,i),25)
                title(results(m).param(i).name)
            end
            set(gcf, 'Position',  [0, 0, 400, 1200])
            
            [simdata, simresults] = sim_gng(m,data,results);
            
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
            legend(handles,{'\theta_1 (Instrumental)','\theta_2 (Pavlovian)'})
            ylabel('\theta');
            xlabel('Trials');
            equalabscissa(1,C)
            set(gcf, 'Position',  [0, 200, 1400, 300])
            
            
            plot_figures('reward-complexity',simresults,simdata);
            plot_figures('bias-complexity',simresults,simdata);
            plot_figures('gobias',simresults,simdata);
            plot_figures('beta-complexity',simresults,simdata);
            close all
             
        end % for each fitted model
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