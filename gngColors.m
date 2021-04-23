function map = gngColors(n)
% color scheme/aesthetic palette for go/nogo controllability paper
addpath '/Users/lucy/Google Drive/Harvard/Projects/mat-tools/'

if n > 4
    %map = brewermap(n+2,'Blues');
    %map = map(2:end,:);
    map = brewermap(n,'Set1');
else
    map = brewermap(n,'*RdBu');
end

if n == 4
    temp = map(3,:);
    map(3,:) = map(4,:);
    map(4,:) = temp;  % swap colors so darker ones are fixed
end

set(0, 'DefaultAxesColorOrder', map) % first three rows
set(0, 'DefaultLineLineWidth', 2) % set line width

end