function [data, cutoff] = analyze_rawdata
% analyze raw data and store into structure

clear all
%close all
% subj = {'A191V7PT3DQKDP','A3V2XCDF45VN9X','A2V27A9GZA1NR2','A3FT3XPTOWHJMY'}; % pilot 1

% batch of 40/40 | '292905'
subj1 = {'A19TD2J8506A4Y','A19WXS1CLVLEEX','A1B5SSGMTAQ9B5','A1BFA82J9Q1CLA',...
    'A1NDMFN9A5G25G','A1SOFLJOEQB591','A1T3ROSW2LC4FG','A2196WCNDZULFS','A24Z9RP5YZZ2TY',...
    'A2615YW1YERQBO','A2IQ0QCTQ3KWLT','A2V27A9GZA1NR2','A30HUZHJBOX1LK','A348NEQKS6VNIB',...
    'A34SIGOLUGKIHJ','A37S96RT1P1IT2','A3CTXNQ2GXIQSP','A3FNC8ELMK8YJA','A3G5IPGLH1IIZN',...
    'A3GLUDQZGEJL5G','A3K9GTQBOI7O5A','A98E8M4QLI9RS','AFU00NU09CFXE',...
    'AJQ71YIGY01HZ','AMELYCC59JKB0','AOS2PVHT2HYTL','AVCOBHDVXZOZL','AZNIEFUIVB2H0',...
    'A3RKG5PZN97RD5','A12XVSIL669PVI','A1GKD3NG1NNHRP','A1HRH92NH49RX2',...
    'A273DS7TQWR9M1','A2VNSNAN1LZBAM','A9HQ3E0F2AGVO','AA4O2W236E3FW',...
    'A1SISJL5ST2PWH','A2871R3LEPWMMK','A2ZDEERVRN5AMC','A4ZPIPBDO624H'};

% batch of 38/40 | '293787'
subj2 = {'A2VNWJU49OOVFC','AOS2PVHT2HYTL','ACKG8OU1KHKO2','A3RHJEMZ4EGY2U',...
    'A1Q56N80RJLQ7S','A2PIFMM4Q2I9ZS','AQXEQDTAU4MJ4','A10JXOU89D5RXR',...
    'A1I72NHC21347A','A3V2XCDF45VN9X','A2APG8MSLJ6G2K','A33LYSCQQU1YDJ',...
    'AOOLS8280CL0Z','A30RAYNDOWQ61S','A2R75YFKVALBXE','A2XQ3CFB5HT2ZQ',...
    'ACAJFF4MF5S5X','A2SKXKH9YXZYRI','AC8ETQXPDRR6P','ANK8K5WTHJ61C',...
    'A1FVXS8IM5QYO8','ADVJB810K4OYR','A12FTSX85NQ8N9','AUAN582MLI96N',...
    'AFK9ALQK5GPNG','A3KH1OG87C8DCM','A98E8M4QLI9RS','A324VBRLXHG5IB',...
    'A2CEHL1T8C927W','A2FYFCD16Z3PCC','AW0MG225VXWCN','AOIR8V07FYMH5',...
    'APGX2WZ59OWDN','A2Y87M8V0N1M6P','A3FNC8ELMK8YJA','A198MSVO1VTAT5',...
    'A3KF6O09H04SP7','A3JI3B5GTVA95F','AUFUUD4WG9CVO','A1I72NHC21347A'};

% batch of 48/48 (OG 50--missing 2 subjects data) | '294904'
subj3 = {'A2JDYN6QM8M5UN','ABW8U1U74P8MI','ALEE1QD4TW9G4','A1JJYY622DGE5L',...
    'A32JEH06T23HDF','A37OUZOGQKGMW0','A12FTSX85NQ8N9','A3KF6O09H04SP7',...
    'A3S3WYVCVWW8IZ','A2YHF0DPCO832L','AOOLS8280CL0Z','A2ONILC0LZKG6Y',...
    'AUQ79MANVDU9B','A2APG8MSLJ6G2K','A2LAMCJLVCRQ4T','A2WPKP73S4MBLK',...
    'AJRY9ALX8069Y','A1W7I6FN183I8F','A3FGT6EU39C6S4','A2FGKKWP33DFWS',...
    'A2F1AA15HG0FRU','A198MSVO1VTAT5','A6HDSE80LQPR8','A3V2XCDF45VN9X',...
    'A2BNOEYZ3VRW2R','A9MJVJAMLCDMV','A2NAKIXS3DVGAA','A2R9OK4M877ZCC',...
    'A3180VXVP8MOIH','A110KENBXU7SUJ','A1ZT30BGR3266K','AJXIC6Q5EM76P',...
    'A3JC9VPPTHNKVL','A2YTO4EY3MNYAJ','A1Z3NTRGIUZ240','A11S8IAAVDXCUS',...
    'AN9MVFWRCF2OP','A2FL477TMKC91L','A1FVXS8IM5QYO8','A1PJLZSOUQ4MIL',...
    'A324VBRLXHG5IB','A37JC45Y9GLSA7','A10249252O9I20MRSOBVF','A11TPUPFP2S4MK',...
    'A1NKBIJQGT0712','A2P065E9CYMYJL','AMTTB8JUWRRM7','AW0K78T4I2T72'};

% batch of 19/20 | '296714'
subj4 = {'A23KAJRDVCVGOE','A1ROEDVMTO9Y3X','A1P2RQ166VS5BT','A1P0XSCJ9XAV74',...
    'APGX2WZ59OWDN','A1UZXOMO6BS6I2','A1YH2I4Y2SYAXJ','A1IFIK8J49WBER',...
    'AOAZMLP27GD81','A3QSFE6GKO157S','ARYL3C6N9SVV1','A3QRZPJT2CT2IK',...
    'A16Z9FSSF1X74O','A2BK45LZGGWPLX','A1945USNZHTROX','A13WTEQ06V3B6D',...
    'APDDA1Y59RHV9','A38I0E8UK53ME5','A37QSTGGV90MFH'}; %'A3862RIFFUV141'

% batch of 20/20 | '296742'
subj5 = {'A3I11HUO6VH8KY','A1NZFJHVJ9CNTO','A1ROEDVMTO9Y3X','A248QG4DPULP46'...
    'AD75IYA9OIIQF','A11CY37O9P73HW','A2C84POENS2UNY','A16G6PPH1INQL8'...
    'A12FCLCVIM2CL3','AFK9ALQK5GPNG','A2MX0EF342FY3P','A1V1JNPU0KOA3X'...
    'AR8O1107OAW4V','A272X64FOZFYLB','A8C3WNWRBWUXO','A3T1KRG2ENHASZ'...
    'AKSJ3C5O3V9RB','AVFMTS8A5R4XK','A2NT3OQZUUZPEO','A3LVLZS8S41ZD7'};

% batch of 39/40 | '299873'
subj6 = {'A2YC6PEMIRSOAA','A2CUAZD7OJDFYR','A3CH1Z6J9R38G9','A3BU8UL4W258UU',...
    'ANFWGSQ8BQRZ','A7ERZELTAMWL5','AEWPAZBYA7XE','AK1Q45RF8A87Z',...
    'A1C5SQZ045W0L5','A2BK9RMC0NOIH8','A2Z6NL0CTXY0ZB','A2MWAXV1YRK5GH',...
    'A1CMWA0L8FTSXA','A1USR9JCAMDGM3','A2NXMRPHG86N2T','A26K8OELA8ZDI9',...
    'A2PXJTMWGUE5DC','A2R75YFKVALBXE','A26V9C29612LZT','A397HP5TSIF2LO',...
    'AURYD2FH3FUOQ','A1G187YBG0DVMQ','A1K1E4KCVW1HOZ','A25R2OI9L2Q1OW',...
    'A320QA9HJFUOZO', 'A1F9KLZGHE9DTA','A2S64AUN7JI7ZS','A2NA6X1SON3KFH',...
    'A3B7TNVOISSZ2O','AVXEDARJC5HLU','A114JRUBJ5IN7D','A3QLGMZOLGMBQ1',...
    'A1KS9LITOVPAT8','A33X52IN60MSOE','A2EGOCAO0VL2S8','A2WQT33K6LD9Z5',...
    'A1PBFDQR599N3K','AW5O1RK3W60FC','ACAJFF4MF5S5X','A3BUWQ5C39GRQC'};

% all subjects
subj = [subj1 subj3 subj4 subj5 subj6];

cutoff = 0.51; % percentage accuracy cutoff

flag = zeros(1,length(subj));
pressflag = zeros(1,length(subj)); blockflag = zeros(1,length(subj)); cutflag = zeros(1,length(subj));
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
    
    A(:,12) = strrep(A(:,12),'true','1');
    A(:,12) = strrep(A(:,12),'false','0');
    trial_idx = find(~isnan(str2double(A(:,12))) & strcmp(A(:,10),'trial'));
    actions = double(str2double(A(trial_idx,9))==32) + 1; %plot(actions,'o')
    correct = double(strcmp(A(trial_idx,12),'1')); %plot(correct,'o')
    if (sum(actions==2) / length(actions))>0.8 || (sum(actions==1) / length(actions))>0.8
        flag(s) = 1; pressflag(s) = 1;
        pa(s,:) = [sum(actions==2) / length(actions) sum(actions==1) / length(actions)];
        %figure; hold on; plot(actions,'o')
    end
    
    if sum(correct(1:60))/length(correct(1:60))<0.30 || sum(correct(61:180))/length(correct(61:180))<0.3 || sum(correct(181:300))/length(correct(181:300))<0.3...
            || sum(correct(301:420))/length(correct(301:420))<0.3 || sum(correct(421:540))/length(correct(421:540))<0.3
        flag(s) = 1; blockflag(s) = 1;
    end
    
    if pcorr(s)<cutoff
        flag(s) = 1; cutflag(s) = 1;
    end
    
end
disp(['Total participants excluded: ',num2str(sum(flag))])
disp(['Excluded because overall % accuracy < ',num2str(cutoff),':',num2str(sum(cutflag))])
disp(['Excluded because always or never pressing: ',num2str(sum(pressflag))])
disp(['Excluded because <30% accuracy in any condition: ',num2str(sum(blockflag))])

% % subjects who were <30% on any one condition and always pressing were also <50% overall 
find(cutflag==1 & pressflag==1 & blockflag==1)

% 3 subjects who were <30% on any one condition were also <50% overall 
find(cutflag==1 & blockflag==1)

% 4 subjects who were always or never pressing and were also <50% overall 
find(cutflag==1 & pressflag==1)

figure; hold on;
histogram(pcorr,25);
xlabel('% Accuracy'); ylabel('# of Subjects'); xlim([0 1]); box off; set(gcf,'Position',[200 200 800 300])
subj = subj(flag==0); % filter subjecs

data.legStr = {'Baseline (S=2)','HiSim, LowCtrl (S=4)','HiSim, HiCtrl (S=4)', 'LowSim, LowCtrl (S=4)','LowSim, HiCtrl (S=4)'};


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
    
    n_trials = sum(~isnan(cell2mat(A(:,15))));
    data(s).t = [1:n_trials]'; % trial #
    %states = {'go_a', 'nogo_b', 'go_c', 'nogo_d'};
    %for i = 1:length(states)
    %    A(:,14) = strrep(A(:,14),states{i},num2str(i));
    %end
    [~,~,bin] = unique(A(:,14),'sorted');
    data(s).s =  bin(bin>1 & ~isnan(cell2mat(A(:,15))))-1; % states
    data(s).a = double(str2double(A(trial_idx,9))==32) + 1; % 1 = no-go, 2 = go
    data(s).corchoice = (str2double(A(trial_idx,11))==32)+1; % what is the correct choice?
    data(s).acc = str2double(A(trial_idx,12)); % accuracy: correct or not
    data(s).r = cell2mat(A(trial_idx+1,15));   % reward
    data(s).rt = str2double(A(trial_idx,1));   % reaction time
    data(s).N = length(data(s).s);
    data(s).block = [];
    for n = 1:length(trials_per_block)
        data(s).block = [data(s).block n*ones(1,trials_per_block(n))];
    end
    
    % reward functions
    data(s).condQ(1).Q = [0.8, 0.2; 0.2, 0.8];
    data(s).condQ(2).Q = [0.6, 0.4; 0.4, 0.6; 0.6, 0.4; 0.4, 0.6];
    data(s).condQ(3).Q = [0.8, 0.2; 0.2, 0.8; 0.8, 0.2; 0.2, 0.8];
    data(s).condQ(4).Q = [0.8, 0.2; 0.2, 0.8; 0.6, 0.4; 0.4, 0.6];
    data(s).condQ(5).Q = [0.8, 0.2; 0.2, 0.8; 1, 0; 0, 1];
    
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
save(strcat('gng_data.mat'),'data')
end
