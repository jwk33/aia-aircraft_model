classdef Atmosphere
    %Atmosphere object
    
    % define atmosphere for flight
    properties (SetAccess = immutable)
        temp(1,1) double
        density(1,1) double
        sos(1,1) double %Speed of Sound
        pressure(1,1) double
    end
    
    methods
        function obj = Atmosphere(altitude)
            [obj.temp,obj.sos,obj.pressure,obj.density] = atmosisa(altitude);
        end
    end
end