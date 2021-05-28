function results = analyze_gng(data)
% PURPOSE: reward-complexity curves for go/no-go experiment of diff
% controllability and set sizes?

% Written by: Lucy Lai

if nargin < 1
    load gng_data; %data = analyze_rawdata; % load gng_data.mat
end

beta = linspace(0.1,15,50);
C = unique(data(1).cond);        % num condition
R_data = zeros(length(data),1);
V_data = zeros(length(data),1);
for s = 1:length(data)
    for c = 1:length(C)
        Q = data(s).condQ(c).Q;
        ix = data(s).cond==C(c);
        state = data(s).s(ix);
        action = data(s).a(ix);
        Ps = ones(1,length(unique(state)))/length(unique(state));
        
        R_data(s,c) = mutual_information(state,action,0.01);
        V_data(s,c) = mean(data(s).r(ix));
        
        if C(c) == 3
            Q(3,:) = [0.81, 0.19];
            Q(4,:) = [0.19, 0.81];
        end
        [R(c,:),V(c,:)] = blahut_arimoto(Ps,Q,beta);
        
        
        results.R(s,:,c) = R(c,:); % S subjects x 50 betas x C conditions
        results.V(s,:,c) = V(c,:);
        
        gb(s,c) = mean(data(s).acc(data(s).s==1 & data(s).cond==c)) - mean(data(s).acc(data(s).s==2 & data(s).cond==c)); % go - nogo
        go = data(s).acc(data(s).s==1 & data(s).cond==c);
        nogo = data(s).acc(data(s).s==2 & data(s).cond==c);
        gobias(s,1:length(go),c) = movmean(go-nogo,10);
        
    end
    
    clear R V
end

% store data
results.R_data = R_data;
results.V_data = V_data;


% compute bias
R = squeeze(nanmean(results.R));
V = squeeze(nanmean(results.V));
for c = 1:length(C)
    Vd2(:,c) =  interp1(R(:,c),V(:,c),results.R_data(:,c));
    results.bias(:,c) = Vd2(:,c) - results.V_data(:,c);
    results.V_interp(:,c) = Vd2(:,c);
end
results.bias(isnan(results.bias)) = 0;

results.gobias =  gobias; % dynamic go bias
results.gb =  gb; % static go bias

% save data
% save('gng_results.mat','results');

end