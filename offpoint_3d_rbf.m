N = 10;
delta = 1e-2;
sigma = 1;

epsilon = 5;

rbf_func = @(r) exp(-((epsilon*r).^2));

phi = 2*pi*linspace(0,1 - 1/N,N)';
theta = pi*linspace(1/N,1 - 1/N,N)';

[phi, theta] = meshgrid(phi, theta);
phi = reshape(phi, [N^2 1]);
theta = reshape(theta, [N^2 1]);

sphere_x = sin(theta).*cos(phi);
sphere_y = sin(theta).*sin(phi);
sphere_z = cos(theta);


sphere = horzcat(sphere_x, sphere_y, sphere_z);
normals = sphere; % Per definition


delta_pos = sphere + delta*normals;
delta_neg = sphere - delta*normals;

train_data = vertcat(sphere, delta_pos, delta_neg);
train_data_w = vertcat(zeros(size(sphere,1),1), sigma.*ones(size(delta_pos,1),1), -sigma.*ones(size(delta_neg,1),1));

scatter3(sphere_x, sphere_y, sphere_z)

potential = rbf(train_data, train_data_w, rbf_func);

[x,y,z] = meshgrid([-3:0.25:3]);
V = potential(horzcat(flatten(x), flatten(y), flatten(z)));
V = reshape(V, size(x));

s = isosurface(x,y,z,V, 0);

% Some lightning for viewability

p = patch(s);
isonormals(x,y,z,V,p)
view(3);
set(p,'FaceColor',[0.5 1 0.5]);  
set(p,'EdgeColor','none');
camlight;
lighting gouraud;
