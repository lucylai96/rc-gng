function data = sim_adaptive(param, data)

% Simulation of adaptive Pavlovian-instrumental Go/NoGo model.
%
% USAGE: data = sim_adaptive(param,stim,R)
%
% INPUTS:
%   param - vector encoding the model parameters:
%           param(1) = inverse temperature
%           param(2) = prior mean, instrumental controller
%           param(3) = prior confidence, instrumental controller
%           param(4) = prior mean, Pavlovian controller
%           param(5) = prior confidence, Pavlovian controller
%           param(6) = initial Pavlovian weight
%
% OUTPUTS:
%   data - structure containing simulation results, with the following fields:
%           .s - stimulus sequence
%           .a - action sequence
%           .r - reward sequence
%           .acc - accuracy (1 = optimal action chosen)
%           .w - Pavlovian weight sequence
%
% DEMOS:
%   stim = ones(100,1);
%   param = [5 0.5 2 0.5 2 0.5];
%   R = [0.5 0.5]; % uncontrollable environment
%   data = sim_adaptive(param);
%   plot(data.w);
%   R = [0.9 0.1]; % controllable environment
%   data = sim_adaptive(param);
%   hold on; plot(data.w,'-r');
%   xlabel('Trial'); ylabel('Pavlovian weight');
%
% adapted by Lucy Lai, Jun 2021, originally by Sam Gershman, Jan 2019


bt = param(1);   % inverse temperature
mq = param(2);   % prior mean, instrumental
pq = param(3);   % prior confidence, instrumental
mv = param(4);   % prior mean, Pavlovian
pv = param(5);   % prior confidence, Pavlovian

if length(param)>5
    w0 = param(6);  % initial Pavlovian weight
else
    w0 = 0.5;
end


C = unique(data(1).cond);
for c = 1:length(C) % for each condition
    ix = find(data.cond==C(c));
    stim = data.s(ix);
    corchoice = data.corchoice(ix);    % correct choice on each trial
    u = unique(stim);
    S = length(u);
    v = zeros(S,1) + mv;
    q = zeros(S,2) + mq;
    Mv = zeros(S,1) + pv;
    Mq = zeros(S,2) + pq;
    L = log(w0) - log(1-w0);
    R = data.condQ(c).Q;
    p = [0.3775  0.6225];
    
    for t = 1:length(stim)
        s = stim(t);  % stimulus
        w = 1./(1+exp(-L));
        d = (1-w)*q(s,1) - (1-w)*q(s,2) - w*v(s);
        P = 1/(1+exp(-bt*d)); % probability of NoGo
        policy = [P 1-P];
        if rand < P
            a = 1; % no-go
        else
            a = 2; 
        end
        
        cost = log(policy(a)) - log(p(a));               % policy complexity cost
        
        % sample reward
        r = rand<(R(s,a)); % reward
        
        if a == corchoice(t)
            acc = 1;                % accuracy
        else
            acc = 0;
        end
        
        % store data
        data.a(ix(t)) = a;
        data.r(ix(t)) = double(r);
        data.acc(ix(t)) = double(acc);
        data.w(ix(t)) = w;
        data.s(ix(t)) = s;
        data.cost(ix(t)) = cost;
        
        % update model posterior
        if r == 1
            L = L + log(v(s)) - log(q(s,a));
        else
            L = L + log(1-v(s)) - log(1-q(s,a));
        end
        
        % update reward predictions
        Mv(s) = Mv(s) + 1;
        Mq(s,a) = Mq(s,a) + 1;
        v(s) = v(s) + (r-v(s))/Mv(s);
        q(s,a) = q(s,a) + (r-q(s,a))/Mq(s,a);
        
    end
    
end