function func = rbfPU(train_pos, train_val, rbf_func, N, rho)
    [patches, patch_indc] = constructPatches(train_pos, N, rho);
    s_js = cell(size(patches,1), 1);
    size(patches,1)
    for i=1:size(patches, 1)
        s_js{i} = rbf(train_pos(patch_indc{i}, :), train_val(patch_indc{i}), rbf_func);
    end
    
    function v = evalRbfPU(x)
        w_func = @(r) (1 - r ./ rho).^2 .* (r < rho) .* (4 * r / rho + 2);
        v = zeros(size(x,1),1);
        tree = KDTreeSearcher(x);
        tic
        points_in_patches = rangesearch(tree,patches,rho);
        toc
        w = zeros(size(x,1),1);
        y = zeros(size(x,1),1);
        is_set = false(size(x,1),1);
        tic
        for j=1:size(patches, 1)
            is_set(points_in_patches{j}) = 1;
            points = x(points_in_patches{j},:);
            dist = norm2(patches(j,:) - points);
            w_val = w_func(dist);
            w(points_in_patches{j}) = w(points_in_patches{j}) + w_val;
            s_j = s_js{j};
            y_j = s_j(points); % (n_x, 1)
            y(points_in_patches{j}) = y(points_in_patches{j}) + w_val .* y_j;
        end
        toc
        v(~is_set) = NaN;
        v(is_set) = y(is_set) ./ w(is_set);
    end
    func = @evalRbfPU;
end