classdef Mission < matlab.mixin.Copyable
    %Mission object
    
    % define flight properties for a given aircraft
    properties
        range(1,1) double {mustBeNonnegative, mustBeFinite}
        M(1,1) double {mustBeNonnegative, mustBeFinite}
        cruise_alt(1,1) double {mustBeNonnegative, mustBeFinite}
        cruise_speed(1,1) double {mustBeNonnegative, mustBeFinite} %m/s
        angle_TO(1,1) double {mustBeNonnegative, mustBeFinite} %degrees
        reserve_fuel(1,1) double {mustBeNonnegative, mustBeFinite} %To Be Added Later  
        max_pax(1,1) double {mustBeNonnegative, mustBeFinite}
        load_factor(1,1) double {mustBeNonnegative, mustBeFinite} % TODO: check this is between 0 and 1
        pax(1,1) double {mustBeNonnegative, mustBeFinite}
        m_cargo (1,1) double {mustBeFinite} %allowing negative for design
        
        % saving operation results for given mission
        fuel_burn FuelBurnModel
        weight Weight
    end

    properties (Access = public) % TODO: only allow aircraft class objects to set this
        convergence Convergence % object with sizing properties: convergence margin, maximum number of iterations
    end


    methods
        function obj = Mission(range, M, cruise_alt, max_pax,load_factor, m_cargo)
            obj.range = range;
            obj.M = M;
            obj.cruise_alt = cruise_alt;
            [T,sos,P,rho] = atmosisa(cruise_alt);
            obj.cruise_speed = sos*M;%m/s
            obj.angle_TO = 5; %degrees
            obj.reserve_fuel = 0; %To Be Added Later
            obj.max_pax = max_pax;
            obj.load_factor = load_factor;
            obj.pax = ceil(max_pax*load_factor);
            obj.m_cargo = m_cargo;
        end

        function obj = update(obj)
            obj.pax = obj.load_factor * obj.max_pax;
        end
    end
end