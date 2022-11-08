function X = SpherePoints(N)
% This function generates equi-distance points on the unit sphere 
% 'equalpart' type is based in equal-area partitioning algorithm of 
%    E. B. Saff and A. B. J. Kuijlaars, Distributing many points on a sphere, Math. Intelligencer, 19 (1997), pp. 5--11.
% 'spiral' type is based on J. N. Ridley. Ideal phyllotaxis on general surfaces of revolution. Mathematical Biosciences, 79:1–24, 1986.

% N: number of points requested (input)
% X: generated points of size (N x 3)
SphereTypePoints = 'equalpart';
switch SphereTypePoints
    case 'equalpart'
        h = -1+ (2.*((1:N)-1)./(N-1));
        theta = acos(h')-pi/2;
        phi = zeros(N, 1);
        p = (3.6/sqrt(N).*(1./sqrt(1-h(2:N-1).^2)));
        for k = 2:N-1
            phi(k) = mod(phi(k-1)+ p(k-1),2*pi);
        end
        phi = phi-pi;
        [x,y,z] = sph2cart(phi,theta,1);
        X = [x(:) y(:) z(:)];
        X(1,:) = [0,0,1];
        X(end,:) = [0,0,-1];
    case 'spiral'
        inc = pi*(3-sqrt(5));
        off = 2/N;
        k = 0:(N-1);
        z = k*off - 1 + (off/2);
        r = sqrt(1 - (z.^2));
        phi = k*inc;
        X = [cos(phi).*r;sin(phi).*r;z]';               
end