function [patches, indices_list] = constructPatches(train_pos, N, rho)
%     min_x = min(min(train_pos(:,1)));
%     min_y = min(min(train_pos(:,2)));
%     max_x = max(max(train_pos(:,1)));
%     max_y = max(max(train_pos(:,2)));
%     if (size(train_pos, 2) == 2)
%         [X, Y] = meshgrid(linspace(min_x, max_x, N), linspace(min_y, max_y, N));
%         grid = horzcat(reshape(X,[], 1), reshape(Y ,[],1));
%     else 
%         max_z = max(max(train_pos(:,3)));
%         min_z = min(min(train_pos(:,3)));
%         [X, Y, Z] = meshgrid(linspace(min_x, max_x, N), linspace(min_y, max_y, N), linspace(min_z, max_z, N));
%         grid = horzcat(reshape(X, [], 1), reshape(Y, [],1), reshape(Z, [], 1));
%     end
    grid = mex_pcCoarsenPoissonDisk(train_pos, N);
    real_index_list = [];
    indices_list = {};
    currentIndex = 1;
    for i=1:size(grid, 1)
        indices = find(norm2(train_pos - grid(i,:)) <= rho);
        if (numel(indices) > 0)
            indices_list{currentIndex} = indices;
            currentIndex = currentIndex + 1;
            real_index_list = [real_index_list i];
        end
    end
    patches = grid(real_index_list, :);
%     scatter(patches(:,1), patches(:, 2))
%     hold on
%     scatter(train_pos(:,1), train_pos(:,2))
%     hold off
%     legend("Patches","Points")
%     title(['Original: ' num2str(length(grid)) ' Kept: ' num2str(length(patches))])
end