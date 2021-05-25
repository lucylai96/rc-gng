function [results,bms_results] = fit_models(data,models,results)

% Fit models to rc-gng data.

addpath('/Users/lucy/Google Drive/Harvard/Projects/mfit')

if nargin < 1
    load gng_data.mat;
end

% fit all models
if nargin < 2
    models = 1:2;
end

for m = models
    
    switch m
        case 1 % 4 free params: lrate_theta, lrate_V, lrate_p
            likfun = @actor_critic_lik; % NO COST MODEL
            param(1) = struct('name','lrate_theta','lb',0,'ub',1,'logpdf',@(x) 0);
            param(2) = struct('name','lrate_V','lb',0,'ub',1,'logpdf',@(x) 0);
            %param(3) = struct('name','lrate_p','lb',0,'ub',1,'logpdf',@(x) 0);
            %param(3) = struct('name','b','lb',0,'ub',1,'logpdf',@(x) 0); % b is initial bias to start at Go
            
        case 2 % 5 free params: C, lrate_theta, lrate_V, lrate_beta, b | fixed: lrate_p = 0, beta0 = 1 (beta is learned starting from beta0)
            likfun = @actor_critic_lik;
            param(1) = struct('name','C','lb',0.01,'ub',log(3),'logpdf',@(x) 0);
            param(2) = struct('name','lrate_theta','lb',0,'ub',1,'logpdf',@(x) 0);
            param(3) = struct('name','lrate_V','lb',0,'ub',1,'logpdf',@(x) 0);
            param(4) = struct('name','lrate_beta','lb',0,'ub',1,'logpdf',@(x) 0);
            %param(4) = struct('name','lrate_p','lb',0,'ub',1,'logpdf',@(x) 0);
            %param(6) = struct('name','b','lb',0,'ub',1,'logpdf',@(x) 0); % b is initial bias to start at Go
            % TODO: also try model where b is fixed to 0.3
            
    end
    
    results(m) = mfit_optimize(likfun,param,data);
    clear param
end

bms_results = mfit_bms(results);

save(strcat('model_fits.mat'),'results','bms_results')

