%% Driver file for KP2 numerical solver
%% Domain, ICs, etc go here
save_on  = 1;  % Set to nonzero if you want to run the solver, set
               % to 0 if you want to plot
rmdir_on = 0;  % Set to nonzero if you want to delete and remake the chosen directory
               % Useful for debugging
gpu_on   = 1;  % set to nonzero to use GPU, otherwise CPU
periodic = 1;  % set to nonzero to run periodic solver (no BCs need)
               % set to 0 to run solver with time-dependent BCs                
plot_on  = 1;  % Set to 1 if you want to plot just before and just
               % after (possibly) calling the solver          
check_IC = 1;  % Set to nonzero to plot the ICs and BCs without running the solver

dd = struct();
sads = [1 4 4  4  1];
qads = [1 1 0 -1 -1];
for ii = 1:5
    %% Numerical Parameters
    tmax   = 150;      % Solver will run from t=0 to t = tmax
    numout = tmax+1; % numout times will be saved (including ICs)
    Lx     = 500;     % Solver will run on x \in [-Lx,Lx]
    Ly     = Lx/2;     % Solver will run on y \in [-Ly,Ly]
    Nexp   = 8;
    Nx     = 2^Nexp;    % Number of Fourier modes in x-direction
    Ny     = 2^(Nexp-1);    % Number of Fourier modes in y-direction

    t      = linspace(0,tmax,numout);
   Nt      = 3;
   dt      = 10^(-Nt);
    %% Initial Condition and large-y approximation in time
%         ic_type = ['KP2_validation_Nexp_',num2str(Nexp),'_dt_',num2str(Nt),'_twosoli'];
        %% One-soliton, corrected for nonzero integral in x
        sau = 1; sad = sads(ii);
        qau = 0; qad = qads(ii);
            x0 = 150; y0 = 0; x0odd = -150;
            tanw = 1/10;
%% Define Soliton parameters and derivatives in x and y
    soli.tw    = tanw;
    soli.a     = @(x,y,t) (sad-sau)/2*tanh(tanw*(y-0)) + (sad+sau)/2;%qa(x,y,t);% qa   .* ones(size(x));
    soli.ax    = @(x,y,t) zeros(size(x));
    soli.ay    = @(x,y,t) (sad-sau)/2*tanw*sech(tanw*(y-0)).^2;
    soli.q     = @(x,y,t) (qad-qau)/2*tanh(tanw*(y-0)) + (qad+qau)/2;%qa(x,y,t);% qa   .* ones(size(x));
    soli.qx    = @(x,y,t) zeros(size(x));
    soli.qy    = @(x,y,t) (qad-qau)/2*tanw*sech(tanw*(y-0)).^2;
    soli.x0    = x0;
    soli.y0    = y0;
    soli.G = 0;
%% Define Soliton function, derivatives
    soli.u  = @(theta,x,y,t,a,g) g + a(x,y,t).*(sech(sqrt(a(x,y,t)/12).*theta)).^2; % CORRECT
    soli.dx = @(theta,dxtheta,x,y,t,a,ax) sech(sqrt(a(x,y,t)/12).*theta).^2.*...
               (ax(x,y,t) + sqrt(a(x,y,t)/12).*tanh(sqrt(a(x,y,t)/12).*theta).*...
                    dxtheta);
    soli.dy = @(theta,dytheta,x,y,t,a,q,ay) sech(sqrt(a(x,y,t)/12).*theta).^2.*...
               (ay(x,y,t) + sqrt(a(x,y,t)/12).*tanh(sqrt(a(x,y,t)/12).*theta).*...
                    dytheta);
% Theta and derivatives
    soli.th = @(x,y,t,a,q,g) (x + q(x,y,t).*y - (a(x,y,t)/3+q(x,y,t).^2+g) * t); % FIXED
    soli.thx = @(x,y,t,a,ax,q,qx,g) ((g*t-x-y.*q(x,y,t)+t*q(x,y,t).^2).*ax(x,y,t)+...
                        a(x,y,t).*(-2+t*ax(x,y,t)-2*(y-2*t*q(x,y,t)).*qx(x,y,t)));
    soli.thy = @(x,y,t,a,ay,q,qy,g) ((g*t-x-y.*q(x,y,t)+t*q(x,y,t).^2).*ay(x,y,t)+...
                        a(x,y,t).*(t.*ay(x,y,t)-2*y.*qy(x,y,t)+...
                        q(x,y,t).*(-2+ 4*t.*qy(x,y,t))));
  
% Asymptotic soliton approximation
    soli.ua  = @(x,y,t)  soli.u(soli.th(x-soli.x0,y-soli.y0,t,soli.a,soli.q,soli.G),...
                                x-soli.x0,y-soli.y0,t,soli.a,soli.G);
    soli.uax  = @(x,y,t) soli.dx(soli.th(x-soli.x0,y-soli.y0,t,soli.a,soli.q,soli.G),...
                            soli.thx(x-soli.x0,y-soli.y0,t,soli.a,soli.ax,soli.q,soli.qx,soli.G),...
                             x-soli.x0,y-soli.y0,t,soli.a,soli.ax);
    soli.uay  = @(x,y,t) soli.dy(soli.th(x-soli.x0,y-soli.y0,t,soli.a,soli.q,soli.G),...
                                 soli.thy(x-soli.x0,y-soli.y0,t,soli.a,soli.ay,soli.q,soli.qy,soli.G),...
                                  x-soli.x0,y-soli.y0,t,soli.a,soli.q,soli.ay);
%% Initial condition, with odd reflection
	soli.x0odd = x0odd;
	soli.u0 = @(x,y)    soli.ua(x,y,0) - soli.ua(x+soli.x0-soli.x0odd,y,0);

    ic_type = ['_solikink_',...
                    '_au_',num2str(sau),'_qu_',num2str(qau),...
                    '_ad_',num2str(sad),'_qd_',num2str(qad),...
                    '_x0_',num2str(x0 ),'_y0_',num2str(y0)];

    %% Generate directory, save parameters
	q = strsplit(pwd,filesep);
    %% use CPU or GPU code, depending
    cpath = [strjoin(q(1:end-1),filesep),filesep,'solver'];
    gpath = [strjoin(q(1:end-1),filesep),filesep,'solver_GPU'];
    pathCell = regexp(path, pathsep, 'split');
    
    if gpu_on
        addpath(gpath)
        if any(strcmpi(cpath, regexp(path, pathsep, 'split')))
            rmpath(cpath)
        end
    else
        addpath(cpath)
        if any(strcmpi(gpath, regexp(path, pathsep, 'split')))
            rmpath(gpath)
        end
    end
    if strcmp(computer,'MACI64')
        maindir = '/Volumes/Data Storage/Numerics/KP';
        if ~exist(maindir,'dir')
            q = strsplit(pwd,filesep);
            maindir = strjoin(q(1:end-1),filesep);
        end
    elseif strcmp(computer,'PCWIN64')
        maindir = 'H:';
    else
        q = strsplit(pwd,filesep);
        maindir = strjoin(q(1:end-1),filesep);
    end
        slant = filesep;

    %% Create directory run will be saved to
    data_dir = [maindir,slant,'Numerics',slant,'KP',slant,...
                '_tmax_',   num2str(round(tmax)),...
                '_Lx_',     num2str(Lx),...
                '_Nx_',     num2str(Nx),...
                '_Ly_',     num2str(Ly),...
                '_Ny_',     num2str(Ny),...
                '_bndry_condns_periodic',...
                '_init_condns_',ic_type,...
                slant];
    % Create the data directory if necessary
    if ~exist(data_dir,'dir')
        mkdir(data_dir);
    else
        disp(['Warning, directory ',data_dir]);
        if rmdir_on == 1
            disp('already exists, rewriting entire folder');
            rmdir(data_dir,'s')
            mkdir(data_dir);
        else
            disp('already exists, possibly overwriting data');
        end
    end
%     dd.(['qm',num2str(find(qrs==ql))]) = data_dir;
    savefile = sprintf('%sparameters.mat',data_dir);

    %% If chosen, run the solver using the parameters and conditions above
    if save_on
        if plot_on
            % Load initial data
              xplot  = (2*Lx/Nx)*[-Nx/2:Nx/2-1];
              yplot  = (2*Ly/Ny)*[-Ny/2:Ny/2-1];
              [XPLOT,YPLOT] = meshgrid(xplot,yplot);
              tplot  = linspace(0,tmax,floor(tmax*10));
              u_init = soli.u0(XPLOT,YPLOT);

            % Plot initial conditions and boundary conditions
            fontsize = 12;
            figure(1); clf;
            subplot(2,2,1)
                contourf(XPLOT,YPLOT,u_init,100,'edgecolor','none'); xlabel('x'); ylabel('y'); 
                title('Initial Conditions');
            subplot(2,2,2)
                contourf(XPLOT,YPLOT,soli.ua(XPLOT,YPLOT,0),100,'edgecolor','none'); xlabel('x'); ylabel('y'); 
                title('Asymptotic u');
            subplot(2,2,3)
                contourf(XPLOT,YPLOT,soli.uax(XPLOT,YPLOT,0),100,'edgecolor','none'); xlabel('x'); ylabel('y'); 
                title('Asymptotic u, x-deriv');
            subplot(2,2,4)
                contourf(XPLOT,YPLOT,soli.uay(XPLOT,YPLOT,0),100,'edgecolor','none'); xlabel('x'); ylabel('y'); 
                title('Asymptotic u, y-deriv');
            set(gca,'fontsize',fontsize,'fontname','times');
            pause(0.25);
            if check_IC
    %             colorbar;
    %             legend(ic_type);
                drawnow;  pause(0.5);
                continue;
            end
        end

        % Save parameters
            save(savefile,'t','Nx','Lx',...
                              'Ny','Ly',...
                              'soli','Nt',...
                              'periodic');
        % Run timestepper
            KP_solver_periodic( t, Lx, Nx, Nt,...
                                   Ly, Ny,...
                                   soli,...
                                   data_dir );     
    else
        load(savefile);
    end


    if plot_on
        try
            plot_data_fun_2D(data_dir);
            figure(4);
            print('sim','-dpng');
            send_mail_message('mdmaide2','Matlab',['Simulation ',data_dir,'done'],'sim.png')
        end
    else
        try
            send_mail_message('mdmaide2','Matlab',['Simulation ',data_dir,'done'])
        end
    end
end