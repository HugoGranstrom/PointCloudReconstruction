epsilon = 10;
rbf = @(r) exp(-((epsilon .* r) .^ 2));
rbfgrad = @(x) -2*epsilon*epsilon*x .* rbf(norm2(x));

N = 1000;

points = SpherePoints(N);
A = constructA(points, points, epsilon);
f = flatten(points);
c = A \ f

points_test = SpherePoints(2000);
A_test = constructA(points, points_test, epsilon);
f_test = A_test * c;
error = mean(abs(f_test - flatten(points_test)), 'all')
p_test = reshape(f_test, [], 3);
%sum(p_test .* points_test, 2)
quiver3(points_test(:,1), points_test(:,2), points_test(:,3), p_test(:,1), p_test(:,2), p_test(:,3))


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