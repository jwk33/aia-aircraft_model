classdef Fuel
    %Fuel object
    
    % builds physical model for different fuel types
    properties (SetAccess = immutable)
        name(1,:) string
        lhv(1,1) double {mustBeNonnegative, mustBeFinite}
        density(1,1) double {mustBeNonnegative, mustBeFinite}
        T(1,1) double % fuel storage temperature. Needed if tank is designed
        specific_CO2 (1,1) double % kgCO2/kg fuel for combustion
        UseTankModel logical 
    end
    
    methods
        function obj = Fuel(name, lhv, density, specific_CO2, temperature, UseTankModel)
            % construct Fuel object
            arguments
                name(1,:) char
                lhv (1,1) double
                density (1,1) double
                specific_CO2 (1,1) double
                temperature (1,1) double = NaN
                UseTankModel logical = 0
            end
            obj.name = name;
            obj.lhv = lhv;
            obj.density = density;
            obj.specific_CO2 = specific_CO2;
            obj.T = temperature;
            obj.UseTankModel = UseTankModel;
        end
    end
end