classdef Material
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name                    % material name
        type                    % type (structural/insulator)
        density                 % kg/m3
        yield_strength          % MPa
        thermal_conductivity    % W / m K
    end
    
    methods
        function obj = Material(name,type,density,yield_strength,thermal_conductivity)
            % construct Fuel object
            obj.name = name;
            obj.type = type;
            obj.density = density;
            obj.yield_strength = yield_strength;
            obj.thermal_conductivity = thermal_conductivity;
        end
    end    
end

