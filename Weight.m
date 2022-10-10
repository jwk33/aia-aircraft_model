classdef Weight < handle
    %Weight class. This class has definintions of the weight breakdown as
    %well as MTOW

    properties (SetAccess = public)
        m_maxTO(1,1) double % take-off weight in tons
        m_OEW (1,1) double %OEW = ZFW - max payload
        m_wings(1,1) double
        m_shell(1,1) double
        m_floor(1,1) double
        m_systems(1,1) double
        m_furnishings(1,1) double
        m_LG(1,1) double 
        m_seats(1,1) double {mustBeInRange(m_seats,0,1000)};
        m_payload(1,1) double
        m_max_payload(1,1) double
        m_tail(1,1) double
%         m_fuel comes from fuel burn class
%         m_engines comes from engines class
%         m_tank comes from fueltank class
    end

    properties (SetAccess = protected)
        tank FuelTank %gets tank mass
        engine Engine %gets engine mass
        dimension Dimension %for use in correlations
        aero Aero %for use in correlations
        fuel_burn FuelBurnModel%used to update m_fuel and MTOW
    end

    properties (SetAccess = immutable)
        fuel Fuel  %possibly unused
        mission Mission %used to get parameters like number of seats etc.
    end

    properties (Constant)
        N_deck = 1;%Should be added into dimension 
    end

    methods
        function obj = Weight(tank,engine,dimension,aero,fuel_burn,fuel,mission)
            %Constructs a weight class
            obj.tank = tank;
            obj.engine = engine;
            obj.dimension = dimension;
            obj.aero = aero;
            obj.fuel_burn = fuel_burn;
            obj.fuel = fuel;
            obj.mission = mission;
            if mission.designRange*0.02 - 19.79 > 30
                obj.m_maxTO = mission.designRange*0.02 - 19.79;
            else
                obj.m_maxTO = 30;
            end
            obj.m_wings = 0.11*obj.m_maxTO;
            obj.m_shell = 0.06*obj.m_maxTO;
            obj.m_floor = 0.06*obj.m_maxTO;
            obj.m_systems = 0.05*obj.m_maxTO;
            obj.m_furnishings = 0.06*obj.m_maxTO;
            obj.m_LG = 0.04*obj.m_maxTO;
            obj.m_seats = 0.05*obj.m_maxTO;
            obj.m_payload = mission.max_pax*mission.load_factor * 105;
            obj.m_max_payload = mission.max_pax*105;
            obj.m_tail = 0.02*obj.m_maxTO;
            obj.m_OEW = obj.m_maxTO - obj.m_max_payload - obj.fuel_burn.m_fuel;
        end

        function obj = Weight_Breakdown(obj)
            %Calculates all of the weights of each component in tonnes
%             arguments
%                 obj
%                 dimension Dimension
%                 aero Aero
%                 mission Mission
%                 N_deck
%             end
            obj.m_wings = 0.86 / 9.81^0.5 * (obj.aero.AR^2 / obj.aero.wing_loading^3 * obj.m_maxTO)^0.25 * obj.m_maxTO;
            obj.m_shell = 60 * obj.dimension.fuselage_diameter^2 * obj.dimension.cabin_length / 9.81;
            obj.m_floor = 160 * 3.75^0.5 * obj.dimension.fuselage_diameter * obj.dimension.cabin_length / 9.81;
            obj.m_systems = (270 * obj.dimension.fuselage_diameter + 150) * obj.dimension.cabin_length / 9.81;
            obj.m_furnishings = (12 * obj.dimension.fuselage_diameter * (3 * obj.dimension.fuselage_diameter + obj.N_deck/2 + 1) * obj.dimension.cabin_length + 3500) / 9.81;
            obj.m_LG = 0.039 * (1 + obj.dimension.cabin_length / 1100) * obj.m_maxTO;
            obj.m_seats = 350 * obj.mission.max_pax / 9.81;
            obj.m_payload = obj.mission.max_pax * obj.mission.load_factor * 105;   % Assume each passenger and their cargo weighs 105 kg
            obj.m_max_payload = obj.mission.max_pax * 105;
            obj.m_tail = 0.07 * (obj.m_shell + obj.m_floor) + 0.1 * obj.m_wings;
            obj.m_OEW = obj.engine.m_engines + obj.m_wings + obj.m_shell + obj.m_floor + obj.m_systems + obj.m_furnishings + obj.m_LG + obj.m_seats + obj.m_payload + obj.m_tail + obj.tank.m_tank;
        end
        function obj = MTOW_Calculation(obj)
            obj.m_maxTO = obj.m_OEW + obj.m_max_payload + obj.fuel_burn.m_fuel;
        end
    end
end