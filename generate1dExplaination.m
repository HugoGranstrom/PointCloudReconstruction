close all;

x = linspace(0, 1.2, 100);

f = @(x) sin(2*pi*x);
epsilon = 0.75;
compactRbf = @(r) (1 - r/epsilon) .^ 4 .* (4*r/epsilon + 1) .* (r < epsilon);
y = f(x);

figure;
plot(x, y, 'g-')
hold on;

nSample = 5;
xSample = linspace(0.1, 0.9, nSample);
ySample = f(xSample);
scatter(xSample, ySample, 'r*')
% 
% for xs=xSample
%     ys = compactRbf(abs(x - xs));
%     plot(x, ys, '--m')
% end
% 
[potential, c] = rbf(xSample', ySample', compactRbf, compactRbf);

% for i=1:length(xSample)
%     ys = c(i) * compactRbf(abs(x - xSample(i)));
%     plot(x, ys, '--m')
% end


yEval = potential(x')';

plot(x, yEval, '-b')

hold off;

figure;
plot(x, compactRbf(abs(0 - x)))
xlabel('r')
ylabel('\phi(r)')