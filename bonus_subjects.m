function bonus_subjects
% analyze raw data and store into structure
clear all

%'A2NHFSO7GMM8QR','A1K8VUKRL53OX'
subj = {'A23KAJRDVCVGOE','A1ROEDVMTO9Y3X','A1P2RQ166VS5BT','A1P0XSCJ9XAV74','APGX2WZ59OWDN','A1UZXOMO6BS6I2','A1YH2I4Y2SYAXJ','A1IFIK8J49WBER','AOAZMLP27GD81','A3QSFE6GKO157S','ARYL3C6N9SVV1','A3QRZPJT2CT2IK','A16Z9FSSF1X74O','A2BK45LZGGWPLX','A1945USNZHTROX','A13WTEQ06V3B6D'};
 
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
    bonus2(s,:) = rew/(rew+unrew) * 10; % subj2
    
    % display bonuses
     disp(strcat(subj{s},':', num2str(bonus2(s,:))))   % later you can generate automatic CSV to bonus people :D
    
    
end
pcorr
writecell([subj',num2cell(bonus2)],'bonus.csv')

bonused
end

function bonused
% see how much was bonused

expt = {'293787','292905','294904'};
figure; hold on;
for i = 1:length(expt)
    A = readtable(expt{i});
    A = table2cell(A);
    
    if i > 1 % how much bonused
        bonus = cell2mat(A(:,9))+7;
    else
        bonus = cell2mat(A(:,9))+1;
    end
    
    histogram(bonus,20);
    xlabel('$ Payout'); ylabel('# of Subjects'); xlim([0 17]); box off; set(gcf,'Position',[200 200 800 300])
    
end
legend('$7+bonus','$1+bonus')
end
