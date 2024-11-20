%{
    File: swarm.m
    Author: Zachary M Swanson
    Date: 11-20-2024
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
        % pbar
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

            obj.history = zeros(num_iters, num_particles, 2);

            obj.particles = particle.empty(obj.num_particles, 0);
            for i = 1:obj.num_particles
                pos_x = rand() * (obj.max_x - obj.min_x) + obj.min_x;
                pos_y = rand() * (obj.max_y - obj.min_y) + obj.min_y;
                vel_x = 0;
                vel_y = 0;
                obj.particles(i) = ...
                    particle(pos_x, pos_y, vel_x, vel_y, obj.fitness_func);

                obj.history(1, i, 1) = pos_x;
                obj.history(1, i, 2) = pos_y;

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

        function [x, y, val, iters] = run(obj)
            iters = 0;
            prev_best_val = obj.gbest_val;
            no_progress_count = 0;

            % obj.pbar = progress_bar();
            for i = 1:obj.num_iterations
                % obj.pbar.update(i, obj.num_iterations, obj.gbest_val);
                for j = 1:obj.num_particles
                    obj.particles(j).update(obj.accel_c1, ...
                        obj.accel_c2, obj.inertia_w, obj.gbest_x, ...
                        obj.gbest_y, obj.max_x, obj.max_y, obj.min_x, ...
                        obj.min_y, obj.max_vel);

                    obj.history(i, j, 1) = obj.particles(j).pos_x;
                    obj.history(i, j, 2) = obj.particles(j).pos_y;
                end

                for j = 1:obj.num_particles
                    if obj.particles(j).best_val < obj.gbest_val
                        obj.gbest_x = obj.particles(j).pos_x;
                        obj.gbest_y = obj.particles(j).pos_y;
                        obj.gbest_val = obj.particles(j).best_val;
                    end
                end

                if (prev_best_val - obj.gbest_val) > obj.threshold
                    prev_best_val = obj.gbest_val;
                    no_progress_count = 0;
                else
                    no_progress_count = no_progress_count + 1;

                    if no_progress_count >= obj.patience
                        iters = i;
                        break;
                    end
                end
            end

            x = obj.gbest_x;
            y = obj.gbest_y;
            val = obj.gbest_val;

            if iters == 0
                iters = obj.num_iterations;
            end
        end
    end
end