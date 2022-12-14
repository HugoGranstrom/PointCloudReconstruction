close all;
N = 1000;
delta = 1e-3;
sigma = 1;

epsilon = 1;

%rbf_func = @(r) exp(-((epsilon*r).^2));
rbf_func = @(r) (1 - r ./ epsilon).^4 .* (r < epsilon) .* (4 * r / epsilon + 1);

%phi = 2*pi*linspace(0,1 - 1/N,N)';
%theta = pi*linspace(1/N,1 - 1/N,N)';

%[phi, theta] = meshgrid(phi, theta);
%phi = reshape(phi, [N^2 1]);
%theta = reshape(theta, [N^2 1]);

%sphere_x = sin(theta).*cos(phi);
%sphere_y = sin(theta).*sin(phi);
%sphere_z = cos(theta);

%sphere = horzcat(sphere_x, sphere_y, sphere_z);
%sphere = SpherePoints(N);
%pc = pointCloud(sphere);
load homer.mat
sphere = ptcloud;
%normals = nrml;
%normals = pcnormals(pc)
%err = mean(sum(abs(normals - sphere), 2))
%quiver3(sphere_x, sphere_y, sphere_z, normals(:,1),normals(:,2),normals(:,3))
%normals = sphere; % Per definition

max_min_dist = max(min(distanceMatrix(sphere, sphere) + 1000*diag(ones([size(sphere, 1) 1]))))

delta_pos = sphere + delta*normals;
delta_neg = sphere - delta*normals;

train_data = vertcat(sphere, delta_pos, delta_neg);
train_data_w = vertcat(zeros(size(sphere,1),1), sigma.*ones(size(delta_pos,1),1), -sigma.*ones(size(delta_neg,1),1));

figure;
%scatter3(sphere(:,1), sphere(:,2), sphere(:,3))
disp('Starting rbf interpolation')

tic
%potential = rbfPU(train_data, train_data_w, @rbf, rbf_func, rbf_func, 450); % (k, 0.9 / (k-1))
potential = rbf(train_data, train_data_w, rbf_func, rbf_func);
disp('Finished interpolation construction')

%% 

disp('Lets go!')
[x,y,z] = meshgrid(linspace(min(min(sphere)), max(max(sphere)), 100));
tic
V = potential(horzcat(flatten(x), flatten(y), flatten(z)));
toc

V = reshape(V, size(x));
disp('Done!')

%% 


s = isosurface(x,y,z,V, 0);

% Some lightning for viewability

p = patch(s);
isonormals(x,y,z,V,p)
set(p,'FaceColor',[0.5 1 0.5]);  
set(p,'EdgeColor','none');
camlight('right', 'infinite');
%shading interp
lighting gouraud 
daspect([1 1 1]);
view([90 0]);

axis off;

