close all
func = @(x,y) 3*(1-x).^2.*exp(-(x.^2) - (y+1).^2) ... 
   - 10*(x/5 - x.^3 - y.^5).*exp(-x.^2-y.^2) ... 
   - 1/3*exp(-(x+1).^2 - y.^2);

[x,y] = meshgrid(-3:1:3, -3:1:3);

z = func(x,y);

surf(x,y,z)
hold on
scatter3(x,y,z, 100, 'red', 'x')
hold off
view(-45,45)
title("Triangulation of 49 points")


figure
dr = 1e-15;
epsilon = 100;
rbf_func = @(r) (1 - r ./ epsilon).^4 .* (r < epsilon) .* (4 * r / epsilon + 1);

ifunc = rbf(horzcat(flatten(x), flatten(y)), flatten(z), rbf_func, '');

% Eval:
[x_, y_] = meshgrid(-3:0.01:3, -3:0.01:3);

z_ = ifunc(horzcat(flatten(x_), flatten(y_)));

z_ = reshape(z_, size(x_));

surf(x_, y_, z_)
shading interp
hold on
scatter3(x,y,z, 100, 'red', 'x')
hold off
view(45,45)
title("RBF Interpolation of 49 points")

figure
surf(x_, y_, func(x_, y_))
shading interp
hold on
scatter3(x,y,z, 100, 'red', 'x')
hold off
view(45,45)
title("Original function")

