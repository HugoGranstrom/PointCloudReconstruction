clear all;
close all;

epsilon = 1;
dr = 1e-14;
delta = 1e-1;
sigma = 1;

r = @(x) sqrt(dr + x(:,1).^2 + x(:,2).^2 + x(:,3).^2);

rbf_func = @(r) (1 - r ./ epsilon).^4 .* (r < epsilon) .* (4 * r / epsilon + 1);
rbfgrad = @(x) -x .* 20 .*(1-r(x)).^3;
rbfHessian =  @(x) (supportHessianRBF(x, epsilon, dr));

%[x, y, z] = meshgrid(linspace(-1.1, 1.1));

%eval_points = horzcat(flatten(x), flatten(y), flatten(z));

N = 3000 * 2;
num_patches = N / 2 / 10;

points = SpherePoints(N);
points_eval = points(1:2:end,:);

points = points(2:2:end,:);
normals = points;

%scatter3(points(:,1), points(:,2), points(:,3), 'r')

% CF
tic
potential_cf = cfrbf(points, normals, rbfHessian, rbfgrad);
disp(['Curl-free construction: ' num2str(toc)])
tic
V_cf = potential_cf(points_eval);
disp(['Curl-free evaluation: ' num2str(toc)])
error = sum(V_cf .^ 2);
disp(['Curl-free error: ' num2str(error)])

% CF-PU
tic
potential_cf = rbfPU(points, normals, @cfrbf, rbfHessian, rbfgrad, num_patches);
disp(['Curl-free PU construction: ' num2str(toc)])
tic
V_cf = potential_cf(points_eval);
disp(['Curl-free PU evaluation: ' num2str(toc)])
error = sum(V_cf .^ 2);
disp(['Curl-free PU error: ' num2str(error)])

% Off-point
delta_pos = points + delta*normals;
delta_neg = points - delta*normals;

train_data = vertcat(points, delta_pos, delta_neg);
train_data_w = vertcat(zeros(size(points,1),1), sigma.*ones(size(delta_pos,1),1), -sigma.*ones(size(delta_neg,1),1));

tic
potential_op = rbf(train_data, train_data_w, rbf_func, rbfgrad);
disp(['Off-point construction: ' num2str(toc)])
tic
V_op = potential_op(points_eval);
disp(['Off-point evaluation: ' num2str(toc)])
error = sum(V_op .^ 2);
disp(['Off-point error: ' num2str(error)])

% Off-point PU
tic
potential_op = rbfPU(train_data, train_data_w, @rbf, rbf_func, rbf_func, num_patches);
disp(['Off-point PU construction: ' num2str(toc)])
tic
V_op = potential_op(points_eval);
disp(['Off-point PU evaluation: ' num2str(toc)])
error = sum(V_op .^ 2);
disp(['Off-point PU error: ' num2str(error)])

%V_cf = reshape(V_cf, size(x));
%isosurface(x,y,z,V_cf, 0)

function H = supportHessianRBF(x, epsilon, m_esp)
    H = zeros([3 3 size(x, 1)]);
    r = sqrt(x(:,1).^2 + x(:,2).^2 + x(:,3).^2 + m_esp) ./ epsilon;
    
    dr = -20.*(1 - r).^3;
    dr2 = 60*(1 - r).^2./r;

    H(1, 1, :) = dr + x(:,1).^2 .* dr2;
    H(2, 2, :) = dr + x(:,2).^2 .* dr2;
    H(3, 3, :) = dr + x(:,3).^2 .* dr2;


    H(1, 2, :) = x(:,1).*x(:,2) .* dr2; 
    H(2, 1, :) = H(1, 2, :);

    H(1, 3, :) = x(:,1).*x(:,3) .* dr2; 
    H(3, 1, :) = H(1, 3, :);
    

    H(2, 3, :) = x(:,2).*x(:,3) .* dr2; 
    H(3, 2, :) = H(2, 3, :);
end