function data = generate_PIT(s,legStr)
% INPUT: s - number of subjects

beta = linspace(0.1,15,50);

% standard negative automaintence experiment
trials = 400; states = 2;
Q2 = [1 0; 0 0]; Ps = ones(1,states)/states; % no peck, peck
cond(1) = generate_cond(trials, states, Q2);
[R(1,:),V(1,:)] = blahut_arimoto(Ps,Q2,beta);

%Q4(:,:,1) = [0 1; 0 0; 1 0; 0 0]; % S = 4, Kon, Koff
%Q4(:,:,2) = [0.2 0.8; 0.8 0.2; 0.19 0.81; 0.81 0.19];  % S = 4, high similarity, HC, distance is 0
%Q4(:,:,3) = [0.2 0.8; 0.8 0.2; 0.4 0.6; 0.6 0.4];  % S = 4, low similarity, LC, distance is 0.2
%Q4(:,:,4) = [0.2 0.8; 0.8 0.2; 0 1; 1 0];          % S = 4, low similarity, HC, distance is 0.2

% trials = 400; states = 4; Ps = ones(1,states)/states;
% for i = 2:size(Q4,3)+1
%     cond(i) = generate_cond(trials, states, Q4(:,:,i-1));
%     [R(i,:),V(i,:)] = blahut_arimoto(Ps,Q4(:,:,i-1),beta);
% end


% theoretical curves
figure; hold on;
plot(R',V')
legend(legStr)
xlabel('Policy complexity')
ylabel('Average reward')


for i = 1:s
    data(i).s = [cond.state];
    data(i).corchoice = [cond.corchoice];
    data(i).cond = [ones(1,trials/2)];
    data(i).cond = [];
    for c = 1:length(cond)
        data(i).cond = [data(i).cond c*ones(1,trials)];
        data(i).condQ(c).Q = cond(c).Q;
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

for i = 1:trials
    [~,corchoice(i)] = max(Q(s(i),:)); % which action is correct
end
cond.state = s;
cond.corchoice = corchoice;
cond.Q = Q;

end


