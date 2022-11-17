epsilon = 5;
rbf = @(r) exp(-((epsilon .* r) .^ 2));
rbfgrad = @(x) -2.*epsilon.*epsilon.*x .* rbf(norm2(x));

N = 100;

points = 2.*SpherePoints(N);
normals = points;
%load homer.mat
%points = ptcloud;
tic
A = constructA(points, points, epsilon);
f = flatten(normals');
c = A \ f;
toc

% points_test = 2.*SpherePoints(100);
% A_test = constructA(points, points_test, epsilon);
% f_test = A_test * c;
% error = mean(abs(f_test - flatten(points_test')), 'all')
% p_test = [f_test(1:3:end) f_test(2:3:end) f_test(3:3:end)];
% %sum(p_test .* points_test, 2)
% close all
% quiver3(points_test(:,1), points_test(:,2), points_test(:,3), points_test(:,1), points_test(:,2), points_test(:,3))
% figure
% quiver3(points_test(:,1), points_test(:,2), points_test(:,3), p_test(:,1), p_test(:,2), p_test(:,3))
% %scatter3(points(:,1), points(:,2), points(:,3))

figure
tic
[x,y,z] = meshgrid(min(points,[],'all'):0.01:max(points,[],'all'));
V = evalCFRBF(horzcat(flatten(x), flatten(y), flatten(z)), points, c, rbfgrad);
V = reshape(V, size(x));
toc
hold on
isosurface(x,y,z,V, 0);
scatter3(points(:,1), points(:,2), points(:,3))
hold off

function H = rbfHessian(x, epsilon)
    H = zeros([3 3 size(x, 1)]);
    ex = exp(-((epsilon * norm2(x)).^2));
    H(1, 1, :) = epsilon^4 * x(:,1).^2 .* ex - 1/2 * epsilon^2 * ex;
    H(2, 2, :) = epsilon^4 * x(:,2).^2 .* ex - 1/2 * epsilon^2 * ex;
    H(3, 3, :) = epsilon^4 * x(:,3).^2 .* ex - 1/2 * epsilon^2 * ex;


    H(1, 2, :) = x(:,1) .* x(:,2) .* epsilon^4 .* ex;
    H(2, 1, :) = H(1, 2, :);

    H(1, 3, :) = x(:,1) .* x(:,3) .* epsilon^4 .* ex;
    H(3, 1, :) = H(1, 3, :);
    

    H(2, 3, :) = x(:,2) .* x(:,3) .* epsilon^4 .* ex;
    H(3, 2, :) = H(2, 3, :);

    H = H.*4;
end

function A = constructA(x_train, x_eval, epsilon)
    n_train = size(x_train, 1);
    n_eval = size(x_eval, 1);
    A = zeros([3*n_eval 3*n_train]);
    for i=1:n_eval
        H = rbfHessian(x_eval(i,:) - x_train, epsilon);
        A((i-1)*3 + 1 : (i-1)*3 + 3, :) = reshape(H, [3 3*n_train]);
        %for j=1:n
        %    A((i-1)*3 + 1 : (i-1)*3 + 3, (j-1)*3 + 1 : (j-1)*3 + 3) = H(j, :, :);
        %end
    end
end

function v = evalCFRBF(x, rbf_pos, c, rbf_grad)
    v = zeros(size(x, 1), 1);
    v_rbf = zeros(size(rbf_pos,1),1);
    for i = 1:size(rbf_pos, 1)
        v = v - rbf_grad(x - rbf_pos(i,:)) * c((i-1)*3 + 1:i*3);
        v_rbf = v_rbf - rbf_grad(rbf_pos - rbf_pos(i,:)) * c((i-1)*3 + 1:i*3);
    end
    v = v - mean(v_rbf, 'all');
end