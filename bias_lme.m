function [lme_bias,lme_complexity] = bias_lme
    
    % Mixed effects regression analysis of bias.
    
    load gng_results.mat
    load gng_data.mat
    
    cond = [data.cond]; % 1:5 depending on condition (trials x subjects)
    
    % factors: similarity(2)  controllability(2)  setsize(2)   go_bias  policy complexity   subject#
    % table is subject x factors = 78 x 6
    % 3 interactions: full model
    % subsets of interactions 
    
    % run regression
    n = size(cond,2);         % num subjects
    sim = [zeros(78,1) ones(78,1) ones(78,1) zeros(78,1) zeros(78,1)];
    ctrl = [zeros(78,1) zeros(78,1) ones(78,1) zeros(78,1) ones(78,1)];
    setsize = [zeros(78,1) ones(78,1) ones(78,1) ones(78,1) ones(78,1)];
    sub = repmat([1:n]',1,5); % [subject x conditions]
     
    tbl = table;
    tbl.sim = categorical(sim(:));
    tbl.ctrl = categorical(ctrl(:));
    tbl.setsize = categorical(setsize(:));
    tbl.gobias = results.gb(:); % 78*5 = 390
    tbl.complexity = results.R_data(:);
    tbl.sub = sub(:); %75x5 conditions
    

    % differences in gobias between similarity groups
    lme_bias = fitlme(tbl,'gobias ~ sim*ctrl + (setsize|sub)');
    anova(lme_bias)
    % Main effect of similarity [F(1,386) = 6.65, p = 0.01]; gobias was significantly higher for HiSim group
    % No interaction, the gobias between similarity groups does not change a function of controllability
   
    % differences in complexity between similarity groups
    lme_complexity = fitlme(tbl,'complexity ~ sim*ctrl + (setsize|sub)');
    anova(lme_complexity)
    % Main effect of similarity [F(1,386) = 33.19, p <0.001] and
    % controllability  [F(1,386) = 21.91, p <0.001]; policy complexity was significantly different between groups 
    % No interaction, the complexity between similarity groups does not change a function of controllability
   
   