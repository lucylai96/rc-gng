function simdata = actor_critic_gng(agent,data)

% Simulate actor-critic agent for go/no-go task
%
% USAGE: simdata = actor_critic_gng(agent,data)

if ~isfield(agent,'beta')
    agent.beta = agent.beta0;
end

simdata = data;
%B = unique(data.learningblock);
C = unique(data(1).cond);
for c = 1:length(C)
    ix = find(data.cond==C(c));
    state = data.state(ix);
    corchoice = data.corchoice(ix);    % correct choice on each trial
    Q = data.condQ(c).Q;
    setsize = length(unique(state));   % number of distinct stimuli
    nA = length(unique(corchoice));    % number of distinct actions
    theta = zeros(setsize,nA);         % policy parameters
    V = zeros(setsize,1);              % state values
    beta = agent.beta;
    ecost = 0;
    
    if isfield(agent,'p')
        p = agent.p;
    else
        p = ones(1,nA)/nA;                 % marginal action probabilities
    end
    for t = 1:length(state)
        s = state(t);
        d = beta*theta(s,:) + log(p);
        logpolicy = d - logsumexp(d);
        policy = exp(logpolicy);    % softmax policy
        a = fastrandsample(policy); % action
        if a == corchoice(t)
            acc = 1;                % accuracy
        else
            acc = 0;
        end
        r = fastrandsample(Q(s,a)); % reward
        
        cost = logpolicy(a) - log(p(a));    % policy complexity cost
        rpe = beta*r - cost - V(s);         % reward prediction error
        g = rpe*beta*(1 - policy(a));       % policy gradient
        V(s) = V(s) + agent.lrate_V*rpe;    % state value update
        ecost = ecost + agent.lrate_V*(cost-ecost);    % state value update
        
        if agent.lrate_beta > 0
            beta = beta + agent.lrate_beta*(agent.C-ecost);%*(theta(s,a)-(theta(s,:)*policy'));
            %beta = beta + agent.lrate_beta*(agent.C-ecost)*(theta(s,a)-(theta(s,:)*policy'));
            dbeta = agent.lrate_beta*(agent.C-cost)*(theta(s,a)-(theta(s,:)*policy'));
            beta = max(min(beta,50),0);
        end
        if agent.lrate_p > 0
            p = p + agent.lrate_p*(policy - p); p = p./sum(p);  % marginal update
        end
        
        theta(s,a) = theta(s,a) + agent.lrate_theta*g/t;        % policy parameter update
        simdata.s(ix(t)) = s;
        simdata.action(ix(t)) = a;
        simdata.reward(ix(t)) = r;
        simdata.acc(ix(t)) = acc;
        simdata.expreward(ix(t)) = policy(corchoice(t));
        simdata.beta(ix(t)) = beta;
        
    end
    simdata.p(c,:) = p;
    %ecost
    %beta
end