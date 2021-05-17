function bonused
expt = {'292905','293787'};
figure; hold on;
for i = 1:length(expt)
    A = readtable(expt{i});
    A = table2cell(A);
    
    if i == 1 % how much bonused
        bonus = cell2mat(A(:,9))+7;
    else
        bonus = cell2mat(A(:,9))+1;
    end
    
    histogram(bonus,20);
    xlabel('$ Payout'); ylabel('# of Subjects'); xlim([0 17]); box off; set(gcf,'Position',[200 200 800 300])
    
end
legend('$7+bonus','$1+bonus')
end