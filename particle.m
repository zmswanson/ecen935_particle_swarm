%{
    File: particle.m
    Author: Zachary M Swanson
    Date: 11-20-2024
    Description: This file contains the particle class which is used to represent
    a particle in the particle swarm optimization algorithm. The particle class
    contains properties for the position, velocity, fitness function, and best
    position of the particle. It also contains methods to update the particle's
    position and velocity based on the particle swarm optimization algorithm.
%}

classdef particle < handle
    properties
        pos_x
        pos_y
        vel_x
        vel_y
        fitness_func
        best_pos_x
        best_pos_y
        best_val
        crnt_val
        no_progress_count
        threshold
    end

    methods
        function obj = particle(pos_x, pos_y, vel_x, vel_y, fit_fn, threshold)
            obj.pos_x = pos_x;
            obj.pos_y = pos_y;
            obj.vel_x = vel_x;
            obj.vel_y = vel_y;

            obj.best_pos_x = pos_x;
            obj.best_pos_y = pos_y;

            % Evaluate the fitness function at the initial position to get the
            % initial p_best value
            obj.fitness_func = fit_fn;
            obj.crnt_val = obj.fitness_func(obj.pos_x, obj.pos_y);
            obj.best_val = obj.crnt_val;

            obj.no_progress_count = 0;
            obj.threshold = threshold;
        end

        % Update the particle's position and velocity based on the PSO algorithm
        function [x, y] = update(obj, c1, c2, w, gbest_x, gbest_y, ...
                max_x, max_y, min_x, min_y, max_vel)
            phi_1 = rand();
            phi_2 = rand();

            inertia_x = w * obj.vel_x;
            inertia_y = w * obj.vel_y;

            cognitive_x = c1 * phi_1 * (obj.best_pos_x - obj.pos_x);
            cognitive_y = c1 * phi_1 * (obj.best_pos_y - obj.pos_y);

            social_x = c2 * phi_2 * (gbest_x - obj.pos_x);
            social_y = c2 * phi_2 * (gbest_y - obj.pos_y);

            % Combine the three components to get the new velocity
            obj.vel_x = inertia_x + cognitive_x + social_x;
            obj.vel_y = inertia_y + cognitive_y + social_y;

            % Limit the velocity if necessary
            if max_vel > 0
                if obj.vel_x > max_vel
                    obj.vel_x = max_vel;
                elseif obj.vel_x < -max_vel
                    obj.vel_x = -max_vel;
                end

                if obj.vel_y > max_vel
                    obj.vel_y = max_vel;
                elseif obj.vel_y < -max_vel
                    obj.vel_y = -max_vel;
                end
            end

            % Update the particle's position
            obj.pos_x = obj.pos_x + obj.vel_x;
            obj.pos_y = obj.pos_y + obj.vel_y;
            
            % Ensure the particle stays within the search space
            if obj.pos_x > max_x
                obj.pos_x = max_x;
            elseif obj.pos_x < min_x
                obj.pos_x = min_x;
            end

            if obj.pos_y > max_y
                obj.pos_y = max_y;
            elseif obj.pos_y < min_y
                obj.pos_y = min_y;
            end

            % Evaluate the new position with the fitness function
            val = obj.fitness_func(obj.pos_x, obj.pos_y);

            % Update the best position if necessary
            if val < obj.best_val
                obj.best_val = val;
                obj.best_pos_x = obj.pos_x;
                obj.best_pos_y = obj.pos_y;
            end

            % Check for progress
            if abs(val - obj.crnt_val) < obj.threshold
                obj.no_progress_count = obj.no_progress_count + 1;
            else
                obj.no_progress_count = 0;
            end

            obj.crnt_val = val;

            x = obj.pos_x;
            y = obj.pos_y;
        end
    end
end