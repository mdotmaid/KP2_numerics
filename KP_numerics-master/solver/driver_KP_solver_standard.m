%% Driver file for KP2 numerical solver
%% Domain, ICs, etc go here
save_on  = 1;  % Set to nonzero if you want to run the solver, set
               % to 0 if you want to plot
rmdir_on = 0;  % Set to nonzero if you want to delete and remake the chosen directory
               % Useful for debugging
periodic = 1;  % setto nonzero to run periodic solver (no BCs need)
               % set to 0 to run solver with time-dependent BCs                
plot_on  = 0;  % Set to 1 if you want to plot just before and just
               % after (possibly) calling the solver          
check_IC = 0;  % Set to nonzero to plot the ICs and BCs without running the solver

% for Nexp = [6:8]

    %% Numerical Parameters
    tmax   = 10;      % Solver will run from t=0 to t = tmax
    numout = 10*tmax+1; % numout times will be saved (including ICs)
    Lx     = 25;     % Solver will run on x \in [-Lx,Lx]
    Ly     = Lx/2;     % Solver will run on y \in [-Ly,Ly]
    Nexp   = 8;
    Nx     = 2^Nexp;    % Number of Fourier modes in x-direction
    Ny     = 2^Nexp/2;    % Number of Fourier modes in y-direction

    t      = linspace(0,tmax,numout);
   Nt      = 3;
   dt      = 10^(-Nt);
    %% Initial Condition and large-y approximation in time
%         ic_type = ['KP2_validation_Nexp_',num2str(Nexp),'_dt_',num2str(Nt),'_twosoli'];
        %% One-soliton, corrected for nonzero integral in x
            sa = 0.5; q = 0; x0 = 0;
            [ soli ] = one_soli(sa,q,x0,Lx);
        ic_type = ['KP2_standard_sa_',num2str(sa),'_q_',num2str(q)];

    %% Generate directory, save parameters
    if strcmp(computer,'MACI64')
        maindir = '/Volumes/Data Storage/Numerics/KP';
    else
        maindir = 'H:';
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
                drawnow; 
                return;
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
    plot_data_fun_2D(data_dir);
    figure(4);
    print('validation','-dpng');
    send_mail_message('mdmaide2','Matlab',['Validation simulation ',data_dir,'done'],'validation.png')
end
% end