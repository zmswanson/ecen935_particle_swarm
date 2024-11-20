classdef progress_bar < handle
    properties
        completed_steps
        remaining_steps
        progress
        message
        msg_len
    end

    methods
        function obj = progress_bar()
            obj.completed_steps = 0;
            obj.remaining_steps = 25;
            obj.progress = 0;

            obj.message = sprintf('[>%s]', repmat(' ', 1, 25));
            obj.msg_len = length(obj.message);
            fprintf(obj.message);
        end

        function update(obj, i, total_steps, extra_float)
            n_steps = total_steps / 25;
            if mod(i, n_steps) == 0 || i == total_steps
                obj.progress = i / total_steps * 100;
                obj.completed_steps = floor(i / total_steps * 25);
                obj.remaining_steps = 25 - obj.completed_steps;

                fprintf(repmat('\b', 1, obj.msg_len));

                obj.message = sprintf('[%s%d>%s] Val=%.2f', ...
                    repmat('=', 1, obj.completed_steps), ...
                    round(obj.progress), ...
                    repmat(' ', 1, obj.remaining_steps), ...
                    extra_float);
                
                obj.msg_len = length(obj.message);

                fprintf(obj.message);
                drawnow;
            end

            if i == total_steps
                fprintf('\n');
            end
        end
    end
end