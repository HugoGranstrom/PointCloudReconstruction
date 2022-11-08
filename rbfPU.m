function func = rbfPU(train_pos, train_val, rbf_func, N, rho)
    [patches, patch_indc] = constructPatches(train_pos, N, rho);
    s_js = cell(size(patches,1), 1);
    for i=1:size(patches, 1)
        s_js{i} = rbf(train_pos(patch_indc{i}, :), train_val(patch_indc{i}), rbf_func);
    end
    
    function v = evalRbfPU(x)
        w_func = @(r) (1 - r ./ rho).^2 .* (r < rho) .* (4 * r / rho + 2);
        v = zeros(size(x,1),1);
        for k=1:size(x,1)
            x_ = x(k,:);
            
            active_patches = norm2(patches - x_) <= rho;
            active_patches_idx = find(active_patches);
            if(isempty(active_patches_idx))
                v(k) = nan;
            else
                w = w_func(norm2(patches(active_patches, :) - x_));
                w = w ./ sum(w); % Normalize w
                v(k) = 0;
                for jk=1:length(active_patches_idx)
                    j = active_patches_idx(jk);
                    s_j = s_js{j};
                    w_j = w(jk);
                    v(k) = v(k) + s_j(x_).*w_j;
                end
            end
        end
    end
    func = @evalRbfPU;
end