classdef Material
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name string                                                           % material name
        type string                                                           % type (structural/insulator)
        density(1,1) double {mustBeNonnegative, mustBeFinite}                 % kg/m3
        yield_strength(1,1) double {mustBeNonnegative, mustBeFinite}          % MPa
        thermal_conductivity(1,1) double {mustBeNonnegative, mustBeFinite}    % W / m K
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

