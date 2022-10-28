classdef Weight < handle
    %Weight class. This class has definintions of the weight breakdown as
    %well as MTOW

    properties (SetAccess = public)
        m_maxTO(1,1) double {mustBeNonnegative, mustBeFinite} % take-off weight in tons
        m_OEW (1,1) double {mustBeNonnegative, mustBeFinite} %OEW = ZFW - max payload
        m_shell(1,1) double {mustBeNonnegative, mustBeFinite}
        m_floor(1,1) double {mustBeNonnegative, mustBeFinite}
        m_systems(1,1) double {mustBeNonnegative, mustBeFinite}
        m_furnishings(1,1) double {mustBeNonnegative, mustBeFinite}
        m_LG(1,1) double {mustBeNonnegative, mustBeFinite} 
        m_seats(1,1) double {mustBeNonnegative, mustBeFinite}
        m_payload(1,1) double {mustBeNonnegative, mustBeFinite}
        m_max_payload(1,1) double {mustBeNonnegative, mustBeFinite}
        m_tail(1,1) double {mustBeNonnegative, mustBeFinite}
        m_fuel_sys(1,1) double {mustBeNonnegative, mustBeFinite}
    end

    methods
        function obj = Weight(aircraft)
            if aircraft.mission.range*0.02 - 19.79 > 30
                obj.m_maxTO = aircraft.mission.range*0.02 - 19.79;
            else
                obj.m_maxTO = 30;
            end
            obj.m_shell = 60 * aircraft.dimension.fuselage_diameter^2 * aircraft.dimension.cabin_length /(1000*9.81);
            obj.m_floor = 160 * 3.75^0.5 * aircraft.dimension.fuselage_diameter * aircraft.dimension.cabin_length /(1000*9.81);
            obj.m_systems = (270 * aircraft.dimension.fuselage_diameter + 150) * aircraft.dimension.cabin_length /(1000*9.81);
            obj.m_furnishings = (12 * aircraft.dimension.fuselage_diameter * (3 * aircraft.dimension.fuselage_diameter + aircraft.dimension.N_deck/2 + 1) * aircraft.dimension.cabin_length + 3500) /(1000*9.81);
            obj.m_LG = 0.039 * (1 + aircraft.dimension.cabin_length / 1100) * obj.m_maxTO;
            obj.m_seats = 350 * aircraft.mission.max_pax /(1000*9.81);
            obj.m_payload = aircraft.mission.pax * 105/1000;   % Assume each passenger and their cargo weighs 105 kg
            obj.m_max_payload = aircraft.mission.max_pax * 105/1000;
            obj.m_tail = 0.07 * (obj.m_shell + obj.m_floor) + 0.1 * aircraft.aero.m_wing;
            if ~isempty(aircraft.tank)
                obj.m_fuel_sys = aircraft.tank.m_tank;
            else
                obj.m_fuel_sys = 0;
            end
            obj.m_OEW = aircraft.engine.m_eng + aircraft.aero.m_wing + obj.m_shell + obj.m_floor + obj.m_systems + obj.m_furnishings + obj.m_LG + obj.m_seats + obj.m_tail + obj.m_fuel_sys;
            obj.m_maxTO = obj.m_OEW + obj.m_max_payload + aircraft.fuelburn.m_fuel;
        end

        function obj = Weight_Iteration(obj,aircraft)
            obj.m_shell = 60 * aircraft.dimension.fuselage_diameter^2 * aircraft.dimension.cabin_length /(1000*9.81);
            obj.m_floor = 160 * 3.75^0.5 * aircraft.dimension.fuselage_diameter * aircraft.dimension.cabin_length /(1000*9.81);
            obj.m_systems = (270 * aircraft.dimension.fuselage_diameter + 150) * aircraft.dimension.cabin_length /(1000*9.81);
            obj.m_furnishings = (12 * aircraft.dimension.fuselage_diameter * (3 * aircraft.dimension.fuselage_diameter + aircraft.dimension.N_deck/2 + 1) * aircraft.dimension.cabin_length + 3500) /(1000*9.81);
            obj.m_LG = 0.039 * (1 + aircraft.dimension.cabin_length / 1100) * obj.m_maxTO;
            obj.m_seats = 350 * aircraft.mission.max_pax /(1000*9.81);
            obj.m_payload = aircraft.mission.max_pax * aircraft.mission.load_factor * 105/1000;  % Assume each passenger and their cargo weighs 105 kg
            obj.m_max_payload = aircraft.mission.max_pax * 105/1000;
            obj.m_tail = 0.07 * (obj.m_shell + obj.m_floor) + 0.1 * aircraft.aero.m_wing/1000;
            if ~isempty(aircraft.tank)
                obj.m_fuel_sys = aircraft.tank.m_tank;
            else
                obj.m_fuel_sys = 0;
            end
            obj.m_OEW = aircraft.engine.m_eng + aircraft.aero.m_wing + obj.m_shell + obj.m_floor + obj.m_systems + obj.m_furnishings + obj.m_LG + obj.m_seats + obj.m_tail + obj.m_fuel_sys;
            obj.m_maxTO = obj.m_OEW + obj.m_max_payload + aircraft.fuelburn.m_fuel;
        end
    end
end