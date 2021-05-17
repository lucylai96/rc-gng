function plot_figures(fig, results, data)
% Plot figures for Pavlovian bias as policy compression
%
% USAGE: plot_figures(fig,[results],[data])
%
% INPUTS:
%   fig - {'fig2', 'fig3', 'fig4'}

if nargin < 2; load gng_results.mat; end % results = analyze_gng(data)
if nargin < 3; load gng_data.mat; end %data = analyze_rawdata; end

if nargin < 1 % plot all figures
    close all
    %fig = {'reward-complexity','bias-complexity','conditions','gobias','beta-complexity'};
    fig = [];
    plot_figures('reward-complexity');
    plot_figures('bias-complexity');
    plot_figures('conditions');
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
        plot(squeeze(nanmean(results.R)),squeeze(nanmean(results.V)))
        legend(legStr)
        xlabel('Policy complexity')
        ylabel('Average reward')
        for s = 1:length(data)
            for c = 1:length(unique(data(s).cond))
                plot(results.R_data(:,c),results.V_data(:,c),'.','MarkerSize',30)
            end
        end
        
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
        [r,p] = corr(x(:),y(:),'type','spearman')
        
        xlabel('Policy complexity');
        ylabel('Bias');
        legend(H,legStr)
        
    case 'conditions'
        % does each condition have diff learned policy complexities?
        figure; hold on;
        subplot 121; hold on;
        x = 1:C;
        for c = 1:C
            scatter(c*ones(size(results.R_data,1),1),results.R_data(:,c),100,map(c,:),'filled','MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',1.5,'MarkerFaceAlpha',0.6','jitter','on','jitterAmount',0.1); hold on;
        end
        hold on;
        [mu,~,ci] = normfit(results.R_data);
        err = diff(ci)/2;
        errorbar(x,mu,err,'Color','k','LineWidth',2,'CapSize',0);
        
        ylabel('Policy complexity');
        xlabel('Condition');
        xlim([0 6])
        hold on;
        % does each condition have diff biases?
        subplot 122; hold on;
        
        for c = 1:C
            scatter(c*ones(size(results.bias,1),1),results.bias(:,c),100,map(c,:),'filled','MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',1.5,'MarkerFaceAlpha',0.6','jitter','on','jitterAmount',0.1); hold on;
        end
        hold on;
        [mu,~,ci] = normfit(results.bias);
        err = diff(ci)/2;
        
        errorbar(x,mu,err,'Color','k','LineWidth',2,'CapSize',0);
        xlabel('Condition');
        ylabel('Bias');
        xlim([0 6])
        %set(gcf,'Position',[200 200 1200 800])
        
    case 'gobias'
        figure; hold on;
        % dynamic go bias
        for s = 1:length(data)
            for c = 1:C
                gb(s,c) = mean(data(s).acc(data(s).s==1 & data(s).cond==c)) - mean(data(s).acc(data(s).s==2 & data(s).cond==c)); %go - nogo
                
                go = data(s).acc(data(s).s==1 & data(s).cond==c);
                nogo = data(s).acc(data(s).s==2 & data(s).cond==c);
                gobias(s,1:length(go),c) = movmean(go-nogo,10);
            end
        end
        
        
        err = sem(gb,1);
        m = mean(gb);
        
        subplot 311; hold on; % go bias bar
        [h] = barwitherr(err,m,'FaceColor','flat');
        for c = 1:C
            h.CData(c,:) = map(c,:); hold on;
        end
        ylabel('Go bias');
        axis tight
        xlim([0 6])
        %[m,~,ci] = normfit(gb);
        %err = diff(ci)/2;
        
        [~,p,~,stat] = ttest(gb(:,2),gb(:,3));
        disp(['HS-LC vs. HS-HC: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
        
        [~,p,~,stat] = ttest(gb(:,2),gb(:,5));
        disp(['HS-LC vs. LS-HC: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
        
        
        subplot 312; hold on; % go bias bar
        [h] = barwitherr(err,m,'FaceColor','flat');
        for c = 1:C
            h.CData(c,:) = map(c,:); hold on;
            scatter(c*ones(size(gb,1),1),gb(:,c),100,map(c,:),'filled','MarkerEdgeColor',[1 1 1],'LineWidth',1.5,'MarkerFaceAlpha',0.75','jitter','on','jitterAmount',0.1); hold on;
        end
        ylabel('Go bias');
        axis tight
        xlim([0 6])
        
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
        ylim([0 1])
        xlim([0 length(go)])
        
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
        b
        
    case 'mov_params' % only for model
        figure; hold on;
        movbeta = zeros(length(data),length(data(1).beta(data(1).cond==2)));
        movcost = zeros(length(data),length(data(1).cost(data(1).cond==2)));
        movtheta = zeros(length(data)*2,length(data(1).theta(data(1).cond==2)));
        
        for s = 1:length(data)
            for c = 1:C
                movbeta(s,1:length(data(s).beta(data(s).cond==c)),c) = movmean(data(s).beta(data(s).cond==c),10);
                movcost(s,1:length(data(s).cost(data(s).cond==c)),c) = movmean(data(s).cost(data(s).cond==c),10);
                movtheta(s*2-1:s*2,1:length(data(s).theta(data(s).cond==c,:)),c) = data(s).theta(data(s).cond==c,:)';
            end
        end
        movbeta(movbeta==0) = NaN;
        
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
            t(3) = shadedErrorBar(1:size(dtheta,2),mean(dtheta),sem(dtheta,1),{'Color',[0 0 0]},1);
            handles(3) = t(3).mainLine;
        end
        subplot(1,C,1)
        legend(handles,{'\theta_1 (Instrumental)','\theta_2 (Pavlovian)','\theta_1-\theta_2'})
        ylabel('\theta');
        xlabel('Trials');
        equalabscissa(1,C)
        set(gcf, 'Position',  [400, 200, 1000, 400])
        
        
        
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