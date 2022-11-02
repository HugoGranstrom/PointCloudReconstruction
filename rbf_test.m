testFunction = @(x,y) (0.75 * exp(-((9*x-2).^2 + (9*y - 2).^2)/4) + 0.75 * exp(-((9*x+1).^2/49 + (9*y - 2).^2/10)) + 0.5 * exp(-((9*x-7).^2 + (9*y - 3).^2)/4) + 0.2 * exp(-((9*x-4).^2 + (9*y - 7).^2)));

epsilon = 21;
rbf_func1 = @(r) exp(-((epsilon*r).^2));

N_train = 1000;
N_test = 50;

data = rand(N_train, 2);

test_x = linspace(0, 1, N_test);
test_y = linspace(0, 1, N_test);
[test_X, test_Y] = meshgrid(test_x, test_y);
x_test = reshape(test_X, [N_test^2 1]);
y_test = reshape(test_Y, [N_test^2 1]);

f_data = testFunction(data(:, 1), data(:, 2));
f_test = testFunction(x_test, y_test);
data_test = horzcat(x_test, y_test);

pred = rbf(data, f_data, data_test, rbf_func1);

surf(test_X, test_Y, reshape(pred, [N_test N_test]))
figure;
surf(test_X, test_Y, reshape(f_test, [N_test N_test]));
error = mean((pred - f_test).^2)

