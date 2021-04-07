function map = gngColors
% color scheme/aesthetic palette for go/nogo controllability paper
addpath '/Users/lucy/Google Drive/Harvard/Projects/mat-tools/'

map = brewermap(2,'*RdBu');
%temp = map(3,:);
%map(3,:) = map(4,:);
%map(4,:) = temp;  % swap colors so darker ones are fixed


set(0, 'DefaultAxesColorOrder', map) % first three rows
set(0, 'DefaultLineLineWidth', 2) % set line width

end