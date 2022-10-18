classdef Aero
    %Holds information about the wing weight, structure and aircraft aerodynamics 

    properties (SetAccess = public)
        m_wing(1,1) double % Mass of wing tonnes
        LovD(1,1) double % Aircraft Lift to Drag
        AR(1,1) double %Wing Aspect Ratio
        b(1,1) double %Wingspan
        toc(1,1) double %Thickness over Chord
        S(1,1) double %Wing area (excluding fuselage)
        mac(1,1) double %Mean Absolute Chord
        root_c(1,1) double %Root Chord
        Sweep(1,1) double %wing sweep angle degrees
        C_L(1,1) double %Wing Coefficient of Lift
        wing_loading(1,1) double %Wing loading
        C_D(1,1) double % Coefficient of drag ffor aircraft normalised to wing area
%         weight Weight %for use in future iteration, the initial setup will hold an empty Weight class
% weight Weight
    end

    properties (SetAccess = immutable)
        tank FuelTank
        fuel Fuel  %possibly unused
        mission Mission %used to get parameters like number of seats etc.
        dimension Dimension %for use in correlations
    end

    methods
%         function obj = Aero()
%             obj.mission = mission;
%             obj.tank = tank;
%             obj.fuel = fuel;
%             obj.dimension = dimension;
%             obj.LovD = 16;
%             obj.AR = 14;
%             obj.b = dimension.fuselage_length*(((m_maxTO/1000)^2)*4e-6 - 0.002*m_maxTO/1000 + 1.0949);
%             obj.toc = 0.15;
%             obj.mac = obj.b/5;
%             obj.root_c = obj.b/obj.AR;
%             obj.Sweep = 25;
%             obj.C_L = 0.5;
%             obj.S = m_maxTO * 9.81 / obj.C_L / mission.dyn_pressure;
%             obj.wing_loading = m_maxTO*9.81/obj.S;
%             obj.m_wing = 0.86 / 9.81^0.5 * (obj.AR^2 / obj.wing_loading^3 * m_maxTO)^0.25 * m_maxTO;
%             obj.C_D = obj.C_L/obj.LovD;
%         end

function obj = initialise(mission,tank,fuel,dimension)
            %UNTITLED5 Construct an instance of this class
            %   Detailed explanation goes here
            obj.mission = mission;
            obj.tank = tank;
            obj.fuel = fuel;
            obj.dimension = dimension;
            if mission.designRange*0.02 - 19.79 > 30
                m_maxTO = mission.designRange*0.02 - 19.79;
            else
                m_maxTO = 30;
            end
            obj.LovD = 16;
            obj.AR = 14;
            obj.b = dimension.fuselage_length*(((m_maxTO/1000)^2)*4e-6 - 0.002*m_maxTO/1000 + 1.0949);
            obj.toc = 0.15;
            obj.mac = obj.b/5;
            obj.root_c = obj.b/obj.AR;
            obj.Sweep = 25;
            obj.C_L = 0.5;
            obj.S = m_maxTO * 9.81 / obj.C_L / mission.dyn_pressure;
            obj.wing_loading = m_maxTO*9.81/obj.S;
            obj.m_wing = 0.86 / 9.81^0.5 * (obj.AR^2 / obj.wing_loading^3 * m_maxTO)^0.25 * m_maxTO;
            obj.C_D = obj.C_L/obj.LovD;
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end