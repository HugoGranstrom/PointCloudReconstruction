epsilon = 1;
rbf_func = @(r) (1 - r ./ epsilon).^4 .* (r < epsilon) .* (4 * r / epsilon + 1);

[X, Y] = meshgrid(linspace(-1, 1));

Z = rbf_func(sqrt(X .^ 2 + Y .^ 2));

p = surf(Z);
axis off;
colormap default
set(p,'EdgeColor','none');
% % set(gca,'xtick',[])
% set(gca,'xticklabel',[])
% % set(gca,'ytick',[])
% set(gca,'yticklabel',[])
% % set(gca,'ztick',[])
% set(gca,'zticklabel',[])
