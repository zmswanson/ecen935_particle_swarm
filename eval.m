% load swarm obj
load("histories\swarm_obj_25_2.00_0.70_1.50_1.50.mat");

for i = 1:swarm_obj.num_particles
    disp(swarm_obj.particles(i).crnt_val);
end
