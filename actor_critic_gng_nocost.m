function simdata = actor_critic_gng_nocost(agent,data)
% Simulate actor-critic agent for go/no-go task but with no complexity cost
% USAGE: simdata = actor_critic_gng_nocost(agent,data)

if ~isfield(agent,'beta')
    agent.beta = agent.beta0;
end

simdata = data;
C = unique(data(1).cond);
for c = 1:length(C)
    ix = find(data.cond==C(c));
    state = data.state(ix);
    corchoice = data.corchoice(ix);    % correct choice on each trial
    R = data.condQ(c).Q;
    setsize = length(unique(state));   % number of distinct stimuli
    nA = length(unique(corchoice));    % number of distinct actions
    theta = zeros(2,1);                % policy parameters
    V = zeros(setsize,1);              % state values
    Q = zeros(setsize,nA);             % state-action values
    beta = agent.beta;
    
    if isfield(agent,'p')
        p = agent.p;
    else
        p = ones(1,nA)/nA;          % marginal action probabilities
    end
    
    for t = 1:length(state)
        s = state(t);
        
        phi = [Q(s,:); 0 V(s)];
        d = beta*(theta'*phi) + log(p);
        
        logpolicy = d - logsumexp(d);
        policy = exp(logpolicy);    % softmax policy
        a = fastrandsample(policy); % action
        if a == corchoice(t)
            acc = 1;                % accuracy
        else
            acc = 0;
        end
        r = fastrandsample(R(s,a)); % reward
        
        rpe = r - V(s);                                % reward prediction error
        g = phi(:,a)*rpe*(1 - policy(a))*beta;         % policy gradient
        V(s) = V(s) + agent.lrate_V*(r-V(s));          % state value update
        Q(s,a) = Q(s,a) + agent.lrate_V*(r-Q(s,a));    % state-action value update
     
        if agent.lrate_p > 0
            p = p + agent.lrate_p*(policy - p); p = p./sum(p);  % marginal update
        end
        
        theta = theta + agent.lrate_theta*g;        % policy parameter update
        
        simdata.s(ix(t)) = s;
        simdata.action(ix(t)) = a;
        simdata.reward(ix(t)) = r;
        simdata.acc(ix(t)) = acc;
        simdata.expreward(ix(t)) = policy(corchoice(t));
        simdata.beta(ix(t)) = beta;
        simdata.theta(ix(t),:) = theta;
        
    end
    simdata.p(c,:) = p;

end