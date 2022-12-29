function [func, c] = rbfBatched(train_pos, train_val, rbf_func, rbf_grad)
    A = rbf_func(distanceMatrix(train_pos, train_pos));
    c = A \ train_val;
    
    function v = evalRbf(eval_pos)
        n_eval = size(eval_pos, 1);
        v = zeros(n_eval, 1);
        grain = 8192;
        for i = 0 : int64(n_eval / grain) - 1
            batch_size = min(n_eval - i*grain, grain);
            v(i*grain+1 : i*grain+batch_size,:) = rbf_func(distanceMatrix(train_pos, eval_pos(i*grain+1:i*grain+batch_size,:))) * c;
        end
    end
    func = @(eval_pos) rbf_func(distanceMatrix(train_pos, eval_pos)) * c;
    func = @evalRbf;
end