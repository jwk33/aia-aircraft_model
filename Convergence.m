classdef Convergence
    % This class will be used to store convergence settings and information
    % about how well the solution converged.

    properties
        max_i (1,1) int8 {mustBePositive} = 50; % max iterations before code gives up
        conv_margin (1,1) double {mustBePositive} = 0.0001; % percentage delta in mtow
        TOW (1,:) double % list of TOW guesses on each iteration loop
        conv_err (1,1) double = 9999; % error between current and previous iteration
        conv_i (1,1) int8 % the number of iterations needed for solution to converge
        conv_bool logical = 0; % true or false: true if solution has converged
        
    end

    methods
        function obj = Convergence()
            % Create instance of convergence class. Defaults are set for
            % convergence margin and max number of iterations.
        end
    end
end