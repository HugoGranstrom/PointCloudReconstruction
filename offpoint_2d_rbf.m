close all;
clear

N = 10;
delta = 1e-1;
sigma = 1;

epsilon = 10;

r = @(x) sqrt(dr + x(:,1).^2 + x(:,2).^2 + x(:,3).^2);
rbf_func = @(r) (1 - r ./ epsilon).^4 .* (r < epsilon) .* (4 * r / epsilon + 1);
rbf_grad = @(x) -x .* 20 .*(1-r(x)).^3;
% rbf_func = @(r) exp(-((epsilon*r).^2));

%r = 2 * pi * rand(N, 1);
r = 2*pi*linspace(0,1,N)';
circle_x = cos(r);
circle_y = sin(r);
circle = horzcat(circle_x, circle_y);
normals = circle; % Per definition

%scatter(circle_x, circle_y);

delta_pos = circle + delta*normals;
delta_neg = circle - delta*normals;

train_data = vertcat(circle, delta_pos, delta_neg);
train_data_z = vertcat(zeros(size(circle,1),1), sigma.*ones(size(delta_pos,1),1), -sigma.*ones(size(delta_neg,1),1));


potential = rbf(train_data, train_data_z, rbf_func, rbf_grad);

potential_xy = @(x, y) potential(horzcat(x,y));

figure;
hold on
fcontour(potential_xy, 'LevelList', [0]);
scatter(circle_x, circle_y);
hold off

figure;
[x, y] = meshgrid(-2:0.01:2);
z = reshape(potential_xy(flatten(x),flatten(y)), size(x));
hold on
s = surf(x,y,z);
alpha 0.5
shading interp
scatter(circle_x, circle_y);
quiver3(circle_x, circle_y, zeros(size(circle_y)), circle_x*delta*4, circle_y*delta*4, zeros(size(circle_y)),"off")
quiver3(circle_x, circle_y, zeros(size(circle_y)), -circle_x*delta*4, -circle_y*delta*4, zeros(size(circle_y)),"off")
r = 2*pi*linspace(0,1,1000)';
plot3(cos(r), sin(r), zeros(size(r)))
hold off