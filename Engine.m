classdef Engine
    %Engine object
    
    % define engine properties
    properties (SetAccess = public)
        m_eng(1,1) double {mustBeNonnegative, mustBeFinite}
        eng_eff(1,1) double {mustBeNonnegative, mustBeFinite}
        prop_eff(1,1) double {mustBeNonnegative, mustBeFinite}
        eng_thrust(1,1) double {mustBeNonnegative, mustBeFinite}
        number_engines(1,1) double {mustBeNonnegative, mustBeFinite}
        bpr(1,1) double {mustBeNonnegative, mustBeFinite} %Bypasss ratio
    end

    methods
        function obj = Engine(mission)
            % construct engine object
            if mission.range*0.02 - 19.79 > 30
                m_maxTO = mission.range*0.02 - 19.79;
            else
                m_maxTO = 30;
            end
            obj.eng_thrust = 1.28*m_maxTO*9.81/1000;%kN
%             obj.fuel = fuel;
%             obj.mission = mission;
%             obj.aero = aero;
            obj.bpr = 9;
            eng_mass = obj.eng_thrust*(8.7+1.14*obj.bpr); % Jenkinson et al. method
            if obj.eng_thrust < 600
                nacelle = 6.8*obj.eng_thrust; % Jenkinson et al. approximation of nacelle weight if take-off thrust < 600 kN
            elseif obj.eng_thrust > 600
                nacelle = 2760 + 2.2*obj.eng_thrust; % Jenkinson et al. approximation of nacelle weight if take-off thrust > 600 kN
            end
            obj.number_engines = 2*ceil(m_maxTO/120);
            obj.m_eng = eng_mass + nacelle; % Total engine weight (engine + nacelle) Unsure if this is per engine or overall??
            obj.eng_eff = 0.6;
            obj.prop_eff = 0.8;
        end

        function obj = Engine_Iteration(obj,a)
            obj.eng_thrust = 1.28*a.weight.m_maxTO*9.81/1000;%kN
            obj.bpr = 9;
            eng_mass = obj.eng_thrust*(8.7+1.14*obj.bpr); % Jenkinson et al. method
            if obj.eng_thrust < 600
                nacelle = 6.8*obj.eng_thrust; % Jenkinson et al. approximation of nacelle weight if take-off thrust < 600 kN
            elseif obj.eng_thrust > 600
                nacelle = 2760 + 2.2*obj.eng_thrust; % Jenkinson et al. approximation of nacelle weight if take-off thrust > 600 kN
            end
            if a.weight.m_maxTO/120 < 1.1 && a.weight.m_maxTO/120 > 0.9
                obj.number_engines = obj.number_engines;
            else
                obj.number_engines = 2*ceil(a.weight.m_maxTO/120);
            end
            obj.m_eng = eng_mass + nacelle; % Total engine weight (engine + nacelle) Unsure if this is per engine or overall??
            %NEED ACCURATE CALCS HERE
            obj.eng_eff = 0.6;
            obj.prop_eff = 0.8;

        end
    end
end