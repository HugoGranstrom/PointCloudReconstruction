N = 20;
delta = 1e-2;
sigma = 1;

epsilon = 2;

rbf_func = @(r) exp(-((epsilon*r).^2));

r = 2 * pi * rand(N, 1);
%r = 2*pi*linspace(0,1,N)';
circle_x = cos(r);
circle_y = sin(r);
circle = horzcat(circle_x, circle_y);
normals = circle; % Per definition

%scatter(circle_x, circle_y);

delta_pos = circle + delta*normals;
delta_neg = circle - delta*normals;

train_data = vertcat(circle, delta_pos, delta_neg);
train_data_z = vertcat(zeros(size(circle,1),1), sigma.*ones(size(delta_pos,1),1), -sigma.*ones(size(delta_neg,1),1));


potential = rbf(train_data, train_data_z, rbf_func);

potential_xy = @(x, y) potential(horzcat(x,y));

hold on
fcontour(potential_xy, 'LevelList', [0]);
scatter(circle_x, circle_y);
hold off