classdef Fuel
    %Fuel object
    
    % builds physical model for different fuel types
    properties (SetAccess = immutable)
        LHV {mustBePositive, mustBeFinite}
        density {mustBePositive, mustBeFinite}
    end
    
    methods
        function obj = Fuel(rho, lhv)
            % construct Fuel object
            obj.LHV = lhv;
            obj.density = rho;
        end
    end
end