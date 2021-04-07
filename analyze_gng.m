function analyze_gng(data)
% PURPOSE: reward-complexity curves for go/no-go experiment of diff
% controllability and set sizes?

% Written by: Lucy Lai

addpath('/Users/lucy/Google Drive/Harvard/Projects/rc-behav/code/GoNogo-control/')
if nargin < 1
    data = load_data('data2.csv');
    
end

beta = linspace(0.1,15,50);

% run Blahut-Arimoto
for s = 1:length(data)
    C = unique(data(s).cond);        % condition
    R_data =zeros(length(C),1);
    V_data =zeros(length(C),1);
    for c = 1:length(C)
        ix = data(s).cond==C(c);
        state = data(s).s(ix);
        action = data(s).a(ix);
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
        
          [R(b,:),V(b,:)] = blahut_arimoto(Ps,Q,beta);
            
            setsize(b) = length(S)-1;
            
        end
        
        for c = 1:max(setsize)
            results.R(s,:,c) = nanmean(R(setsize==c,:));
            results.V(s,:,c) = nanmean(V(setsize==c,:));
            results.R_data(s,c) = nanmean(R_data(setsize==c));
            results.V_data(s,c) = nanmean(V_data(setsize==c));
        end
        
        clear R V
        
    end
    
    % compute bias
    R = squeeze(nanmean(results.R));
    V = squeeze(nanmean(results.V));
    for c = 1:max(setsize)
        Vd2(:,c) =  interp1(R(:,c),V(:,c),results.R_data(:,c));
        results.bias(:,c) = Vd2(:,c) - results.V_data(:,c);
        results.V_interp(:,c) = Vd2(:,c);
    end
    
    end
end

end