function pred = rbf(train_pos, train_val, eval_pos, rbf_func)
    A = rbf_func(distanceMatrix(train_pos, train_pos));
    c = A \ train_val;
    
    A_eval = rbf_func(distanceMatrix(train_pos, eval_pos));
    pred = A_eval * c;
end