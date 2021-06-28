function data = generate_negauto(n,expt)
% INPUT: s - number of subjects

beta = linspace(0.1,15,50);

% which experimental task to simulate
switch expt
    case 1 % Key K only
        trials = 600; states = 2; actions = 2;
        Q = [1 0; 0 0];
        Ps = ones(1,states)/states; % a = 1 is no peck, a = 2 is peck (K)
        s = repmat(randperm(states),1, trials/states);
        
        for i = 1:trials
            [~,corchoice(i)] = max(Q(s(i),:)); % which action is correct
        end
        cond.state = s;
        cond.corchoice = corchoice;
        cond.Q = Q;
        [R,V] = blahut_arimoto(Ps,Q,beta);
        
    case 3 % Key K, Key I (irrelevant)
        
        trials = 600; states = 2; actions = 3;
        Q = [1 0 1; 0 0 0]; % a = 1 is no peck, a = 2 is peck (K), a = 3 is peck (I)
        Ps = ones(1,states)/states; % no peck, peck K, peck I
        s = repmat(randperm(states), 1, trials/states);
        cond.Q = zeros(states, actions, trials);
        for i = 1:200
            [~,corchoice(i)] = max(Q(s(i),:)); % which action is correct
            cond.Q(:,:,i) = Q;
        end
        
        Q = [0 0 0; 1 0 1]; % reversal
        for i = 201:400
            [~,corchoice(i)] = max(Q(s(i),:)); % which action is correct
             cond.Q(:,:,i) = Q;
        end
         
        Q = [1 0 1; 0 0 0]; % reversal back
        for i = 401:600
            [~,corchoice(i)] = max(Q(s(i),:)); % which action is correct
             cond.Q(:,:,i) = Q;
        end
        cond.state = s;
        cond.corchoice = corchoice;
        [R,V] = blahut_arimoto(Ps,Q,beta);
        
    case 4
        Q = [1 1 0;0 0 0; 0 0 0]; % S = 5, A = 3
end

% theoretical curves
% figure; hold on;
% plot(R',V')
% legend(legStr)
% xlabel('Policy complexity')
% ylabel('Average reward')

% copying for multiple simulated agents
for i = 1:n
    data(i).s = [cond.state];
    data(i).corchoice = [cond.corchoice];
    data(i).cond = [];
    for c = 1:length(cond)
        data(i).cond = [data(i).cond c*ones(1,trials)];
        data(i).condQ(c).Q = cond(c).Q;
    end
end

end
