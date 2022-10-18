classdef Engine
    %Engine object
    
    % define engine properties
    properties (SetAccess = public)
        m_eng(1,1) double
        eng_eff(1,1) double
        prop_eff(1,1) double
        eng_thrust(1,1) double
        number_engines(1,1) double
        bpr(1,1) double %Bypasss ratio
    end

    properties (SetAccess = protected)
        aero Aero %gets engine mass
    end

    properties (SetAccess = immutable)
        fuel Fuel  %possibly unused
        mission Mission %used to get parameters like number of seats etc.
    end

    methods
        function obj = Engine(fuel, mission, aero)
            % construct engine object
            if mission.designRange*0.02 - 19.79 > 30
                m_maxTO = mission.designRange*0.02 - 19.79;
            else
                m_maxTO = 30;
            end
            obj.eng_thrust = 1.28*m_maxTO*9.81/1000;%kN
            obj.fuel = fuel;
            obj.mission = mission;
            obj.aero = aero;
            obj.bpr = 9;
            eng_mass = obj.eng_thrust*(8.7+1.14*bpr); % Jenkinson et al. method
            if takeoff_thrust < 600
                nacelle = 6.8*obj.eng_thrust; % Jenkinson et al. approximation of nacelle weight if take-off thrust < 600 kN
            elseif takeoff_thrust > 600
                nacelle = 2760 + 2.2*obj.eng_thrust; % Jenkinson et al. approximation of nacelle weight if take-off thrust > 600 kN
            end
            obj.number_engines = 2*ceil(m_maxTO/120);
            obj.m_eng = eng_mass + nacelle; % Total engine weight (engine + nacelle) Unsure if this is per engine or overall??
            obj.eng_eff = 0.6;
            obj.prop_eff = 0.8;
        end
    end
end