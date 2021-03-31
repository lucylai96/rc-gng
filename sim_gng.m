function sim_gng(data,results)
% PURPOSE: simulate go-nogo experiment for diff controllability and set sizes?

% Written by: Lucy Lai

addpath('/Users/lucy/Google Drive/Harvard/Projects/rc-behav/code/GoNogo-control/')
prettyplot
beta = linspace(0.1,15,50);

rng(1); % set random seed for reproducibility

if nargin < 1
     data = generate_task;
     %data = load_data('data2.csv');
end
% 
% if nargin < 2
%     load model_fits;
%     results = results(1);
% end
prettyplot;

beta = linspace(0.1,15,50);
Ps = [0.33 0.33 0.33];
Q = [0.6 0.4;0.4 0.6; 0.6 0.4];
[R(1,:),V(1,:)] = blahut_arimoto(Ps,Q,beta);

Q = [0.8 0.2;0.2 0.8; 0.8 0.2];
[R(2,:),V(2,:)] = blahut_arimoto(Ps,Q,beta);

Q = [1 0;0 1;1 0];
[R(3,:),V(3,:)] = blahut_arimoto(Ps,Q,beta);

plot(R',V','-o')
legend('Low control','Medium control', 'High control')
box off;

for s = 1 % 1 subject
    data.s = 1;
    
end

for s = 1:length(data)
    
    %agent.lrate_beta = 0;
    agent.lrate_p = 0;
    agent.C = [];
    for k = 1:length(results.param)
        agent.(results.param(k).name) = results.x(s,k);
    end
    
    simdata(s) = actor_critic(agent,data(s));
end

simresults = analyze_gng(simdata);



%
%     % go-bias
%     if size(R,1) == 2
%         if s == 1
%             if a == 1 % go to win -- hit
%                 data.hitg(t) = 1;
%             else
%                 data.hitg(t) = 0;
%             end
%         elseif s == 2
%             if a == 2 % no-go to win  -- hit
%                 data.hitng(t) = 1;
%             else
%                 data.hitng(t) = 0;
%             end
%         end
%     elseif size(R,1) == 4
%         if s <=2
%             if a == 1 % go to win -- hit
%                 data.hitg(t) = 1;
%             else
%                 data.hitg(t) = 0;
%             end
%         elseif s >= 3
%             if a == 2 % no-go to win  -- hit
%                 data.hitng(t) = 1;
%             else
%                 data.hitng(t) = 0;
%             end
%         end
%
%     end
%
%     % store results
%     data.a(t) = a;
%     data.r(t) = r;
%     %data.w(t,:) = w;
%     data.rpe(t) = rpe;
%     data.theta(t,:) = theta;
%     data.phi(:,:,t) = phi;
%     data.rpe(t) = rpe;
%     data.V(t,:) = V;
%     data.Q(:,:,t) = Q;
%     data.cost(t) = ecost;
%
% end
% data.hitg(isnan(data.hitg)) = [];
% data.hitng(isnan(data.hitng)) = [];
% data.gobias = movmean(movmean(data.hitg,5)-movmean(data.hitng,5),5);

end