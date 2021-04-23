function data = generate_dorfman(s)
% INPUT: s - number of subjects

beta = linspace(0.1,15,50);

% LC
trials = 120; states = 3;
Q = [0.25 0.75; 0.75 0.25; 0.5 0.5]; Ps = ones(1,states)/states;
cond(1) = generate_cond(trials, states, Q);
[R(1,:),V(1,:)] = blahut_arimoto(Ps,Q,beta);

Q = [0.25 0.75; 0.75 0.25; 0.2 0.8];
cond(2) = generate_cond(trials, states, Q);
[R(2,:),V(2,:)] = blahut_arimoto(Ps,Q,beta);

% theoretical curves
% figure; hold on;
% plot(R',V')
% legend('Low control','High control')
% xlabel('Policy complexity')
% ylabel('Average reward')


for i = 1:s
    data(i).state = [cond.state];
    data(i).corchoice = [cond.corchoice];
    data(i).cond = [ones(1,trials) 2*ones(1,trials)];
    %data(s).Q = cond.Q;
    for x = 1:length(cond)
        data(i).condQ(x).Q = cond(x).Q;
    end
    
end

end

function cond = generate_cond(trials, states, Q)
% INPUT: number of trials, states, and Q function (trials must be divisible
% by states)
% OUTPUT: data.s - a vector of randomized states
%         data.corchoice - vector of correct choices
%         data.Q - reward function

s = repmat(randperm(states),1, trials/states);
s = s(randperm(length(s)));

for i = 1:trials
    [~,corchoice(i)] = max(Q(s(i),:)); % which action is correct
end
cond.state = s;
cond.corchoice = corchoice;
cond.Q = Q;

end


