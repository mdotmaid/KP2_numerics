function [ soli ] = vertical_segment(am,ad,au,...
                                     qm,qu,qd,...
                                     x0,y0,w,Lx,Ly,Nx,Ny,tstart)
	soli.x  = linspace(-Lx,Lx-(2*Lx/Nx),Nx);
	soli.y  = linspace(-Ly,Ly-(2*Ly/Ny),Ny);
	%% CURRENTLY ASSUMES am=1
    if am~=1
        disp('Setting middle state to 1...');
        am = 1;
    end
          %% Define Soliton parameters and derivatives in x and y
            soli.w     = (w);
            soli.a     = @(x,y,t) au                         .*( (y-soli.w/2)/t >= 2-4/3*sqrt(au) ) + ...
                                  9/64*(2-(y-soli.w/2)/t).^2 .*(-2/3<(y-soli.w/2)/t).*((y-soli.w/2)/t<2-4/3*sqrt(au)) +...
                                  1                          .*((y-soli.w/2)/t<=-2/3).*((y+soli.w/2)/t>=+2/3) +...
                                  9/64*(2+(y+soli.w/2)/t).^2 .*(+2/3>(y+soli.w/2)/t).*((y+soli.w/2)/t>4/3*sqrt(au)-2) +...
                                  ad                         .*( (y+soli.w/2)/t <= 4/3*sqrt(ad)-2);
            soli.ax    = @(x,y,t) (zeros(size(x)));
            soli.ay    = @(x,y,t) zeros(size(x));
%                                   9/32*(2-(y-soli.w/2)/t)/t .*(-2/3<(y-soli.w/2)/t).*((y-soli.w/2)/t<2-4/3*sqrt(au)) +...
%                                   9/32*(2+(y+soli.w/2)/t)/t .*(+2/3>(y+soli.w/2)/t).*((y+soli.w/2)/t>4/3*sqrt(au)-2);
            soli.q     = @(x,y,t) (1-sqrt(soli.a(x,y,t)))     .*(-2/3<(y-soli.w/2)/t) + ...
                                  (sqrt(soli.a(x,y,t))-1)    .*(+2/3>(y+soli.w/2)/t);
            soli.qx    = @(x,y,t) (zeros(size(x)));
            soli.qy    = @(x,y,t) zeros(size(x));
            soli.x0    = (x0);
            soli.y0    = (y0);
            soli.G = 0;
      %% Define Soliton function, derivatives
          soli.u  = @(atheta,x,y,t,a,g) g + a(x,y,t).*(sech(atheta)).^2; % CORRECT
          soli.dx = @(x,y,t) (zeros(size(x)));
          soli.dy = @(x,y,t) (zeros(size(x)));
      % Theta and derivatives
          % Theta is modulated wave variable such that
                %theta_x =  sqrt(a/12)
                %theta_y =  sqrt(a/12)*q
                %theta_t = -sqrt(a/12)*(a/3+q^2+g)
                soli.th.intx = zeros(Nx,Ny);
            for Nxi = 1:length(soli.x)
                soli.th.intx
            end
              
          soli.ath = @(x,y,t,a,q,g) (x + q(x,y,t).*y - (a(x,y,t)/3+q(x,y,t).^2+g) * t); % FIXED
          soli.thx = @(x,y,t) (zeros(size(x)));
          soli.thy = @(x,y,t) (zeros(size(x)));
        
      % Asymptotic soliton approximation
          soli.ua  = @(x,y,t)  soli.u(soli.ath(x-soli.x0,y-soli.y0,t,soli.a,soli.q,soli.G),...
                                      x-soli.x0,y-soli.y0,t,soli.a,soli.G);
          soli.uax  = @(x,y,t) (zeros(size(x)));
          soli.uay  = @(x,y,t) (zeros(size(x)));
                                    
%       %% Define Soliton function, derivatives
%           soli.u  = @(theta,x,y,t,a,g) g + a(x,y,t).*(sech(sqrt(a(x,y,t)/12).*theta)).^2; % CORRECT
%           soli.dx = @(theta,dxtheta,x,y,t,a,ax) sech(sqrt(a(x,y,t)/12).*theta).^2.*...
%                      (ax(x,y,t) + sqrt(a(x,y,t)/12).*tanh(sqrt(a(x,y,t)/12).*theta).*...
%                           dxtheta);
%           soli.dy = @(theta,dytheta,x,y,t,a,q,ay) sech(sqrt(a(x,y,t)/12).*theta).^2.*...
%                      (ay(x,y,t) + sqrt(a(x,y,t)/12).*tanh(sqrt(a(x,y,t)/12).*theta).*...
%                           dytheta);
%       % Theta and derivatives
%           soli.th = @(x,y,t,a,q,g) (x + q(x,y,t).*y - (a(x,y,t)/3+q(x,y,t).^2+g) * t); % FIXED
%           soli.thx = @(x,y,t,a,ax,q,qx,g) ((g*t-x-y.*q(x,y,t)+t*q(x,y,t).^2).*ax(x,y,t)+...
%                               a(x,y,t).*(-2+t*ax(x,y,t)-2*(y-2*t*q(x,y,t)).*qx(x,y,t)));
%           soli.thy = @(x,y,t,a,ay,q,qy,g) ((g*t-x-y.*q(x,y,t)+t*q(x,y,t).^2).*ay(x,y,t)+...
%                               a(x,y,t).*(t.*ay(x,y,t)-2*y.*qy(x,y,t)+...
%                               q(x,y,t).*(-2+ 4*t.*qy(x,y,t))));
%         
%       % Asymptotic soliton approximation
%           soli.ua  = @(x,y,t)  soli.u(soli.th(x-soli.x0,y-soli.y0,t,soli.a,soli.q,soli.G),...
%                                       x-soli.x0,y-soli.y0,t,soli.a,soli.G);
%           soli.uax  = @(x,y,t) soli.dx(soli.th(x-soli.x0,y-soli.y0,t,soli.a,soli.q,soli.G),...
%                                   soli.thx(x-soli.x0,y-soli.y0,t,soli.a,soli.ax,soli.q,soli.qx,soli.G),...
%                                    x-soli.x0,y-soli.y0,t,soli.a,soli.ax);
%           soli.uay  = @(x,y,t) soli.dy(soli.th(x-soli.x0,y-soli.y0,t,soli.a,soli.q,soli.G),...
%                                        soli.thy(x-soli.x0,y-soli.y0,t,soli.a,soli.ay,soli.q,soli.qy,soli.G),...
%                                         x-soli.x0,y-soli.y0,t,soli.a,soli.q,soli.ay);
        end
