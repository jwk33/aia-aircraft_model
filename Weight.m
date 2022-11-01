classdef Weight < handle
    %Weight class. This class has definintions of the weight breakdown as
    %well as MTOW

    properties (SetAccess = public)
        % High level weights
        m_maxTO(1,1) double {mustBeNonnegative, mustBeFinite} % take-off weight in kg
        m_OEW (1,1) double {mustBeNonnegative, mustBeFinite} %OEW = ZFW - max payload
        m_max_payload(1,1) double {mustBeNonnegative, mustBeFinite}
        m_payload(1,1) double {mustBeNonnegative, mustBeFinite}
        m_fuel (1,1) double {mustBeNonnegative, mustBeFinite}

        % Weight breakdown
        m_wing (1,1) double {mustBeNonnegative, mustBeFinite}
        m_fuselage (1,1) double {mustBeNonnegative, mustBeFinite}
        m_LG(1,1) double {mustBeNonnegative, mustBeFinite} 
        m_tail(1,1) double {mustBeNonnegative, mustBeFinite}
        m_engine (1,1) double {mustBeNonnegative, mustBeFinite}
        m_fuel_sys(1,1) double {mustBeNonnegative, mustBeFinite}
        m_systems(1,1) double {mustBeNonnegative, mustBeFinite}
        m_furnishings(1,1) double {mustBeNonnegative, mustBeFinite}
        m_op_items (1,1) double {mustBeNonnegative, mustBeFinite}
        m_seats(1,1) double {mustBeNonnegative, mustBeFinite}
        m_shell(1,1) double {mustBeNonnegative, mustBeFinite}
        m_floor(1,1) double {mustBeNonnegative, mustBeFinite}
        m_mzf_delta(1,1) double {mustBeFinite} = 0 % change in mzf due to technology improvements applied to oew
    end

    properties (Constant)
        m_pax = 102; % kg per passenger
    end

    methods
        function obj = Weight(obj)
            %creates empty weight class
        end
        function obj = first_calc(obj,aircraft)
            if aircraft.mission.range*0.02 - 19.79 > 30
                obj.m_maxTO = (aircraft.mission.range*0.02 - 19.79)*1e3;
            else
                obj.m_maxTO = 30e3;
            end
            
            obj.m_payload = aircraft.mission.pax * obj.m_pax + aircraft.mission.m_cargo;  % Assume each passenger and their cargo weighs 105 kg
            obj.m_max_payload = aircraft.mission.max_pax * obj.m_pax + aircraft.mission.m_cargo;
            obj.m_fuel = aircraft.fuelburn.m_fuel;

            obj = torenbeek(obj,aircraft);
            
            % calculate expected high level weights  
            obj = obj.finalise();

            % calculate high level weights with technology improvements
            obj = aircraft.tech.improve_oew(obj);
            obj = obj.finalise();
        end

        function obj = Weight_Iteration(obj,aircraft)
            obj.m_payload = aircraft.mission.pax * obj.m_pax + aircraft.mission.m_cargo;  % Assume each passenger and their cargo weighs 105 kg
            obj.m_max_payload = aircraft.mission.max_pax * obj.m_pax + aircraft.mission.m_cargo;
            obj.m_fuel = aircraft.fuelburn.m_fuel;

            obj = torenbeek(obj,aircraft);

            % calculate expected high level weights  
            obj = obj.finalise();

            % calculate high level weights with technology improvements
            obj = aircraft.tech.improve_oew(obj);
            obj = obj.finalise();
        end

        function obj = finalise(obj)
            % Operating Empty Weight
            obj.m_OEW = obj.m_wing ...
                + obj.m_fuselage ...
                + obj.m_LG ...
                + obj.m_tail ...
                + obj.m_engine ...
                + obj.m_systems ...
                + obj.m_furnishings ...
                + obj.m_op_items ...
                + obj.m_fuel_sys ...
                + obj.m_mzf_delta;
            
            % Max Takeoff Weight
            obj.m_maxTO = obj.m_OEW + obj.m_max_payload + obj.m_fuel;
        end

        function obj = torenbeek(obj,aircraft)
            l = aircraft.dimension.fuselage_length;
            d = aircraft.dimension.fuselage_diameter;
            l_tank = 0;
            g = 9.81;

            % Wing mass
            obj.m_wing = 0.86/sqrt(g) * (aircraft.aero.AR^2/aircraft.aero.wing_loading^3*obj.m_maxTO)^(1/4) * obj.m_maxTO;
            
            % Propulsion mass
            obj.m_engine = aircraft.engine.m_eng;

            % Landing Gear mass
            obj.m_LG = 0.039*(1+l/1100) * obj.m_maxTO;

            % Fuselage mass
            obj.m_fuselage = (60 * d^2 * (l + 1.5) + 160 * sqrt(3.75) * d * l)/(g);

            % Empennage mass
            obj.m_tail = (0.1 * obj.m_wing) + (0.07 * obj.m_fuselage);

            % Systems mass
            obj.m_systems = (270*d + 150) * l/g;

            % Furnishings mass
            obj.m_furnishings = (35000 + (12*d*(3*d + aircraft.dimension.N_deck/2 + 1))*(l-l_tank))/g;

            % Operating items mass
            obj.m_op_items = 350 * aircraft.dimension.max_seats/g;

            % Fuel Systems
            if ~isempty(aircraft.tank)
                obj.m_fuel_sys = aircraft.tank.m_tank;  %hydrogen tank
            else
                obj.m_fuel_sys = 0;
            end

            
        end

        function obj = torenbeek_old(obj,aircraft)
            m_shell = 60 * aircraft.dimension.fuselage_diameter^2 * aircraft.dimension.cabin_length /(9.81);
            m_floor = 160 * 3.75^0.5 * aircraft.dimension.fuselage_diameter * aircraft.dimension.cabin_length /(9.81);
            
            obj.m_fuselage = m_shell + m_floor;
            
            obj.m_systems = (270 * aircraft.dimension.fuselage_diameter + 150) * aircraft.dimension.cabin_length /(9.81);
            obj.m_furnishings = (12 * aircraft.dimension.fuselage_diameter * (3 * aircraft.dimension.fuselage_diameter + aircraft.dimension.N_deck/2 + 1) * aircraft.dimension.cabin_length + 3500) /(9.81);
            obj.m_LG = 0.039 * (1 + aircraft.dimension.cabin_length / 1100) * obj.m_maxTO;
            obj.m_op_items = 350 * aircraft.mission.max_pax /(9.81);
            obj.m_tail = 0.07 * (obj.m_shell + obj.m_floor) + 0.1 * aircraft.aero.m_wing;

            if ~isempty(aircraft.tank)
                obj.m_fuel_sys = aircraft.tank.m_tank;
            else
                obj.m_fuel_sys = 0;
            end

            obj.m_engine = aircraft.engine.m_eng;
            obj.m_wing = aircraft.aero.m_wing;
        end
    end
end