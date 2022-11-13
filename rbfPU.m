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
        dist = distanceMatrix(patches, x); % shape (n_x, n_patches) so each row is for one x-point
        isClose = dist <= rho;
        wAll = w_func(dist);
        wAll = wAll ./ sum(wAll, 2);
        for j=1:size(patches, 1)
            active_points = isClose(:,j);
            % sum(active_points) / length(active_points)
            w = wAll(active_points, j); %w_func(dist(active_points,j));
            x_ = x(active_points,:);
            s_j = s_js{j};
            y_j = s_j(x_); % (n_x, 1)
            v(active_points) = v(active_points) + y_j .* w;
        end
        % set empty sets to nan;
        isnan = ~sum(isClose, 2);
        v(isnan) = nan;



    end
    func = @evalRbfPU;
end