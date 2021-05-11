function data = analyze_rawdata
% analyze raw data and store into structure
clear all
% subj = {'A191V7PT3DQKDP','A3V2XCDF45VN9X','A2V27A9GZA1NR2','A3FT3XPTOWHJMY'}; % pilot 1
% batch of 40/40
subj = {'A19TD2J8506A4Y','A19WXS1CLVLEEX','A1B5SSGMTAQ9B5','A1BFA82J9Q1CLA',...
    'A1NDMFN9A5G25G','A1SOFLJOEQB591','A1T3ROSW2LC4FG','A2196WCNDZULFS','A24Z9RP5YZZ2TY',...
    'A2615YW1YERQBO','A2IQ0QCTQ3KWLT','A2V27A9GZA1NR2','A30HUZHJBOX1LK','A348NEQKS6VNIB',...
    'A34SIGOLUGKIHJ','A37S96RT1P1IT2','A3CTXNQ2GXIQSP','A3FNC8ELMK8YJA','A3G5IPGLH1IIZN',...
    'A3GLUDQZGEJL5G','A3K9GTQBOI7O5A','A98E8M4QLI9RS','AFU00NU09CFXE',...
    'AJQ71YIGY01HZ','AMELYCC59JKB0','AOS2PVHT2HYTL','AVCOBHDVXZOZL','AZNIEFUIVB2H0',...
    'A3RKG5PZN97RD5','A12XVSIL669PVI.csv','A1GKD3NG1NNHRP.csv','A1HRH92NH49RX2.csv',...
    'A273DS7TQWR9M1.csv','A2VNSNAN1LZBAM.csv','A9HQ3E0F2AGVO.csv','AA4O2W236E3FW.csv',...
    'A1SISJL5ST2PWH.csv','A2871R3LEPWMMK.csv','A2ZDEERVRN5AMC.csv','A4ZPIPBDO624H.csv'};

%subj = {'A10JXOU89D5RXR.csv','A1I72NHC21347A.csv','A1Q56N80RJLQ7S.csv','A2APG8MSLJ6G2K.csv','A2PIFMM4Q2I9ZS.csv','A2VNWJU49OOVFC.csv','A33LYSCQQU1YDJ.csv','A3RHJEMZ4EGY2U.csv','A3V2XCDF45VN9X.csv','ACKG8OU1KHKO2.csv','AOS2PVHT2HYTL.csv','AQXEQDTAU4MJ4.csv'};

cutoff = 0.65;% cutoff percentage [0 1]

for s = 1:length(subj)
    % 1:rt   2:url   3:trial_type   4:trial_index   5:time_elapsed
    % 6:internal_node_id   7: view_history
    % 8:stimulus   9:key_press   10:test_part   11:correct_response   12:correct
    % 13:use_rew   14:which_stim   15:reward   16:responses
    
    A = readtable(strcat('experiment/data/',subj{s}));
    A = table2cell(A);
    
    corr = sum(strcmp(A(40:end,12), 'true'));
    incorr = sum(strcmp(A(40:end,12), 'false'));
    pcorr(s) = corr/(corr+incorr);
end
histogram(pcorr,20)
xlabel('% Accuracy'); ylabel('# of Subjects');
subj = subj(find(pcorr>cutoff)); % filter by percent correct >cutoff%

data.legStr = {'Control, S = 2','HiSim, LC, S = 4','HiSim, HC, S = 4', 'LowSim, LC, S = 4','LowSim, HC, S = 4'};

for s = 1:length(subj)
    % 1:rt   2:url   3:trial_type   4:trial_index   5:time_elapsed
    % 6:internal_node_id   7: view_history
    % 8:stimulus   9:key_press   10:test_part   11:correct_response   12:correct
    % 13:use_rew   14:which_stim   15:reward   16:responses
    
    A = readtable(strcat('experiment/data/',subj{s}));
    A = table2cell(A);
   
    %% save into data structure
    
    % 10 practice trials
    % 60 trials control cond1  [0.8,0.2; 0.2,0.8]
    % 120 trials cond2 [0.6, 0.4],[0.4, 0.6],[0.6, 0.4],[0.4, 0.6] // high similarity, low control
    % 120 trials cond3 [0.8, 0.2],[0.2, 0.8],[0.8, 0.2],[0.2, 0.8] // high similarity, high control
    % 120 trials cond4 [0.8, 0.2],[0.2, 0.8],[0.6, 0.4],[0.4, 0.6] // low similarity, low control
    % 120 trials cond5 [0.8, 0.2],[0.2, 0.8],[1, 0], [0, 1]        // low similarity, high control
    
    trials_per_block = [60,120,120,120,120];
    
    % correct ==> 0 or 1
    A(:,12) = strrep(A(:,12),'true','1');
    A(:,12) = strrep(A(:,12),'false','0');
    trial_idx = find(~isnan(str2double(A(:,12))) & strcmp(A(:,10),'trial'));
    
    block_bounds = find(strcmp(A(:,3),'instructions')==1); % index for when block changes
    n_trials = sum(~isnan(cell2mat(A(:,15))));
    data(s).t = [1:n_trials]'; % trial #
    %states = {'go_a', 'nogo_b', 'go_c', 'nogo_d'};
    %for i = 1:length(states)
    %    A(:,14) = strrep(A(:,14),states{i},num2str(i));
    %end
    [~,~,bin] = unique(A(:,14),'sorted');
    data(s).s =  bin(bin>1 & ~isnan(cell2mat(A(:,15))))-1; % states
    data(s).a = double(str2double(A(trial_idx,9))==32) + 1; % 1 = no-go, 2 = go
    data(s).acc = str2double(A(trial_idx,12)); % accuracy: correct or not
    data(s).r = cell2mat(A(trial_idx+1,15));   % reward
    data(s).rt = str2double(A(trial_idx,1));   % reaction time
    
    data(s).block = [];
    for n = 1:length(trials_per_block)
        data(s).block = [data(s).block n*ones(1,trials_per_block(n))];
    end
    
    % reward functions
    data(s).condQ(1).Q = [0.8,0.2; 0.2,0.8];
    data(s).condQ(2).Q =[0.6, 0.4; 0.4, 0.6; 0.6, 0.4; 0.4, 0.6];
    data(s).condQ(3).Q =[0.8, 0.2; 0.2, 0.8; 0.8, 0.2; 0.2, 0.8];
    data(s).condQ(4).Q =[0.8, 0.2; 0.2, 0.8; 0.6, 0.4; 0.4, 0.6];
    data(s).condQ(5).Q =[0.8, 0.2; 0.2, 0.8; 1, 0; 0, 1];
    
    data(s).cond = zeros(1,n_trials)';
    rew_fun = cell2mat(cellfun(@str2num,A(trial_idx,13),'uniform',0)); % reward functions
    for b = 1:max(unique(data(s).block))  % for each block, assign the objective condition
        ix = data(s).block==b;
        [~,sidx] = unique(data(s).s(ix));
        R = rew_fun(ix,:);
        for c = 1:length(data(s).condQ)
            if isequal(R(sidx,:), data(s).condQ(c).Q) % see which condition this block is
                data(s).cond(ix) = c;
            end
        end
    end
    
end

% save in a MAT file
save('gng_data.mat','data')
end
