classdef Atmosphere
    %Atmosphere object
    
    % define atmosphere for flight
    properties (SetAccess = immutable)
        temp
        density
    end
    
    methods
        function obj = Atmosphere(T, rho)
            obj.temp = T;
            obj.density = rho;
        end
    end
end