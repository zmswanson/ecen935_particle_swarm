%{
    File: swarm.m
    Author: Zachary M Swanson
    Date: 11-20-2024
    Description: This file contains the swarm class which is used to implement
    the particle swarm optimization algorithm. The swarm class is used to
    initialize a swarm of particles and run the optimization algorithm to find
    the minimum value of a given fitness function.
%}

classdef swarm < handle
    properties
        num_particles
        particles
        gbest_x
        gbest_y
        gbest_val
        threshold
        num_iterations
        patience
        accel_c1
        accel_c2
        inertia_w
        max_vel
        max_x
        max_y
        min_x
        min_y
        fitness_func
        history
    end

    methods
        function obj = swarm(num_particles, threshold, num_iters, patience, ...
                accel_c1, accel_c2, inertia_w, max_vel, max_x, max_y, ...
                min_x, min_y, fitness_func)
            obj.num_particles = num_particles;
            obj.threshold = threshold;
            obj.num_iterations = num_iters;
            obj.patience = patience;
            obj.accel_c1 = accel_c1;
            obj.accel_c2 = accel_c2;
            obj.inertia_w = inertia_w;
            obj.max_vel = max_vel;
            obj.max_x = max_x;
            obj.max_y = max_y;
            obj.min_x = min_x;
            obj.min_y = min_y;
            obj.fitness_func = fitness_func;

            obj.history = zeros(num_iters, num_particles, 3);

            obj.particles = particle.empty(obj.num_particles, 0);
            for i = 1:obj.num_particles
                % Randomly initialize the position and velocity of the particle
                % within the bounds of the search space
                pos_x = rand() * (obj.max_x - obj.min_x) + obj.min_x;
                pos_y = rand() * (obj.max_y - obj.min_y) + obj.min_y;
                vel_x = 0;
                vel_y = 0;
                obj.particles(i) = particle(pos_x, pos_y, vel_x, vel_y, ...
                    obj.fitness_func, obj.threshold);

                obj.history(1, i, 1) = pos_x;
                obj.history(1, i, 2) = pos_y;
                obj.history(1, i, 3) = obj.particles(i).crnt_val;

                % Update the global best position based on the initial positions
                if i == 1
                    obj.gbest_x = obj.particles(i).pos_x;
                    obj.gbest_y = obj.particles(i).pos_y;
                    obj.gbest_val = obj.particles(i).best_val;
                else
                    if obj.particles(i).best_val < obj.gbest_val
                        obj.gbest_x = obj.particles(i).pos_x;
                        obj.gbest_y = obj.particles(i).pos_y;
                        obj.gbest_val = obj.particles(i).best_val;
                    end
                end
            end
        end

        function [x, y, val, avg_z, max_z, iters] = run(obj)
            iters = 0;

            for i = 1:obj.num_iterations
                no_progress = true;

                % Loop through each particle and update its position
                for j = 1:obj.num_particles
                    obj.particles(j).update(obj.accel_c1, ...
                        obj.accel_c2, obj.inertia_w, obj.gbest_x, ...
                        obj.gbest_y, obj.max_x, obj.max_y, obj.min_x, ...
                        obj.min_y, obj.max_vel);

                    % Update the current value of the particle in the history
                    % matrix for later analysis
                    obj.history(i, j, 1) = obj.particles(j).pos_x;
                    obj.history(i, j, 2) = obj.particles(j).pos_y;
                    obj.history(i, j, 3) = obj.particles(j).crnt_val;
                end

                % Loop through each particle and update the global best position
                for j = 1:obj.num_particles
                    if obj.particles(j).best_val < obj.gbest_val
                        obj.gbest_x = obj.particles(j).pos_x;
                        obj.gbest_y = obj.particles(j).pos_y;
                        obj.gbest_val = obj.particles(j).best_val;
                    end

                    % Check if the particle has made progress within the
                    % last patience iterations
                    if obj.particles(j).no_progress_count < obj.patience
                        no_progress = false;
                    end
                end

                % if no particle has made progress within the last patience
                % iterations, break out of the loop... we're assuming that
                % all particles have converged to some minimum
                if no_progress
                    iters = i;
                    break;
                end
            end

            x = obj.gbest_x;
            y = obj.gbest_y;
            val = obj.gbest_val;

            if iters == 0
                iters = obj.num_iterations;
            end

            avg_z = 0;
            max_z = 0;

            for i = 1:obj.num_particles
                avg_z = avg_z + obj.particles(i).crnt_val;
                if i == 1
                    max_z = obj.particles(i).crnt_val;
                else
                    if obj.particles(i).crnt_val > max_z
                        max_z = obj.particles(i).crnt_val;
                    end
                end
            end

            avg_z = avg_z / obj.num_particles;
        end

        % Helper function to find the iteration at which the first minimum
        % value was found based on the history of the swarm
        function iters = iters_to_first_min(obj)
            % find the minimum value in the history
            min_val = obj.history(1, 1, 3);
            min_i = 0;

            for i = 1:obj.num_iterations
                for j = 1:obj.num_particles
                    if obj.history(i, j, 3) < min_val
                        min_val = obj.history(i, j, 3);
                    end
                end
            end

            if min_val < 0
                min_val = 0.9999 * min_val;
            elseif min_val > 0
                min_val = 1.0001 * min_val;
            end

            iter_found = false;

            for i = 1:obj.num_iterations
                for j = 1:obj.num_particles
                    if obj.history(i, j, 3) <= min_val
                        min_i = i;
                        iter_found = true;
                        break;
                    end
                end

                if iter_found
                    break;
                end
            end

            iters = min_i;
        end
    end
end