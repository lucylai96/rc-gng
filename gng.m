function gng
% PURPOSE: reward-complexity curves for go/no-go experiment of diff
% controllability and set sizes? 

% Written by: Lucy Lai

addpath('/Users/lucy/Google Drive/Harvard/Projects/rc-behav/code/GoNogo-control/')

data = load_data('data2.csv');

beta = linspace(0.1,15,50);

% run Blahut-Arimoto
for s = 1:length(data)
    C = unique(data(s).cond);        % condition
    R_data =zeros(length(C),1);
    V_data =zeros(length(C),1);
    for c = 1:length(C)
        ix = data(s).cond==C(c);
        state = data(s).state(ix);
        action = data(s).action(ix);
        reward = data(s).acc(ix);
        R_data(c) = mutual_information(state,action,0.1);
        V_data(c) = mean(data(s).reward(ix));
        
        S = unique(state);
        Q = zeros(length(S),3);
        Ps = zeros(1,length(S));
        for i = 1:length(S)
            ii = state==S(i);
            Ps(i) = mean(ii);
            a = c(ii); a = a(1);
            Q(i,a) = 1;
        end
        
    end
end


end