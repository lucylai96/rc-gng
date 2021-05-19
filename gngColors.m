function map = gngColors(n)
% color scheme/aesthetic palette for go/nogo controllability paper
addpath '/Users/lucy/Google Drive/Harvard/Projects/mat-tools/'
prettyplot

if n > 4
    map1 = brewermap(n,'Set1');
    map2 = brewermap(n,'Pastel1');
    d = map2-map1;
    map = map1+d/2;
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
set(0, 'DefaultLineLineWidth', 2) % set line width
end