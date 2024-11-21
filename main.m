%{
    File: main.m
    Author: Zachary M Swanson
    Date: 11-20-2024
%}

% Define the fitness function
function z = fitness_func(x, y)
    z = (4 - 2.1 * x.^2 + x.^4/3) .* x.^2 + x.*y + (-4 + 4 * y.^2) .* y.^2;
end

min_x = -5;
max_x = 5;
min_y = -5;
max_y = 5;

min_threshold = 1e-6;
patience = 20;
max_iterations = 1000;

num_particles = 25;
v_max = 0.2 * (max_x - min_x);
accel_c1 = 1.5;
accel_c2 = 1.5;
inertia_w = 0.7;

rng(52);
swarm_obj = swarm(...
    num_particles, min_threshold, max_iterations, patience, accel_c1, ...
    accel_c2, inertia_w, v_max, max_x, max_y, min_x, min_y, @fitness_func);

[x, y, z, avg_z, max_z, iters] = swarm_obj.run();
first_min_iters = swarm_obj.iters_to_first_min();
fprintf('\nBest x: %f\n', x);
fprintf('Best y: %f\n', y);
fprintf('Best z: %f\n', z);
fprintf('Iterations: %d\n', iters);

% Write the results to a file using the following format:
% best_x,best_y,best_z,avg_z,max_z,iters,first_min_iters,n_particle,v_max, ...
% ... inertia_w,accel_c1,accel_c2
fileID = fopen('results.csv', 'a');
fprintf(fileID, '%f,%f,%f,%f,%f,%d,%d,%d,%f,%f,%f,%f\n', ...
    x, y, z, avg_z, max_z, iters, first_min_iters, num_particles, v_max, ...
    inertia_w, accel_c1, accel_c2);
fclose(fileID);

% Save the history to a file
filename = sprintf('histories/swarm_obj_%d_%.2f_%.2f_%.2f_%.2f.mat', ...
    num_particles, v_max, inertia_w, accel_c1, accel_c2);
save(filename, 'swarm_obj');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    Ablation Study    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

range_n_particles = 1:1:50;
range_v_max = (0:0.01:0.5) * (max_x - min_x);
range_inertia_w = 0:0.1:1.0;
range_accel_c1 = 0:0.5:2.0;
range_accel_c2 = 0:0.5:2.0;

disp('Running ablation study...');
disp('Starting number of particles study...');

for n = range_n_particles
    rng(52);
    swarm_obj = swarm(...
        n, min_threshold, max_iterations, patience, accel_c1, ...
        accel_c2, inertia_w, v_max, max_x, max_y, min_x, min_y, @fitness_func);

    [x, y, z, avg_z, max_z, iters] = swarm_obj.run();
    first_min_iters = swarm_obj.iters_to_first_min();

    fileID = fopen('results.csv', 'a');
    fprintf(fileID, '%f,%f,%f,%f,%f,%d,%d,%d,%f,%f,%f,%f\n', ...
        x, y, z, avg_z, max_z, iters, first_min_iters, n, v_max, ...
        inertia_w, accel_c1, accel_c2);
    fclose(fileID);
    

    filename = sprintf('histories/swarm_obj_%d_%.2f_%.2f_%.2f_%.2f.mat', ...
        n, v_max, inertia_w, accel_c1, accel_c2);
    save(filename, 'swarm_obj');
end

disp('Starting velocity limit study...');

for v = range_v_max
    rng(52);
    swarm_obj = swarm(...
        num_particles, min_threshold, max_iterations, patience, accel_c1, ...
        accel_c2, inertia_w, v, max_x, max_y, min_x, min_y, @fitness_func);

    [x, y, z, avg_z, max_z, iters] = swarm_obj.run();
    first_min_iters = swarm_obj.iters_to_first_min();

    fileID = fopen('results.csv', 'a');
    fprintf(fileID, '%f,%f,%f,%f,%f,%d,%d,%d,%f,%f,%f,%f\n', ...
        x, y, z, avg_z, max_z, iters, first_min_iters, num_particles, v, ...
        inertia_w, accel_c1, accel_c2);
    fclose(fileID);

    filename = sprintf('histories/swarm_obj_%d_%.2f_%.2f_%.2f_%.2f.mat', ...
        num_particles, v, inertia_w, accel_c1, accel_c2);
    save(filename, 'swarm_obj');
end

disp('Starting inertia_w study...');

for w = range_inertia_w
    rng(52);
    swarm_obj = swarm(...
        num_particles, min_threshold, max_iterations, patience, accel_c1, ...
        accel_c2, w, v_max, max_x, max_y, min_x, min_y, @fitness_func);

    [x, y, z, avg_z, max_z, iters] = swarm_obj.run();
    first_min_iters = swarm_obj.iters_to_first_min();

    fileID = fopen('results.csv', 'a');
    fprintf(fileID, '%f,%f,%f,%f,%f,%d,%d,%d,%f,%f,%f,%f\n', ...
        x, y, z, avg_z, max_z, iters, first_min_iters, num_particles, ...
        v_max, w, accel_c1, accel_c2);
    fclose(fileID);

    filename = sprintf('histories/swarm_obj_%d_%.2f_%.2f_%.2f_%.2f.mat', ...
        num_particles, v_max, w, accel_c1, accel_c2);
    save(filename, 'swarm_obj');
end

disp('Starting accel_c1 and accel_c2 study...');

for c1 = range_accel_c1
    for c2 = range_accel_c2
        if c1 == 0 && c2 == 0
            continue;
        end
        
        rng(52);
        swarm_obj = swarm(...
            num_particles, min_threshold, max_iterations, patience, c1, ...
            c2, inertia_w, v_max, max_x, max_y, min_x, min_y, @fitness_func);

        [x, y, z, avg_z, max_z, iters] = swarm_obj.run();
        first_min_iters = swarm_obj.iters_to_first_min();
    
        fileID = fopen('results.csv', 'a');
        fprintf(fileID, '%f,%f,%f,%f,%f,%d,%d,%d,%f,%f,%f,%f\n', ...
            x, y, z, avg_z, max_z, iters, first_min_iters, ...
            num_particles, v_max, inertia_w, c1, c2);
        fclose(fileID);

        filename = sprintf('histories/swarm_obj_%d_%.2f_%.2f_%.2f_%.2f.mat', ...
            num_particles, v_max, inertia_w, c1, c2);
        save(filename, 'swarm_obj');
    end
end
