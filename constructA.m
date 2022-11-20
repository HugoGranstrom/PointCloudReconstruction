function A = constructA(x_train, x_eval, rbfHessian)
    n_train = size(x_train, 1);
    n_eval = size(x_eval, 1);
    A = zeros([3*n_eval 3*n_train]);
    for i=1:n_eval
        H = rbfHessian(x_eval(i,:) - x_train);
        A((i-1)*3 + 1 : (i-1)*3 + 3, :) = reshape(H, [3 3*n_train]);
    end
end