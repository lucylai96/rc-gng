function results = analyze_gng(data)
% PURPOSE: reward-complexity curves for go/no-go experiment of diff
% controllability and set sizes?

% Written by: Lucy Lai


addpath('/Users/lucy/Google Drive/Harvard/Projects/rc-behav/code/GoNogo-control/')
if nargin < 1
    data = load_data('data2.csv');
    
end

beta = linspace(0.1,15,50);
C = unique(data(1).cond);        % num condition
R_data = zeros(length(data),1);
V_data = zeros(length(data),1);
for s = 1:length(data)
    for c = 1:length(C)
        Q = data(s).condQ(c).Q;
        ix = data(s).cond==C(c); 
        state = data(s).state(ix);
        action = data(s).action(ix);
        Ps = ones(1,length(unique(state)))/length(unique(state));
        
        R_data(s,c) = mutual_information(state,action,0.1);
        V_data(s,c) = mean(data(s).reward(ix));
        
        [R(c,:),V(c,:)] = blahut_arimoto(Ps,Q,beta);
        
        results.R(s,:,c) = R(c,:); % S subjects x 50 betas x C conditions
        results.V(s,:,c) = V(c,:);
    end
    
    clear R V
end

% store data
results.R_data = R_data;
results.V_data = V_data;



% compute bias
% R = squeeze(nanmean(results.R));
% V = squeeze(nanmean(results.V));
% for c = 1:max(setsize)
%     Vd2(:,c) =  interp1(R(:,c),V(:,c),results.R_data(:,c));
%     results.bias(:,c) = Vd2(:,c) - results.V_data(:,c);
%     results.V_interp(:,c) = Vd2(:,c);
% end



end