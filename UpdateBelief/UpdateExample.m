%%
% This code contains an example of updating the brior for every state
% we need to creat a 4D matrix which coontains every state in 
%
% This piece of code must be able to update and viualize the state space,
% as well as the force distribution of each state
%
%%

% our state space (only one state variable) is a 4D matrix, containing the
% following dimensions: (Fy, Fx, Vy, Vx)

% Example: a specific point in state space would have a specific Vx and Vy,
% and for this specific state we have a 2D distribution of force (X and Y).

% let's try out a gaussian
fx = -5:0.1:5; fx_mu = 3; fx_sigma = 1;
fy = -5:0.1:5; fy_mu = 0; fy_sigma = 1;
F = Gauss2d( fx, fx_mu, fx_sigma, fy, fy_mu, fy_sigma);

figure; % two different ways to display the distribution
subplot(121); surf(fx, fy, F); xlabel('f_x'); ylabel('f_y');
subplot(122); imagesc(fx, fy, F); xlabel('f_x'); ylabel('f_y'); axis xy

%% 

% what are informations that we need to create out state space?
% 1) Maximum and minimum speeds that human exhibit during experiment
% 2) State variable resolution, we could use 0.01! i dont know

Vmin = -5;
Vmax = 5;
Vres = 0.1;
Vx = Vmin:Vres:Vmax; Vy = Vx;
Vsize   = length(Vmin:Vres:Vmax);
% /////////////////////////////////////////////////////////////////

% Now, each state needs its own force distribution, so what do we need?
% 1) Max force and min force that subjects exhibit
% 2) Force resolution
% 3) The prior (i.e., the mean for the force distribution)
% 4) Uncertainty in sensory input (the variance in our likelihood)

Fmin = -5;
Fmax = 5;
Fres = 0.1;
Fx = Fmin:Fres:Fmax; Fy = Fx;

% This is what is saved in our implicit memory (assumption)
% These are initially adjusted to whatever we have been training for, 
% it can also be based on textual cue! so we retrieve another set of them
Fmus    = zeros(2, Vsize, Vsize);
Fsigmas = ones(2, Vsize, Vsize);

% let's change some of the sigma:
Fsigmas(:, 30:70, 30:70) = 0.5;

Fsigmas(:, 40:60, 40:60) = 0.1;

%%
% A function to initialize the state space based on given mu and sigma data

% This function needs the mu and signam values for each specific state
sspace = compSpace(Fmin, Fmax, Fres, Vmin, Vmax, Vres, Fmus, Fsigmas);

%% Display the state space

sspace_image = showSpace(sspace);
figure; imagesc(Fx, Fy, sspace_image); xlabel('f_x'); ylabel('f_y'); axis xy
colorbar;
figure; surf(Fx, Fy, sspace(:,:,50,50)); xlabel('f_x'); ylabel('f_y');

% To display the progression in out state space we can always take the
% maximum value of each states prior and plot them "image" of out state
% space