% Define the fitness function
function z = fitness_func(x, y)
    z = (4 - 2.1 * x.^2 + x.^4/3) .* x.^2 + x.*y + (-4 + 4 * y.^2) .* y.^2;
end

% plot the fitness function
[X, Y] = meshgrid(-2:0.1:2, -1:0.1:1);
% [X, Y] = meshgrid(-5:0.1:5, -5:0.1:5);
Z = fitness_func(X, Y);
figure;
surf(X, Y, Z);
xlabel('x');
ylabel('y');
zlabel('f(x, y)');
title('Fitness Function');
colorbar;



% % Create an animation of the swarm's progress
% history = swarm_obj.history;
% num_iterations = size(history, 1);
% num_particles = size(history, 2);


% [X, Y] = meshgrid(-5:0.01:5, -5:0.01:5);
% Z = fitness_func(X, Y);
% figure;
% imagesc(-5:0.01:5, -5:0.01:5, Z);
% hold on;
% for i = 1:num_particles
%     for j = 2:20:num_iterations
%         plot(history(j-1:j, i, 1), history(j-1:j, i, 2), 'r', 'LineWidth', 1.5);
%         pause(0.001);
%     end
% end
% hold off;
% xlabel('x');
% ylabel('y');
% title('Fitness Function');
% colorbar;
