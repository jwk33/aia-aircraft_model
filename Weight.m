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
    end

    methods
        function obj = Weight(tank,aero,engine,fuelburn,dimension,mission)
            if mission.range*0.02 - 19.79 > 30
                obj.m_maxTO = mission.range*0.02 - 19.79;
            else
                obj.m_maxTO = 30;
            end
            m_maxTO = 1000;
            obj.m_shell = 60 * dimension.fuselage_diameter^2 * dimension.cabin_length /(1000*9.81);
            obj.m_floor = 160 * 3.75^0.5 * dimension.fuselage_diameter * dimension.cabin_length /(1000*9.81);
            obj.m_systems = (270 * dimension.fuselage_diameter + 150) * dimension.cabin_length /(1000*9.81);
            obj.m_furnishings = (12 * dimension.fuselage_diameter * (3 * dimension.fuselage_diameter + dimension.N_deck/2 + 1) * dimension.cabin_length + 3500) /(1000*9.81);
            obj.m_LG = 0.039 * (1 + dimension.cabin_length / 1100) * obj.m_maxTO;
            obj.m_seats = 350 * mission.max_pax /(1000*9.81);
            obj.m_payload = mission.pax * 105/1000;   % Assume each passenger and their cargo weighs 105 kg
            obj.m_max_payload = mission.max_pax * 105/1000;
            obj.m_tail = 0.07 * (obj.m_shell + obj.m_floor) + 0.1 * aero.m_wing;
            obj.m_OEW = engine.m_eng + aero.m_wing + obj.m_shell + obj.m_floor + obj.m_systems + obj.m_furnishings + obj.m_LG + obj.m_seats + obj.m_payload + obj.m_tail + tank.m_tank;
            obj.m_maxTO = obj.m_OEW + obj.m_max_payload + fuelburn.m_fuel;
        end

        function obj = Weight_Iteration(obj,a)
            obj.m_shell = 60 * a.dimension.fuselage_diameter^2 * a.dimension.cabin_length /(1000*9.81);
            obj.m_floor = 160 * 3.75^0.5 * a.dimension.fuselage_diameter * a.dimension.cabin_length /(1000*9.81);
            obj.m_systems = (270 * a.dimension.fuselage_diameter + 150) * a.dimension.cabin_length /(1000*9.81);
            obj.m_furnishings = (12 * a.dimension.fuselage_diameter * (3 * a.dimension.fuselage_diameter + a.dimension.N_deck/2 + 1) * a.dimension.cabin_length + 3500) /(1000*9.81);
            obj.m_LG = 0.039 * (1 + a.dimension.cabin_length / 1100) * obj.m_maxTO;
            obj.m_seats = 350 * a.mission.max_pax /(1000*9.81);
            obj.m_payload = a.mission.max_pax * a.mission.load_factor * 105/1000;  % Assume each passenger and their cargo weighs 105 kg
            obj.m_max_payload = a.mission.max_pax * 105/1000;
            obj.m_tail = 0.07 * (obj.m_shell + obj.m_floor) + 0.1 * a.aero.m_wing/1000;
            obj.m_OEW = a.engine.m_eng + a.aero.m_wing + obj.m_shell + obj.m_floor + obj.m_systems + obj.m_furnishings + obj.m_LG + obj.m_seats + obj.m_payload + obj.m_tail + a.tank.m_tank;
            obj.m_maxTO = obj.m_OEW + obj.m_max_payload + a.fuelburn.m_fuel;
        end
    end
end