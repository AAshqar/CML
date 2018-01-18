close all; clear all;

% initialize the global variables (mainly contains the biological aspects 
% of the subject, except memory)
InitGlobals()

doGeneralization = false;

% We have some implicit memory saved! and we can retrieve that memory.
% it can be based on textual cue!
memory     = retrieve_memory(1); % (1) is NULL field

% some experiment-specific parameters
exp = Exp_params(1);

% initialize the state space
global Vx; % biological range of Vx
global Vy; % biological range of Vy
Vsize = length(Vx);

sspace = zeros(2, 2, Vsize, Vsize); % state space initialization
sspace(:,1,:,:) = memory.Fmus; % memory retrieval
sspace(:,2,:,:) = memory.Fsigmas; % memory retrieval

% Compute ideal force field values for each state
idealF = compIdealF(exp.compF); 

% try to set the mean of the prior to the ideal force! this is ideal
% adaptation!
% sspace(:,1,:,:) = idealF;

% Position Information - this is task dependent
startPos  = [0, 0];
targetPos = [-5, 10];

% simulation params
dt     = 0.01;    % [s]  -> step size
period = 2;     % [s]
N      = ceil(period/dt); 

r         = zeros(N,2); % initial position
r_actual  = zeros(N,2);
v         = zeros(N,2); % initial speed
v_actual  = zeros(N,2);
a         = zeros(N,2); % initial acceleration
a_actual  = zeros(N,2);

% here is were the loop should be implemented
figure(1);
% for trials = 1:100;
%     clf;
    for i = 2:N

        t = dt*i;

        % Minimizing total jerk
        [r(i,:), v(i,:), a(i,:)] = compMinJerk(startPos, targetPos, period, t);

        % Compute the forcefield
        F_forcefield = exp.compF(v_actual(i-1,:));

        % Use the implicit memory to compute the adaptation force
        F_adapt = -useBelief(v_actual(i-1,:), sspace);

        % Update position, velocity and acceleration
        [r_actual(i,:), v_actual(i,:), a_actual(i,:)] = updateMinJerk(r(i-1,:), r_actual(i-1,:),...
                                                                      v(i-1,:), v_actual(i-1,:),...
                                                                      a(i-1,:), F_forcefield, F_adapt, dt);

        % Update the implicit memory
%         sspace = UpdateBelief(sspace, v_actual(i-1,:), F_forcefield, doGeneralization);
        [indx, indy] = findStateInd( v_actual(i-1,:));
        disp([indx, indy])
        sspace(:,1,indx, indy) = exp.compF(v_actual(i-1,:));
        % Display the update amount in the states
%         subplot(122); grid;

%         sspace_image = showSpace(idealF, sspace);
%         imagesc(Vy, Vx, sspace_image); xlabel('V_x'); ylabel('V_y'); axis xy
%         colorbar;

%         % Display the trajectory - velocity
%         subplot(122); grid; hold on;
%         sc5atter(v_actual(i-1,1), v_actual(i-1,2), 'o'); xlim([-15,15]); ylim([-15,15]);
% 
%         % Display the trajectory - position
%         subplot(121); grid; hold on;
%         scatter(r_actual(i,1), r_actual(i,2), 'o'); xlim([-10,10]); ylim([-5,15]);
%         % draw the start and target points
%         scatter(startPos(1), startPos(2), 'filled', 'k');
%         scatter(targetPos(1), targetPos(2), 'filled', 'r'); 
% 
        drawnow;
        pause(0.01)
    end
    figure;
    sspace_image = showSpace(idealF, sspace);
    imagesc(Vy, Vx, sspace_image'); xlabel('V_x'); ylabel('V_y'); axis xy
    colorbar;

% end


figure;
plot(sqrt(r_actual(:,1).^2 + r_actual(:,2).^2)); hold on
plot(sqrt(v_actual(:,1).^2 + v_actual(:,2).^2));
plot(sqrt(a_actual(:,1).^2 + a_actual(:,2).^2));