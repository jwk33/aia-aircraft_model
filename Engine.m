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
                m_maxTO = (mission.range*0.02 - 19.79)*1e3;
            else
                m_maxTO = 30e3;
            end
            obj.eng_thrust = 1.28*m_maxTO;%kN
%             obj.fuel = fuel;
%             obj.mission = mission;
%             obj.aero = aero;
            obj.bpr = 15.1;
%             obj.bpr = 15.66;
            eng_mass = obj.eng_thrust*(8.7+1.14*obj.bpr); % kg Jenkinson et al. method
            if obj.eng_thrust < 600
                nacelle = 6.8*obj.eng_thrust; % kg Jenkinson et al. approximation of nacelle weight if take-off thrust < 600 kN
            elseif obj.eng_thrust > 600
                nacelle = 2760 + 2.2*obj.eng_thrust; % kg Jenkinson et al. approximation of nacelle weight if take-off thrust > 600 kN
            end
            obj.number_engines = 2*ceil(m_maxTO/120);
            obj.m_eng = (eng_mass + nacelle); % Total engine weight (engine + nacelle) Unsure if this is per engine or overall??
            obj.m_eng = 6e3;
            obj.eng_eff = 0.4511;
            obj.prop_eff = 0.8158;
%             obj.m_eng = 5;
%             obj.eng_eff = 0.5153;
%             obj.prop_eff = 0.8076;
        end

        function obj = Engine_Iteration(obj,aircraft)
            obj.eng_thrust = 1.28*aircraft.weight.m_maxTO*1e-3;%kN
            obj.bpr = 15.1;
%             obj.bpr = 15.66;
            eng_mass = obj.eng_thrust*(8.7+1.14*obj.bpr); % Jenkinson et al. method
            if obj.eng_thrust < 600
                nacelle = 6.8*obj.eng_thrust; % Jenkinson et al. approximation of nacelle weight if take-off thrust < 600 kN
            elseif obj.eng_thrust > 600
                nacelle = 2760 + 2.2*obj.eng_thrust; % Jenkinson et al. approximation of nacelle weight if take-off thrust > 600 kN
            end
            if aircraft.weight.m_maxTO/120e3 < 1.1 && aircraft.weight.m_maxTO/120e3 > 0.9
                obj.number_engines = obj.number_engines;
            else
                obj.number_engines = 2*ceil(aircraft.weight.m_maxTO/120e3);
            end
            obj.m_eng = (eng_mass + nacelle); % Total engine weight (engine + nacelle) Unsure if this is per engine or overall??
            %NEED ACCURATE CALCS HERE
            obj.m_eng = 6.800e3;
            %obj.eng_eff = 0.4511;
            obj.eng_eff = 0.4045;
            obj.prop_eff = 0.8158;
%             obj.m_eng = 5;
%             obj.eng_eff = 0.5153;
%             obj.prop_eff = 0.8076;
        end
    end
end