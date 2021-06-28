function [results,bms_results] = fit_models(data,models)

% Fit models to rc-gng data.

addpath('/Users/lucy/Google Drive/Harvard/Projects/mfit')

if nargin < 1
    load gng_data.mat;
end

% fit all models
if nargin < 2
    models = 1:3;
end

for m = models
    a = 2; b = 2; % for beta prior
    
    switch m
        case 1 % 4 free params: lrate_theta, lrate_V, lrate_p
            likfun = @actor_critic_lik; % NO COST MODEL
            param(1) = struct('name','lrate_theta','lb',0,'ub',1,'logpdf',@(x) sum(log(betapdf(x,a,b))),'label','\alpha_{\theta}');
            param(2) = struct('name','lrate_V','lb',0,'ub',1,'logpdf',@(x) sum(log(betapdf(x,a,b))),'label','\alpha_V');
            %param(3) = struct('name','lrate_p','lb',0,'ub',1,'logpdf',@(x) 0);
            %param(3) = struct('name','b','lb',0,'ub',1,'logpdf',@(x) 0); % b is initial bias to start at Go
            
        case 2 % 5 free params: C, lrate_theta, lrate_V, lrate_beta, b | fixed: lrate_p = 0, beta0 = 1 (beta is learned starting from beta0)
            likfun = @actor_critic_lik;
            %param(1) = struct('name','C','lb',0.01,'ub',log(3),'logpdf',@(x) 0,'label','C');
            %param(2) = struct('name','lrate_theta','lb',0,'ub',1,'logpdf',@(x) 0,'label','lrate_{\theta}');
            %param(3) = struct('name','lrate_V','lb',0,'ub',1,'logpdf',@(x) 0,'label','lrate_V');
            %param(4) = struct('name','lrate_beta','lb',0,'ub',1,'logpdf',@(x) 0,'label','lrate_{\beta}');
            
            param(1) = struct('name','C','lb',0.1,'ub',2,'logpdf',@(x) unifpdf(x,0.1,2),'label','C');
            param(2) = struct('name','lrate_theta','lb',0.7,'ub',1,'logpdf',@(x) 1,'label','\alpha_{\theta}');
            param(3) = struct('name','lrate_V','lb',0.7,'ub',1,'logpdf',@(x) 1,'label','\alpha_V');
            %param(4) = struct('name','lrate_e','lb',0,'ub',1,'logpdf',@(x) rand,'label','\alpha_{\eta}');
            
            %param(4) = struct('name','lrate_beta','lb',0,'ub',1,'logpdf',@(x) sum(log(betapdf(x,a,b))),'label','\alpha_{\beta}');
            %param(5) = struct('name','b','lb',0,'ub',1,'logpdf',@(x)  sum(log(unifpdf(x,0,1))),'label','b'); % b is initial bias to start at Go
            %param(6) = struct('name','beta0','lb',0,'ub',30,'logpdf',@(x) 0,'label','\beta_0'); % b is initial bias to start at Go
            
            %param(6) = struct('name','lrate_p','lb',0,'ub',1,'logpdf',@(x) sum(log(betapdf(x,a,b))),'label','lrate_{p}');
            % TODO: also try model where b is fixed to 0.3
        case 3
            likfun = @dorfman_adaptive_lik;
            pmin = 0.01;
            pmax = 100;
            btmin = 1e-3;
            btmax = 50;
            param(1) = struct('name','invtemp','logpdf',@(x) 0,'lb',btmin,'ub',btmax,'label','\beta');    % inverse temperature
            param(2) = struct('name','mq','logpdf',@(x) 0,'lb',0.001,'ub',0.999,'label','\theta_I');      % prior mean, instrumental
            param(3) = struct('name','pq','logpdf',@(x) 0,'lb',pmin,'ub',pmax,'label','\eta_I');          % prior confidence, instrumental
            param(4) = struct('name','mv','logpdf',@(x) 0,'lb',0.001,'ub',0.999,'label','\theta_P');      % prior mean, Pavlovian
            param(5) = struct('name','pv','logpdf',@(x) 0,'lb',pmin,'ub',pmax,'label','\eta_P');          % prior confidence, Pavlovian
        case 4
            likfun = @dorfman_fixed_lik;
            pmin = 0.01;
            pmax = 100;
            btmin = 1e-3;
            btmax = 50;
            param(1) = struct('name','invtemp','logpdf',@(x) 0,'lb',btmin,'ub',btmax,'label','\beta');    % inverse temperature
            param(2) = struct('name','w','logpdf',@(x) 0,'lb',0.001,'ub',0.999,'label','w');              % weight
            param(3) = struct('name','mq','logpdf',@(x) 0,'lb',0.001,'ub',0.999,'label','\theta_I');      % prior mean, instrumental
            param(4) = struct('name','pq','logpdf',@(x) 0,'lb',pmin,'ub',pmax,'label','\eta_I');          % prior confidence, instrumental
            param(5) = struct('name','mv','logpdf',@(x) 0,'lb',0.001,'ub',0.999,'label','\theta_P');      % prior mean, Pavlovian
            param(6) = struct('name','pv','logpdf',@(x) 0,'lb',pmin,'ub',pmax,'label','\eta_P');          % prior confidence, Pavlovian
    end
    
    results(m) = mfit_optimize(likfun,param,data);
    clear param
end
use_bic = 1;
bms_results = mfit_bms(results,use_bic);

save(strcat('model_fits11.mat'),'results','bms_results')

