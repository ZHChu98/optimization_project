classdef ifc < handle
    properties
        weight;
        bias;
        input; % storing input required during backpropagation
    end
    
    methods
        % initialization
        function obj = ifc(n_input, n_output)
            obj.weight = 0.01 + 0.01*randn(n_input, n_output);
            obj.bias = 0.01 + 0.01*randn(1, n_output);
        end
        
        % forward propagation
        function y = forward(obj, x)
            obj.input = x;
            y = x * obj.weight + obj.bias;
        end
        
        % backpropagation
        function delta_x = backward(obj, delta_y, learning_rate)
            % errors of input
            delta_x = delta_y * obj.weight';
            
            % errors of bias
            delta_b = sum(delta_y, 1);
            obj.bias = obj.bias - delta_b * learning_rate;
            
            % errors of weight
            delta_W = obj.input' * delta_y;
            obj.weight = obj.weight - delta_W * learning_rate;
        end
    end
end

