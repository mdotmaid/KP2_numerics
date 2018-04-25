function [ soli ] = vertical_segment_GPU(sam,sad,sau,...
                                         qam,qau,qad,...
                                         tw,x0,y0,Lx,w)
          %% Define Soliton parameters and derivatives in x and y
            soli.w     = gpuArray(w);
            soli.tw    = gpuArray(tw);
            soli.a     = @(x,y,t) gpuArray((sau-sam)/2*tanh(1/soli.tw*(y-soli.w/2))  - (sad-sam)/2*tanh(1/soli.tw*(y+soli.w/2)));
            soli.ax    = @(x,y,t) gpuArray(zeros(size(x)));
            soli.ay    = @(x,y,t) gpuArray((sau-sam)/2*1/soli.tw*sech(1/soli.tw*(y-soli.w/2)).^2 - (sad-sam)/2*1/soli.tw*sech(1/soli.tw*(y+soli.w/2)).^2);
            soli.q     = @(x,y,t) gpuArray((qau-qam)/2*tanh(1/soli.tw*(y-soli.w/2))  - (qad-qam)/2*tanh(1/soli.tw*(y+soli.w/2)));
            soli.qx    = @(x,y,t) gpuArray(zeros(size(x)));
            soli.qy    = @(x,y,t) gpuArray((qau-qam)/2*1/soli.tw*sech(1/soli.tw*(y-soli.w/2)).^2 - (qad-qam)/2*1/soli.tw*sech(1/soli.tw*(y+soli.w/2)).^2);
            soli.x0    = gpuArray(x0);
            soli.y0    = gpuArray(y0);
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
        end
