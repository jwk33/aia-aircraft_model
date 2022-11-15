classdef Aero
    %Holds information about the wing weight, structure and aircraft aerodynamics 

    properties (SetAccess = public)
        LovD(1,1) double {mustBeNonnegative, mustBeFinite} = 16 % Aircraft Lift to Drag
        AR(1,1) double {mustBeNonnegative, mustBeFinite} = 10 %Wing Aspect Ratio
        b(1,1) double {mustBeNonnegative, mustBeFinite} %Wingspan
        toc(1,1) double {mustBeNonnegative, mustBeFinite}  = 0.15 %Thickness over Chord
        S(1,1) double {mustBeNonnegative, mustBeFinite} %Wing area (excluding fuselage)
        mac(1,1) double {mustBeNonnegative, mustBeFinite} %Mean Absolute Chord
        root_c(1,1) double {mustBeNonnegative, mustBeFinite} %Root Chord
        sweep(1,1) double {mustBeNonnegative, mustBeFinite} = 30 %wing sweep angle degrees
        C_L(1,1) double {mustBeNonnegative, mustBeFinite} %Wing Coefficient of Lift
        wing_loading(1,1) double {mustBeNonnegative, mustBeFinite} %Wing loading
        C_D(1,1) double {mustBeNonnegative, mustBeFinite} % Coefficient of drag for aircraft normalised to wing area
        M_c(1,1) double
        m_wing (1,1) double
    end

    methods
        function obj = Aero(aircraft)
            %Construct an instance of an AERO class
            [dyn_pressure, nu] = atmos_calc(obj, aircraft.design_mission.cruise_alt, aircraft.design_mission.cruise_speed);
            
            % Handle inputs
            m_TO = aircraft.weight.m_TO;

            if any(ismember(fields(aircraft.manual_input),'AR'))
                obj.AR = aircraft.manual_input.AR;
            else
                % use default
                %disp(obj.AR);
            end
            
            if any(ismember(fields(aircraft.manual_input),'sweep'))
                obj.sweep = aircraft.manual_input.sweep;
            else
                % use default
                %disp(obj.sweep);
            end

            if any(ismember(fields(aircraft.manual_input),'wing_area'))
                obj.S = aircraft.manual_input.wing_area;
                obj.wing_loading = m_TO/obj.S;
            else
                % use default
                obj.wing_loading = 650; %kg/m2
                obj.S = m_TO/obj.wing_loading;
            end

            
            obj.b = sqrt(obj.S*obj.AR);
            obj.root_c = obj.b/obj.AR; 
            obj.mac = obj.S/obj.b;
            obj.C_L = m_TO * 9.81 / (obj.S * dyn_pressure);
            obj.C_D = obj.C_L/obj.LovD;

            % update L/D for given technology levels
            obj = aircraft.tech.improve_LoD(obj);

            % update wing mass
            obj = obj.calculate_mass(aircraft);
        end

        function obj = Aero_Iteration(obj,aircraft)
            %Iterate using the parameters to get the updated Aero numbers
            %Any properties here not updated are assumed constant = 
            %toc, sweep, C_L
            %Initial Variables
%             m_avg = (aircraft.weight.m_maxTO + aircraft.weight.m_OEW+aircraft.weight.m_max_payload)/2;
            m_TO = aircraft.weight.m_TO;
            
            %Get Atmospheric Data
            [dyn_pressure, nu] = atmos_calc(obj, aircraft.design_mission.cruise_alt, aircraft.design_mission.cruise_speed);
            
            %Calculate Wing Performance
            obj.C_L = m_TO*9.81/obj.S/dyn_pressure;
           
%             S_tail = obj.S*aircraft.weight.m_tail/aircraft.weight.m_wing;
            %%%% DERIVED CONSTANTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            S_wet_w = obj.S*3; %wetted surface area of the wing %%%changed to 3 to include the tail and horiz stabiliser
            S_wet_f = pi*aircraft.dimension.fuselage_diameter*aircraft.dimension.fuselage_length; %fuselage wetted surface area
            S_ref = obj.S + obj.root_c*aircraft.dimension.fuselage_diameter; %Reference area
        
            %%%% CALCULATE INCOMPRESSIBLE DRAG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Correlations from David Barton's report
        
            %Empirical correlations from Civil Jet Aircraft Design. Reynolds number
            %for the wing based on mean chord, and for the fuselage based on length
        
            %Slight error compared to DBs calculation, unsure why
            c_d_0_w = cf(obj.mac,aircraft.design_mission.cruise_speed,nu) * 1.4 * (1 + cosd(obj.sweep)^2 * (3.3 * obj.toc - 0.008 * obj.toc^2 + 27 * obj.toc^3)) * (S_wet_w / S_ref);
            c_d_0_f = cf(aircraft.dimension.cabin_length,aircraft.design_mission.cruise_speed,nu) * (1 + 2.2 * (aircraft.dimension.cabin_length / aircraft.dimension.fuselage_diameter)^(-1.5) - 0.9 * (aircraft.dimension.cabin_length / aircraft.dimension.fuselage_diameter)^(-3)) * (S_wet_f / S_ref);
        
            c_d_0 = c_d_0_w + c_d_0_f;
            
            k_viscous = 0.38 * c_d_0;
            k_inviscid = 1 / (0.99 * (1 - 2 * (aircraft.dimension.fuselage_diameter / obj.b)^2));
            k1 = k_inviscid / (pi*obj.AR) + k_viscous;
            k2 = 0;
        
            c_d_incompressible = c_d_0 + k2 * obj.C_L + k1 * obj.C_L^2;
        
            %%%% CALCULATE COMPRESSBILE DRAG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
            %Modified Korn equation
            obj.M_c = obj.M_crit();
            if aircraft.design_mission.M < 0.8*obj.M_crit()
                c_d_compressible = 0;
            else
                c_d_compressible = 20 * (aircraft.design_mission.M - obj.M_crit())^4;
            end

            obj.C_D = c_d_incompressible + c_d_compressible;

            %Wing Mass Calcs
            if any(ismember(fields(aircraft.manual_input),'wing_area'))
                % assuming wing area is constant across iterations
                obj.wing_loading = m_TO/obj.S;
            else
                % assuming wing area varies with m_maxTO with iterations
                obj.wing_loading = 650; %kg/m2
                obj.S = m_TO/obj.wing_loading;
            end



            obj.LovD = obj.C_L/obj.C_D;
            %%%%%% MANUAL OVERRIDE to set L/D = 17 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %a.c_d = a.c_l / 17; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % update L/D for given technology levels
            obj = aircraft.tech.improve_LoD(obj);

            

            % update wing mass
            obj = obj.calculate_mass(aircraft);
        end
        
        
        function critical_mach_no = M_crit(obj)
        %function to calculate drag coefficient based on diameter, length, lift
            %coefficient and Mach number
            
            %%%% CALCULATE M_crit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            M_dd = 0.95/cosd(obj.sweep) - obj.toc/(cosd(obj.sweep)^2) - obj.C_L/(10*cosd(obj.sweep)^3);
            critical_mach_no = M_dd - (0.02/80)^(1/3);
        end
    end

    methods (Access = private)
        function [dyn_pressure, nu] = atmos_calc(obj, cruise_alt, cruise_speed)
            % calculate dynamic pressure
            [T,sos,P,rho] = atmosisa(cruise_alt);
            kvisc = (0.1456e-5)*(T^0.5)/(1 + 110/T);
            nu = kvisc/rho;
            dyn_pressure = 0.5 * rho * cruise_speed^2;
        end 
        
        function obj = calculate_mass(obj, aircraft)
            taper = 0.35;
            n_ult = 3.75;
            eta_cp = 0.36*((1+taper)^0.5);
            if ~aircraft.fuel.UseTankModel
                %disp("Bending reduction")
                m_gross = (aircraft.weight.m_maxTO * aircraft.weight.m_maxZFW)^0.5;
            else
                %disp("Max bending")
                m_gross = (aircraft.weight.m_maxTO);
            end
            %m_gross = aircraft.weight.m_maxTO;
            
            %obj.m_wing = (0.0013*n_ult) * m_gross * (eta_cp*obj.b/100) * (obj.AR/(obj.toc*(cosd(obj.sweep)^2))) + 210*obj.S/9.81;
            obj.m_wing = 0.86/sqrt(9.81) * (obj.AR^2/obj.wing_loading^3*m_gross)^(1/4) * aircraft.weight.m_maxTO;
        end


    end
end