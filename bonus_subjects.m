function bonus_subjects
% analyze raw data and store into structure
clear all
% batch of 40 (Full Pilot 1)
% subj = {'A19TD2J8506A4Y','A19WXS1CLVLEEX','A1B5SSGMTAQ9B5','A1BFA82J9Q1CLA','A1NDMFN9A5G25G','A1SOFLJOEQB591','A1T3ROSW2LC4FG','A2196WCNDZULFS','A24Z9RP5YZZ2TY','A2615YW1YERQBO','A2IQ0QCTQ3KWLT','A2V27A9GZA1NR2','A30HUZHJBOX1LK','A348NEQKS6VNIB','A34SIGOLUGKIHJ','A37S96RT1P1IT2','A3CTXNQ2GXIQSP','A3FNC8ELMK8YJA','A3G5IPGLH1IIZN','A3GLUDQZGEJL5G','A3K9GTQBOI7O5A','A98E8M4QLI9RS','AFU00NU09CFXE','AJQ71YIGY01HZ','AMELYCC59JKB0','AOS2PVHT2HYTL','AVCOBHDVXZOZL','AZNIEFUIVB2H0','A3RKG5PZN97RD5','A12XVSIL669PVI.csv','A1GKD3NG1NNHRP.csv','A1HRH92NH49RX2.csv','A273DS7TQWR9M1.csv','A2VNSNAN1LZBAM.csv','A9HQ3E0F2AGVO.csv','AA4O2W236E3FW.csv','A1SISJL5ST2PWH.csv','A2871R3LEPWMMK.csv','A2ZDEERVRN5AMC.csv','A4ZPIPBDO624H.csv'};

% batch of 13/20
subj = {'A10JXOU89D5RXR.csv','A1I72NHC21347A.csv','A1Q56N80RJLQ7S.csv','A2APG8MSLJ6G2K.csv','A2PIFMM4Q2I9ZS.csv','A2VNWJU49OOVFC.csv','A33LYSCQQU1YDJ.csv','A3RHJEMZ4EGY2U.csv','A3V2XCDF45VN9X.csv','ACKG8OU1KHKO2.csv','AOS2PVHT2HYTL.csv','AQXEQDTAU4MJ4.csv','AOOLS8280CL0Z.csv'};
subj = {'A348NEQKS6VNIB.csv'}

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
    bonus2(s,:) = rew/(rew+unrew) * 15;
    
    % display bonuses
    %disp(strcat(subj{s},':', num2str(pcorr))) % actually correct
    disp(strcat(subj{s},':', num2str(bonus2(s,:)))) % later you can generate automatic CSV to bonus people :D
    
    
end

writecell([subj',num2cell(bonus2)],'bonus.csv')
end