function func = cfrbf(x_train, y_train, rbfHessian, rbf_grad)
    A = constructA(x_train, x_train, rbfHessian);
    f = flatten(y_train');
    c = A \ f;

    function v = evalCFRBF(x)
        v = zeros(size(x, 1), 1);
        v_rbf = zeros(size(x_train,1),1);
        for i = 1:size(x_train, 1)
            v = v - rbf_grad(x - x_train(i,:)) * c((i-1)*3 + 1:i*3);
            v_rbf = v_rbf - rbf_grad(x_train - x_train(i,:)) * c((i-1)*3 + 1:i*3);
        end
        v = v - mean(v_rbf, 'all');
    end

    func = @evalCFRBF;

end