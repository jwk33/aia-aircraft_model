classdef Flight
    %Flight object
    
    % define flight properties for a given aircraft
    properties
        mach
        fL
        aircraft Aircraft
        range
        atm
    end
    methods
        function obj = Flight(M, fL, aircraft, atmosphere)
            obj.mach = M;
            obj.fL = fL;
            obj.aircraft = aircraft;
            obj.atm = atmosphere;
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