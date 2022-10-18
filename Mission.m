classdef Mission
    %Mission object
    
    % define flight properties for a given aircraft
    properties
        passenger
        cargo
        payload_total
        range
        mach
        cruise_alt
        cruise_speed %m/s
        angle_TO %degrees
        mission_fuel
        reserve_fuel
        energy
        emissions
        
        
    end
    methods
        function obj = Mission(M, cruise_alt, aircraft, atmosphere)
            obj.mach = M;
            obj.cruise_alt = cruise_alt;
            obj.aircraft = aircraft;
            obj.atmosphere = atmosphere;
        end
%         function emissions(obj)
%             ...
%         end
%         function fuelUsage(obj)
%             ...
%         end
%         function energyUsage(obj)
%             ...
%         end
    end
end