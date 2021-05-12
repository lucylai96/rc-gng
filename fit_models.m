function [results,bms_results] = fit_models(data,models,results)
    
    % Fit models to rc-gng data.
    
    if nargin < 1
        data = load_data;
    end
    
    if nargin < 2
        models = 1:4;
    end
    
    for m = models
        
        switch m
            
            case 1 % 5 free params: C, lrate_theta, lrate_V, beta0, lrate_beta | fixed: lrate_p
                likfun = @actor_critic_lik;
                param(1) = struct('name','C','lb',0.01,'ub',log(3),'logpdf',@(x) 0);
                param(2) = struct('name','lrate_theta','lb',0,'ub',1,'logpdf',@(x) 0);
                param(3) = struct('name','lrate_V','lb',0,'ub',1,'logpdf',@(x) 0);
                param(4) = struct('name','beta0','lb',0,'ub',50,'logpdf',@(x) 0);
                param(5) = struct('name','lrate_beta','lb',0,'ub',1,'logpdf',@(x) 0);
                
            case 2 % 6 free params: C, lrate_theta, lrate_V, beta0, lrate_beta, lrate_p
                likfun = @actor_critic_lik;
                param(1) = struct('name','C','lb',0.01,'ub',log(3),'logpdf',@(x) 0);
                param(2) = struct('name','lrate_theta','lb',0,'ub',1,'logpdf',@(x) 0);
                param(3) = struct('name','lrate_V','lb',0,'ub',1,'logpdf',@(x) 0);
                param(4) = struct('name','beta0','lb',0,'ub',50,'logpdf',@(x) 0);
                param(5) = struct('name','lrate_beta','lb',0,'ub',1,'logpdf',@(x) 0);
                param(6) = struct('name','lrate_p','lb',0,'ub',1,'logpdf',@(x) 0);
                
            case 3 % 6 free params: beta, lrate_theta, lrate_V, lrate_p, 
                likfun = @actor_critic_lik;
                param(1) = struct('name','beta','lb',0,'ub',50,'logpdf',@(x) 0);
                param(2) = struct('name','lrate_theta','lb',0,'ub',1,'logpdf',@(x) 0);
                param(3) = struct('name','lrate_V','lb',0,'ub',1,'logpdf',@(x) 0);
                param(4) = struct('name','lrate_p','lb',0,'ub',1,'logpdf',@(x) 0);
                
            case 4 % beta, lrate_theta, lrate_V, lrate_p, 
                likfun = @actor_critic0_lik; % different function?? without cost i think
                param(1) = struct('name','beta','lb',0,'ub',50,'logpdf',@(x) 0);
                param(2) = struct('name','lrate_theta','lb',0,'ub',1,'logpdf',@(x) 0);
                param(3) = struct('name','lrate_p','lb',0,'ub',1,'logpdf',@(x) 0);
                param(4) = struct('name','lrate_V','lb',0,'ub',1,'logpdf',@(x) 0);
        end
        
        results(m) = mfit_optimize(likfun,param,data);
        clear param
    end
    
    if nargout > 1
        bms_results = mfit_bms(results);
    end