classdef Weight < handle
    %Weight class. This class has definintions of the weight breakdown as
    %well as MTOW

    properties (SetAccess = public)
        m_maxTO(1,1) double % take-off weight in tons
        OEWFrac(1,1) double {mustBeInRange(OEWFrac,0,1)}; % OEW fraction
        m_engines(1,1) double {mustBeInRange(m_engines,0,1)};
        m_wings(1,1) double {mustBeInRange(m_wings,0,1)};
        m_shell(1,1) double {mustBeInRange(m_shell,0,1)};
        m_floor(1,1) double {mustBeInRange(m_floor,0,1)};
        m_systems(1,1) double {mustBeInRange(m_systems,0,1)};
        m_furnishings(1,1) double {mustBeInRange(m_furnishings,0,1)};
        m_LG(1,1) double {mustBeInRange(m_LG,0,1)};
        m_seats(1,1) double {mustBeInRange(m_seats,0,1)};
        m_payload(1,1) double {mustBeInRange(m_payload,0,1)};
        m_tail(1,1) double {mustBeInRange(m_tail,0,1)};
        m_fuel(1,1) double {mustBeInRange(m_fuel,0,1)};
    end

    properties (SetAccess = protected)
        tank FuelTank
        engine Engine
        dimension Dimension
        aero Aero
    end

    properties (SetAccess = immutable)
        useTankModel logical % Use tank model in weight determination - relevant
        % for new tank models (such as liquid hydrogen)
        fuel Fuel  
        mission Mission
    end

    properties (Constant)
        k_LH2 = 0.0072;
        N_deck = 1;
    end

    methods
        function obj = Weight(inputArg1,inputArg2)
            %UNTITLED6 Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end

        function obj = Weight_Breakdown(obj,dimension,aero,mission,engine,N_deck,k_LH2)
            %Calculates all of the weights of each component in tonnes
%             arguments
%                 obj
%                 dimension Dimension
%                 aero Aero
%                 mission Mission
%                 engine Engine
%                 N_deck
%                 k_LH2
%             end
            obj.m_engines = engine.number_engines * 8000 / 9.81 + 0.935 * (1 - k_LH2) / aero.LovD();
            obj.m_wings = 0.86 / 9.81^0.5 * (aero.AR^2 / aero.wing_loading()^3 * obj.m_maxTO)^0.25;
            obj.m_shell = (60 * dimension.fuselage_diameter()^2 * dimension.cabin_length / 9.81)/obj.m_maxTO;
            obj.m_floor = (160 * 3.75^0.5 * dimension.fuselage_diameter() * dimension.cabin_length / 9.81)/obj.m_maxTO;
            obj.m_systems = ((270 * dimension.fuselage_diameter() + 150) * dimension.cabin_length / 9.81)/obj.m_maxTO;
            obj.m_furnishings = ((12 * dimension.fuselage_diameter() * (3 * dimension.fuselage_diameter() + N_deck/2 + 1) * dimension.cabin_length + 3500) / 9.81)/obj.m_maxTO;
            obj.m_LG = 0.039 * (1 + dimension.cabin_length / 1100);
            obj.m_seats = (350 * mission.max_pax() / 9.81)/obj.m_maxTO;
            obj.m_payload = (mission.max_pax() * mission.load_factor * 105)/obj.m_maxTO;   % Assume each passenger and their cargo weighs 105 kg 
            obj.m_tail = (0.07 * (obj.m_shell + obj.m_floor) + 0.1 * obj.m_wings)/obj.m_maxTO;
        end
    end
end