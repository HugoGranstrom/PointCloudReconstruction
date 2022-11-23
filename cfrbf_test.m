close all;
epsilon = 1;

%rbf = @(r) exp(-((epsilon .* r) .^ 2));
%rbfgrad = @(x) -2.*epsilon.*epsilon.*x .* rbf(norm2(x));
% rbfHessian = @(x) (gaussRbfHessian(x, epsilon));

dr = 1e-5;

sqrs = @(x) sqrt(dr + x(:,1).^2 + x(:,2).^2 + x(:,3).^2);

rbfgrad = @(x) 2 .* x .* (1 - epsilon./sqrs(x))./(epsilon.^2);
rbfHessian =  @(x) (supportHessianRBF(x, epsilon, dr));


% syms x y z;
% dr = 1e-5;
% r = sqrt(x*x + y*y + z*z + dr);
% %func = (1 - r ./ epsilon).^2 .* (4 * r / epsilon + 2);
% func = (1 - r ./ epsilon).^2;
% %func = exp(-((epsilon .* r) .^ 2));
% rbfgrad_f = matlabFunction(gradient(func), 'file', 'rbfgrad_file.m');
% rbfgrad = @(x) rbfgrad_file(x(:,1)', x(:,2)', x(:,3)')' .* (norm2(x) < epsilon);
% 
% rbfHessian_f = matlabFunction(hessian(func), 'file', 'rbfhessian_file.m');
% rbfHessian = @(x) rbfHessianHandler(x, rbfHessian_f) .* reshape((norm2(x) < epsilon), 1, 1, []);

N = 100;

%points = 2.*SpherePoints(N);
%normals = points;
load homer.mat
points = ptcloud;
% tic
% A = constructA(points, points, rbfHessian);
% toc
% f = flatten(normals');
% tic
% c = A \ f;
% toc

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

tic
[x,y,z] = meshgrid(min(points,[],'all'):0.003:max(points,[],'all'));
%potential = cfrbf(points, normals, rbfgrad, rbfHessian);
potential = rbfPU(points, normals, @cfrbf, rbfHessian, rbfgrad, 400, 0.05);
V = potential(horzcat(flatten(x), flatten(y), flatten(z)));
V = reshape(V, size(x));
toc
figure
hold on
s = isosurface(x,y,z,V, 0);
p = patch(s);
isonormals(x,y,z,V,p)
set(p,'FaceColor',[0.5 1 0.5]);  
set(p,'EdgeColor','none');
camlight('right', 'infinite');
daspect([1 1 1]);
view([90 0]);
axis off;
%scatter3(points(:,1), points(:,2), points(:,3))
%quiver3(points(:,1), points(:,2), points(:,3), normals(:, 1), normals(:, 2), normals(:, 3))
hold off

function H = gaussRbfHessian(x, epsilon)
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

function H = rbfHessianHandler(x, handle)
    H = zeros([3 3 size(x, 1)]);
    for i=1:size(x,1)
        H(:,:,i) = handle(x(i,1), x(i,2), x(i,3));
    end
end

function H = supportHessianRBF(x, epsilon, m_esp)
    H = zeros([3 3 size(x, 1)]);
    sqrs = x(:,1).^2 + x(:,2).^2 + x(:,3).^2 + m_esp;
    sqrs_rt = sqrt(sqrs);

    term = 2.*(1 - sqrs_rt./epsilon)./(sqrs_rt.*epsilon);
    term_2 = term./sqrs;

    H(1, 1, :) = (2.*x(:,1).^2) ./ (epsilon^2 .* sqrs) + x(:,1).^2 .* term_2 - term;
    H(2, 2, :) = (2.*x(:,2).^2) ./ (epsilon^2 .* sqrs) + x(:,2).^2 .* term_2 - term;
    H(3, 3, :) = (2.*x(:,3).^2) ./ (epsilon^2 .* sqrs) + x(:,3).^2 .* term_2 - term;


    H(1, 2, :) = x(:,1).*x(:,2) .*(2 ./ (epsilon^2 .* sqrs) + term_2); 
    H(2, 1, :) = H(1, 2, :);

    H(1, 3, :) = x(:,1).*x(:,3) .*(2 ./ (epsilon^2 .* sqrs) + term_2); 
    H(3, 1, :) = H(1, 3, :);
    

    H(2, 3, :) = x(:,2).*x(:,3) .*(2 ./ (epsilon^2 .* sqrs) + term_2); 
    H(3, 2, :) = H(2, 3, :);
end



