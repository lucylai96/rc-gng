function [lme_bias,lme_complexity] = bias_lme
    
    % Mixed effects regression analysis of bias.
    
    load results_collins14.mat
    data = load_data;
    
    cond = [data.cond];
    
    % run regression
    n = length(cond);
    for i=1:5
        setsize(:,i) = zeros(n,1)+i;
        sub(:,i) = (1:n)';
    end
    
    tbl = table;
    tbl.SZ = categorical(repmat(cond',5,1));
    tbl.setsize = categorical(setsize(:));
    tbl.bias = results.bias(:);
    tbl.complexity = results.R_data(:);
    tbl.sub = sub(:);
    
     % look at the differences in bias away from curve between healthy and SZ
    lme_bias = fitlme(tbl,'bias ~ SZ*setsize + (setsize|sub)');
    anova(lme_bias) 
    % main effects of 'setsize' [F (4,415) = 6.99, p < 0.001] and group 'SZ' [F(1,415) = 5.76, p < 0.05]
    % as well as an interaction between 'SZ:setsize' [F(4,415) = 4.07, p < 0.005]. 
    % Average bias was larger for higher set sizes and for the SZ group
    % Interaction: the bias difference between the groups grew as a function of set size.
    
    
    % look at the differences in complexity between healthy and SZ
    lme_complexity = fitlme(tbl,'complexity ~ SZ*setsize + (setsize|sub)');
    anova(lme_complexity) 
    % F(1,415) = 11.51, policy complexity was significantly lower for the SZ group,
    % Interaction: none, the complexity difference between the groups does not change a function of set size 'SZ:setsize'
    
    
    biasdiff_HC = results.bias(cond==0,end) - results.bias(cond==0,1);
    biasdiff_SZ = results.bias(cond==1,end) - results.bias(cond==1,1);
    [~,p,~,stat] = ttest2(biasdiff_HC,biasdiff_SZ);
    disp(['HC vs. SZ, setsize 6 - 2: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
    
    [~,p,~,stat] = ttest(results.bias(cond==0,1),results.bias(cond==0,end));
    disp(['HC, setsize 2 vs. 6: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
    [~,p,~,stat] = ttest(results.bias(cond==1,1),results.bias(cond==1,end));
    disp(['SZ, setsize 2 vs. 6: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);