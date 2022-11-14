classdef Engine
    %Engine object
    
    % define engine properties
    properties (SetAccess = public)
        m_eng(1,1) double {mustBeNonnegative, mustBeFinite}
        eta_eng(1,1) double {mustBeNonnegative, mustBeFinite} = 0.44
        eta_prop(1,1) double {mustBeNonnegative, mustBeFinite} = 0.81
        eta_ov(1,1) double {mustBeNonnegative, mustBeFinite}
        thrust_total(1,1) double {mustBeNonnegative, mustBeFinite} % total thrust
        thrust_eng(1,1) double {mustBeNonnegative, mustBeFinite} % thrust per engine
        number_engines(1,1) double {mustBeNonnegative, mustBeFinite}
        bpr(1,1) double {mustBeNonnegative, mustBeFinite} %Bypasss ratio
        m_input(1,1) double
        eta_input(1,1) double
    end

    methods
        function obj = Engine(aircraft)
            % construct engine object
            

            %handle inputs

            if any(ismember(fields(aircraft.manual_input),'m_eng'))
                obj.m_eng = aircraft.manual_input.m_eng;
            else
                % use default
                obj = obj.calculate_mass(aircraft);
            end
            
            if any(ismember(fields(aircraft.manual_input),'eta'))
                obj.eta_eng = aircraft.manual_input.eta;
            else
                % use default
            end


            obj.eta_ov = obj.eta_eng * obj.eta_prop;

        end

        function obj = Engine_Iteration(obj,aircraft)
            
            %handle inputs

            if any(ismember(fields(aircraft.manual_input),'m_eng'))
                obj.m_eng = aircraft.manual_input.m_eng;
            else
                % use default
                obj = obj.calculate_mass(aircraft);
            end
            
            if any(ismember(fields(aircraft.manual_input),'eta'))
                obj.eta_eng = aircraft.manual_input.eta;
            else
                % use default
            end


            obj.eta_ov = obj.eta_eng * obj.eta_prop;

            
            % update eta for given tech levels
            obj = aircraft.tech.improve_eta(obj);
        end


        function obj = calculate_mass(obj, aircraft)
            obj.thrust_total = 0.3*(9.81* aircraft.weight.m_maxTO*1e-3);%kN % TODO: Assumming constant T/W of 0.3 
            
%             obj.bpr = 15.66;

            if any(ismember(fields(aircraft.manual_input),'bpr'))
                obj.bpr = aircraft.manual_input.bpr;
            else
                % use default
                obj.bpr = 8;
            end
            
            if any(ismember(fields(aircraft.manual_input),'number_engines'))
                obj.number_engines = aircraft.manual_input.number_engines;
            else
                % use default
                obj.number_engines = 2;
            end
            
            obj.thrust_eng = obj.thrust_total/obj.number_engines;

            eng_mass = obj.thrust_eng*(8.7+1.14*obj.bpr); % Jenkinson et al. method
            
            if obj.thrust_eng < 600
                nacelle = 6.8*obj.thrust_eng/9.81; % Jenkinson et al. approximation of nacelle weight if take-off thrust < 600 kN
            elseif obj.thrust_eng > 600
                nacelle = 2760 + 2.2*obj.thrust_eng/9.81; % Jenkinson et al. approximation of nacelle weight if take-off thrust > 600 kN
            end


%             if aircraft.weight.m_maxTO/120e3 < 1.1 && aircraft.weight.m_maxTO/120e3 > 0.9
%                 obj.number_engines = obj.number_engines;
%             else
%                 obj.number_engines = 2*ceil(aircraft.weight.m_maxTO/120e3);
%             end
            obj.m_eng = obj.number_engines*(eng_mass + nacelle); % Total engine weight (engine + nacelle) Unsure if this is per engine or overall??
            
            % update eta for given tech levels
            obj = aircraft.tech.improve_eta(obj);
        end
    end
end