function func = rbf(train_pos, train_val, rbf_func, rbf_grad)
    A = rbf_func(distanceMatrix(train_pos, train_pos));
    c = A \ train_val;
    
    func = @(eval_pos) rbf_func(distanceMatrix(train_pos, eval_pos)) * c;
end