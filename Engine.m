classdef Engine
    %Engine object
    
    % define engine properties
    properties (SetAccess = public)
        m_eng(1,1) double {mustBeNonnegative, mustBeFinite}
        eta_eng(1,1) double {mustBeNonnegative, mustBeFinite}
        eta_prop(1,1) double {mustBeNonnegative, mustBeFinite}
        eng_thrust(1,1) double {mustBeNonnegative, mustBeFinite}
        number_engines(1,1) double {mustBeNonnegative, mustBeFinite}
        bpr(1,1) double {mustBeNonnegative, mustBeFinite} %Bypasss ratio
    end

    methods
        function obj = Engine(mission,aircraft)
            % construct engine object
            
            if isempty(aircraft.m_eng)
                disp('calculating engine mass')
                obj = obj.calculate_mass(aircraft);
            else
                disp('using input engine mass')
            end
            
            if isempty(aircraft.eta_eng)
                disp('using default engine efficiency')
                obj.eta_eng = 0.4511;
            else
                disp('using input engine efficiency')
                obj.eta_eng = aircraft.eta_eng;
            end
            obj.eta_prop = 0.8158;

        end

        function obj = Engine_Iteration(obj,aircraft)
            if isempty(aircraft.m_eng)
                disp('calculating engine mass')
                obj = obj.calculate_mass(aircraft);
            else
                disp('using input engine mass')
            end
            
            if isempty(aircraft.eta_eng)
                disp('using default engine efficiency')
                obj.eta_eng = 0.4511;
            else
                disp('using input engine efficiency')
            end
            obj.eta_prop = 0.8158;
        end


        function obj = calculate_mass(obj, aircraft)
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
        end
    end
end