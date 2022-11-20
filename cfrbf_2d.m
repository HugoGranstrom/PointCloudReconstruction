close all;

[X_, Y_] = meshgrid(0:0.05:1);

X = flatten(X_);
Y = flatten(Y_);

X_test = X(1:2:end);
Y_test = Y(1:2:end);

X = X(2:2:end);
Y = Y(2:2:end);


U = 2*X + Y.^2;
V = X.^2 + 2*Y;

quiver(X, Y, U, V);

epsilon = 5;

A = constructA([X Y], [X Y], epsilon);
c = A \ flatten([U V]');

A_test = constructA([X Y], [X_test Y_test], epsilon);
f_test = A_test * c;
f_test = [f_test(1:2:end) f_test(2:2:end)];
figure
quiver(X_test,Y_test, -f_test(:,1), -f_test(:,2))

[X, Y] = meshgrid(-1:0.1:1);

x = flatten(X);
y = flatten(Y);

A = constructA([0 0], [x y], 5);



function H = rbfHessian(x, epsilon)
    H = zeros([2 2 size(x, 1)]);
    ex = exp(-((epsilon * norm2(x)).^2));
    H(1, 1, :) = epsilon^4 * x(:,1).^2 .* ex - 1/2 * epsilon^2 * ex;
    H(2, 2, :) = epsilon^4 * x(:,2).^2 .* ex - 1/2 * epsilon^2 * ex;
    
    H(1, 2, :) = x(:,1) .* x(:,2) .* epsilon^4 .* ex;
    H(2, 1, :) = H(1, 2, :);

    H = H.*4;
end

function A = constructA(x_train, x_eval, epsilon)
    n_train = size(x_train, 1);
    n_eval = size(x_eval, 1);
    A = zeros([2*n_eval 2*n_train]);
    for i=1:n_eval
        H = rbfHessian(x_train - x_eval(i,:), epsilon);
        A((i-1)*2 + 1 : (i-1)*2 + 2, :) = reshape(H, [2 2*n_train]);
    end
end