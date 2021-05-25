function [lik,latents] = actor_critic_lik(x,data)

% Likelihood function for actor-critic agent (gng task)
%
% USAGE: [lik,latents] = actor_critic_lik(x,data)

if length(x)==2   % no cost model
    agent.m = 1;
    agent.C = [];
    agent.lrate_theta = x(1);
    agent.lrate_V = x(2);
    agent.beta0 = 1;
    agent.lrate_beta = 0;
    agent.lrate_p = 0;
    agent.lrate_e = 0.1;
    agent.b = 1;
    
elseif length(x)==3 % 'best' model
    agent.m = 2;
    agent.C = 1;
    agent.lrate_theta = x(1);
    agent.lrate_V = x(2);
    agent.beta0 = 1;
    agent.lrate_beta = x(3);
    agent.lrate_p = 0;
    agent.lrate_e = 0.1;
    agent.b = 1;
end

C = unique(data(1).cond);
lik = 0;

for c = 1:length(C)
    ix = find(data.cond==C(c));
    reward = data.r(ix);
    action = data.a(ix);
    state = data.s(ix);
    acc = data.acc(ix);                 % correct choice on each trial
    R = data.condQ(c).Q;                % reward function for that block
    setsize = length(unique(state));    % number of distinct states
    nA = length(unique(action));           % number of distinct actions
    theta = zeros(2,1);                 % policy parameters (Pavlovian vs. Instrumental)
    V = zeros(setsize,1);               % state values
    Q = zeros(setsize,nA);              % state-action values
    p = ones(1,nA)/nA;                  % marginal action probabilities
    beta = agent.beta0;
    ecost = 0;
    
    if nargout > 1                      % if you want to collect the latents
        ii = find(ix);
    end
    
    for t = 1:length(state)
        s = state(t); a = action(t); r = reward(t);
        phi = [Q(s,:); 0 V(s)];
        %d = beta*(theta'*phi) + log(p);
        d = (theta'*phi)+ [0 agent.b];
        
        logpolicy = d - logsumexp(d);
        policy = exp(logpolicy);               % softmax policy
        lik = lik + logpolicy(a);
        cost = logpolicy(a) - log(p(a));       % policy complexity cost
        
        if agent.m > 1                         % if it's a cost model
            rpe = beta*r - cost - V(s);        % reward prediction error
        else
            rpe = r - V(s);                    % reward prediction error w/o cost
        end
        
        g = rpe*phi(:,a)*(1 - policy(a));              % policy gradient
        V(s) = V(s) + agent.lrate_V*(r-V(s));          % state value update
        Q(s,a) = Q(s,a) + agent.lrate_V*(r-Q(s,a));    % state-action value update
        ecost = ecost + agent.lrate_e*(cost-ecost);    % policy cost update
        
        if agent.lrate_beta > 0
            beta = beta + agent.lrate_beta*(agent.C-cost);
            % beta = beta + agent.lrate_beta*(agent.C-cost)*(theta(s,a)-(theta(s,:)*policy'));
            beta = max(min(beta,50),0);
        end
        
        if agent.lrate_p > 0
            p = p + agent.lrate_p*(policy - p); p = p./sum(p);  % marginal update
        end
        
        theta = theta + agent.lrate_theta*g;                  % policy parameter update
        
        if nargout > 1                                          % if you want to collect the latents
            latents.rpe(ii(t)) = rpe;
        end
        
    end % trials in block end
end % block end