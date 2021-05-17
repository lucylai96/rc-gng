function bonus_subjects
% analyze raw data and store into structure
clear all

subj = {'A273DS7TQWR9M1','A12XVSIL669PVI','AA4O2W236E3FW','A9HQ3E0F2AGVO','A1GKD3NG1NNHRP','A1HRH92NH49RX2','A2VNSNAN1LZBAM','A2871R3LEPWMMK','A1SISJL5ST2PWH','A2ZDEERVRN5AMC','A4ZPIPBDO624H'};

for s = 1:length(subj)
    % 1:rt   2:url   3:trial_type   4:trial_index   5:time_elapsed
    % 6:internal_node_id   7: view_history
    % 8:stimulus   9:key_press   10:test_part   11:correct_response   12:correct
    % 13:use_rew   14:which_stim   15:reward   16:responses
    
    A = readtable(strcat('experiment/data/',subj{s}));
    A = table2cell(A);
    
    %% calculate bonus
    corr = sum(strcmp(A(40:end,12), 'true'));
    incorr = sum(strcmp(A(40:end,12), 'false'));
    pcorr(s) = corr/(corr+incorr);  
    
    rew = sum(cell2mat(A(:,15))==1);
    unrew = sum(cell2mat(A(:,15))==0);
    bonus2(s,:) = rew/(rew+unrew) * 10; % subj1
    %bonus2(s,:) = rew/(rew+unrew) * 15; % subj2
    
    % display bonuses
    disp(strcat(subj{s},':', num2str(bonus2(s,:)))) % later you can generate automatic CSV to bonus people :D
    
    
end
pcorr
writecell([subj',num2cell(bonus2)],'bonus.csv')
end