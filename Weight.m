classdef Weight < matlab.mixin.Copyable
    %Weight class. This class has definintions of the weight breakdown as
    %well as MTOW

    properties (SetAccess = public)
        % High level weights
        m_maxTO(1,1) double {mustBeNonnegative, mustBeFinite} % max take-off weight in kg
        m_TO(1,1) double {mustBeNonnegative, mustBeFinite} % take-off weight at operation point
        m_maxZFW(1,1) double {mustBeNonnegative, mustBeFinite} % zero-fuel weight
        m_ZFW(1,1) double {mustBeNonnegative, mustBeFinite} % zero-fuel weight at operation point
        m_OEW (1,1) double {mustBeNonnegative, mustBeFinite} %OEW = ZFW - max payload
        m_max_payload(1,1) double {mustBeNonnegative, mustBeFinite}
        m_payload(1,1) double {mustBeNonnegative, mustBeFinite}
        m_Fuel (1,1) double {mustBeNonnegative, mustBeFinite}
        m_maxFuel(1,1) double {mustBeNonnegative, mustBeFinite}

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
        function obj = Weight()
            %creates empty weight class
        end
        function obj = first_calc(obj,aircraft)

            obj = torenbeek(obj,aircraft);
            
            % calculate expected high level weights  
            obj = obj.finalise(aircraft,aircraft.design_mission);

            % calculate high level weights with technology improvements
            obj = aircraft.tech.improve_oew(obj,aircraft,aircraft.design_mission);
            obj = obj.finalise(aircraft,aircraft.design_mission);
        end

        function obj = Weight_Iteration(obj,aircraft)
            
            

            obj = torenbeek(obj,aircraft);

            % calculate expected high level weights  
            obj = obj.finalise(aircraft,aircraft.design_mission);

            % calculate high level weights with technology improvements
            obj = aircraft.tech.improve_oew(obj,aircraft,aircraft.design_mission);
            obj = obj.finalise(aircraft,aircraft.design_mission);
        end

        function obj = finalise(obj, aircraft,mission)
            
            % Payload
            obj.m_max_payload = mission.max_pax * obj.m_pax + mission.m_cargo;

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


            % Max Fuel
            obj.m_maxFuel = aircraft.fuelburn.m_fuel; % for design portion, max fuel is equal to fuel at design point

            % Max Takeoff Weight
            obj.m_maxTO = obj.m_OEW + obj.m_max_payload + obj.m_maxFuel;

            % Max Zero Fuel
            obj.m_maxZFW = obj.m_OEW + obj.m_max_payload;
            
            % Variables that will change with operating point
            obj = obj.operate(aircraft,mission);

            assert(obj.m_maxTO < 1e6, "Max Takeoff Weight too high - Solution diverged")

            
        end

        function obj = operate(obj, aircraft, mission)
            % Payload
            obj.m_payload = mission.pax * obj.m_pax + mission.m_cargo;  % Assume each passenger and their cargo weighs 105 kg
            
            % Fuel
            obj.m_Fuel = aircraft.fuelburn.m_fuel;

            % Takeoff Weight
            obj.m_TO = obj.m_OEW + obj.m_payload + obj.m_Fuel;

            % Zero Fuel
            obj.m_ZFW = obj.m_OEW + obj.m_payload;
            assert ((obj.m_maxTO - obj.m_TO) > -1 , ...
                ['Takeoff Weight greater than Max Takeoff Weight\n' ...
                'MTOW: %7.4f t\n TOW: %7.4f t'],obj.m_maxTO*1e-3, obj.m_TO*1e-3)
            if (obj.m_maxTO - obj.m_TO) < 0
                warning("TOW higher than MTOW by %10.9f kg",obj.m_TO - obj.m_maxTO)
            end
            assert (obj.m_TO > obj.m_OEW, "Takeoff weight less than empty weight")
            
        end

        function obj = torenbeek(obj,aircraft)
            l = aircraft.dimension.fuselage_length;
            d = aircraft.dimension.fuselage_diameter;
            
            g = 9.81;
            
            % Fuel Systems
            if ~isempty(aircraft.tank)
                obj.m_fuel_sys = aircraft.tank.m_tank;  %hydrogen tank
                l_tank = aircraft.tank.length_ext;
            else
                obj.m_fuel_sys = 0;
                l_tank = 0;
            end

            % Wing mass
            obj.m_wing = aircraft.aero.m_wing;
            
            
            % Propulsion mass
            obj.m_engine = aircraft.engine.m_eng;

            % Landing Gear mass % verified
            obj.m_LG = 0.039*(1+l/1100) * obj.m_maxTO;

            % Fuselage mass % verified
            obj.m_fuselage = (60 * d^2 * (l + 1.5) + 160 * sqrt(3.75) * d * l)/(g);

            % Empennage mass % verified
            obj.m_tail = (0.1 * obj.m_wing) + (0.07 * obj.m_fuselage);

            % Systems mass % verified
            obj.m_systems = (270*d + 150) * l/g;

            % Furnishings mass % verified but minor adjustment so length is
            % only cabin length
            obj.m_furnishings = (35000 + (12*d*(3*d + aircraft.dimension.N_deck/2 + 1))*(l-l_tank))/g;

            % Operating items mass % verified but range boundary is
            % arbitrary
            if aircraft.design_mission.range > 6000
                m_op_pax = 500/g;

            else
                m_op_pax = 350/g;
            end

            obj.m_op_items = m_op_pax * aircraft.dimension.max_seats;

            

            
        end

        function obj = torenbeek_old(obj,aircraft)
            m_shell = 60 * aircraft.dimension.fuselage_diameter^2 * aircraft.dimension.cabin_length /(9.81);
            m_floor = 160 * 3.75^0.5 * aircraft.dimension.fuselage_diameter * aircraft.dimension.cabin_length /(9.81);
            
            obj.m_fuselage = m_shell + m_floor;
            
            obj.m_systems = (270 * aircraft.dimension.fuselage_diameter + 150) * aircraft.dimension.cabin_length /(9.81);
            obj.m_furnishings = (12 * aircraft.dimension.fuselage_diameter * (3 * aircraft.dimension.fuselage_diameter + aircraft.dimension.N_deck/2 + 1) * aircraft.dimension.cabin_length + 3500) /(9.81);
            obj.m_LG = 0.039 * (1 + aircraft.dimension.cabin_length / 1100) * obj.m_maxTO;
            obj.m_op_items = 350 * aircraft.design_mission.max_pax /(9.81);
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