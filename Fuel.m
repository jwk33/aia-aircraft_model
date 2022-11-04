classdef Fuel
    %Fuel object
    
    % builds physical model for different fuel types
    properties (SetAccess = immutable)
        name(1,:) char
        lhv(1,1) double {mustBeNonnegative, mustBeFinite}
        density(1,1) double {mustBeNonnegative, mustBeFinite}
        UseTankModel logical
    end
    
    methods
        function obj = Fuel(name, lhv, density, UseTankModel)
            % construct Fuel object
            obj.name = name;
            obj.lhv = lhv;
            obj.density = density;
            obj.UseTankModel = UseTankModel;
        end
    end
end