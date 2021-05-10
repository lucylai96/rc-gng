function plot_figures(fig, results, data)
% Plot figures.
%
% USAGE: plot_figures(fig,[results],[data])
%
% INPUTS:
%   fig - {'fig2', 'fig3', 'fig4'}

if nargin < 2; load gng_results.mat; end % results = analyze_gng(data)
if nargin < 3; load gng_data.mat; end %data = analyze_rawdata; end

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
        
    case 'gobias'
        % dynamic go bias
        for s = 1:length(data)
            for c = 1:C
                acc(s,c) = mean(data(s).acc(data(s).s==1 & data(s).cond==c)) - mean(data(s).acc(data(s).s==2 & data(s).cond==c)); %go - nogo
                
                go = data(s).acc(data(s).s==1 & data(s).cond==c);
                nogo = data(s).acc(data(s).s==2 & data(s).cond==c);
                gobias(s,1:length(go),c) = movmean(go-nogo,10);
            end
        end
        
        
        err = sem(acc,1);
        m = mean(acc);
        
        figure; hold on;
        subplot 211; hold on; % go bias bar
        [h] = barwitherr(err,m,'FaceColor','flat');
        for c = 1:C
            h.CData(c,:) = map(c,:); hold on;
            scatter(c*ones(size(acc,1),1),acc(:,c),100,map(c,:),'filled','MarkerEdgeColor','k','LineWidth',1.5,'MarkerFaceAlpha',0.8','jitter','on','jitterAmount',0.1); hold on;
        end
        ylabel('Go bias');
        ylim([0 1])
        
        subplot 212; hold on; % dynamic go bias
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
        
        
    case 'mov_params' % only for model
        movbeta = zeros(length(data),length(data(1).beta(data(1).cond==2)));
        movtheta = zeros(length(data)*2,length(data(1).theta(data(1).cond==2)));
        
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

function H = myeb(Y,varargin)
%
% myeb(Y,varargin);
%
% This function makes nice coloured, shaded error bars. Exactly what
% it does depends on Y, and on whether you give it one or two inputs.
%
% If you only pass it Y, and no other arguments, it assuemd you're
% giving it raw data.
%
%		myeb(Raw_Data)
%
% 	.) if Y is 2D array, it will then plot mean(Y) with errorbars given
% 	by std(Y). In this case there is only one mean vector with its
% 	errorbars.
%
%	.) if Y is 3D array, it will plot size(Y,3) lines with the
%	associated errorbars. Line k will be mean(Y(:,:,k)) with errorbars
%	given by std(Y(:,:,k))
%
% If you pass it 2 arguments, each has to be at most 2D.
%
%		myeb(mu,std)
%
% 	.) if mu and std are 1D, it just plots one line given by mu with a
% 	shaded region given by std.
%
%	.) if mu and std are 2D, it will plot size(Y,2) lines in the
%	standard sequence of colours; each line mu(:,k) will have a shaded
%	region in the same colour, but less saturated given by std(:,k)


%col=[0 0 1; 0 .5 0; 1 0 0; 0 1 1; 1 0 1; 1 .5 0; 1 .5 1];
%col=[0.8 0.5 0; 0 0 1; 0 .5 0; 1 0 0; 1 0 1; 1 .5 0; 1 .5 1];
%col = linspecer(size(Y,2));
%col = col([1 end],:);
col = linspecer(2);
ccol=col+.5; ccol(ccol>1)=1;

if isempty(varargin)
    
    if length(size(Y))==2
        m=mean(Y);
        s=std(Y);
        ind1=1:length(m);
        ind2=ind1(end:-1:1);
        %hold on; h=fill([ind1 ind2],[m-s m(ind2)+s(ind2)],.6*ones(1,3));
        hold on; h=fill([ind1 ind2],[m-s m(ind2)+s(ind2)],.6*[1 0 0]);
        set(h,'edgecolor',.6*[1 0 0])
        H = plot(ind1,m,'LineWidth',4);
        hold off
    elseif length(size(Y))>2
        cla; hold on;
        ind1=1:size(Y,2);
        ind2=ind1(end:-1:1);
        if size(Y,3)>8; col=jet(size(Y,3));ccol=col+.8; ccol(ccol>1)=1;end
        for k=1:size(Y,3)
            m=mean(Y(:,:,k));
            s=std(Y(:,:,k));
            h=fill([ind1 ind2],[m-s m(ind2)+s(ind2)],ccol(k,:));
            set(h,'edgecolor',ccol(k,:))
        end
        for k=1:size(Y,3)
            m=mean(Y(:,:,k));
            s=std(Y(:,:,k));
            H = plot(ind1,m,'LineWidth',4,'color',col(k,:));
        end
        hold off
    end
    
elseif length(varargin)==1
    
    m=Y;
    s=varargin{1};
    if length(size(Y))>2; error;
    elseif min(size(Y))==1
        if size(m,1)>1; m=m';s=s';end
        ind1=1:length(m);
        ind2=ind1(end:-1:1);
        hold on; h=fill([ind1 ind2],[m-s m(ind2)+s(ind2)],.6*ones(1,3));
        set(h,'edgecolor',.6*ones(1,3))
        H = plot(ind1,m,'LineWidth',4);
        hold off
    else
        
        ind1=(1:size(Y,1));
        ind2=ind1(end:-1:1);
        cla; hold on;
        for k=1:size(Y,2)
            H = plot(ind1,m(:,k)','LineWidth',4,'color',col(k,:));
        end
        if size(Y,2)>8; col=jet(size(Y,2));ccol=col+.8; ccol(ccol>1)=1;end
        for k=1:size(Y,2)
            mm=m(:,k)';
            ss=s(:,k)';
            h=fill([ind1 ind2],[mm-ss mm(ind2)+ss(ind2)],ccol(k,:));
            set(h,'edgecolor',ccol(k,:));
        end
        for k=1:size(Y,2)
            mm=m(:,k)';
            H = plot(ind1,mm,'LineWidth',4,'color',col(k,:));
        end
        hold off
    end
    
elseif length(varargin)==2
    
    m=Y;
    s=varargin{1};
    ix = varargin{2};
    if length(size(Y))>2
        error;
    elseif min(size(Y))==1
        if size(m,1)>1; m=m';s=s';end
        ind1=1:length(m);
        ind2=ind1(end:-1:1);
        hold on; h=fill([ix(ind1) ix(ind2)],[m-s m(ind2)+s(ind2)],.6*ones(1,3));
        set(h,'edgecolor',.6*ones(1,3))
        H = plot(ix(ind1),m,'LineWidth',4);
        hold off
    else
        ind1=(1:size(Y,1));
        ind2=ind1(end:-1:1);
        cla; hold on;
        if size(Y,2)>8; col=jet(size(Y,2));ccol=col+.8; ccol(ccol>1)=1;end
        for k=1:size(Y,2)
            mm=m(:,k)';
            ss=s(:,k)';
            h=fill([ix(ind1) ix(ind2)],[mm-ss mm(ind2)+ss(ind2)],ccol(k,:));
            set(h,'edgecolor',ccol(k,:))
        end
        for k=1:size(Y,2)
            mm=m(:,k)';
            ss=s(:,k)';
            H = plot(ix(ind1),mm,'LineWidth',4,'color',col(k,:));
        end
        hold off
    end
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