classdef Aero
    %Holds information about the wing weight, structure and aircraft aerodynamics 

    properties (SetAccess = public)
        m_wing(1,1) double {mustBeNonnegative, mustBeFinite} % Mass of wing tonnes
        LovD(1,1) double {mustBeNonnegative, mustBeFinite} % Aircraft Lift to Drag
        AR(1,1) double {mustBeNonnegative, mustBeFinite} %Wing Aspect Ratio
        b(1,1) double {mustBeNonnegative, mustBeFinite} %Wingspan
        toc(1,1) double {mustBeNonnegative, mustBeFinite} %Thickness over Chord
        S(1,1) double {mustBeNonnegative, mustBeFinite} %Wing area (excluding fuselage)
        mac(1,1) double {mustBeNonnegative, mustBeFinite} %Mean Absolute Chord
        root_c(1,1) double {mustBeNonnegative, mustBeFinite} %Root Chord
        Sweep(1,1) double {mustBeNonnegative, mustBeFinite} %wing sweep angle degrees
        C_L(1,1) double {mustBeNonnegative, mustBeFinite} %Wing Coefficient of Lift
        wing_loading(1,1) double {mustBeNonnegative, mustBeFinite} %Wing loading
        C_D(1,1) double {mustBeNonnegative, mustBeFinite} % Coefficient of drag ffor aircraft normalised to wing area
    end

    methods
        function obj = Aero(mission,dimension)
            %UNTITLED5 Construct an instance of this class
            [T,sos,P,rho] = atmosisa(mission.cruise_alt);
            dyn_pressure = 0.5 * rho * mission.cruise_speed^2;
            if mission.range*0.02 - 19.79 > 30
                m_maxTO = mission.range*0.02 - 19.79;
            else
                m_maxTO = 30;
            end
            m_maxTO = 1000;
            obj.LovD = 16;
            obj.AR = 14;
            obj.b = dimension.fuselage_length*(((m_maxTO)^2)*4e-6 - 0.002*m_maxTO + 1.0949);
            obj.toc = 0.15;
            obj.mac = obj.b/5;
            obj.root_c = obj.b/obj.AR;
            obj.Sweep = 25;
            obj.C_L = 0.5;
            obj.S = m_maxTO*1000 * 9.81 / obj.C_L / dyn_pressure;
            obj.wing_loading = m_maxTO*1000/obj.S;%kg/m2
            obj.m_wing = 0.86 / 9.81^0.5 * (obj.AR^2 / obj.wing_loading^3 * m_maxTO*1000)^0.25 * m_maxTO;
            obj.C_D = obj.C_L/obj.LovD;
        end

        function obj = Aero_Iteration(obj,a)
            %Iterate using the parameters to get the updated Aero numbers
            %Any properties here not updated are assumed constant = 
            %toc, sweep, C_L
            %Initial Variables
            m_avg = (a.weight.m_maxTO + a.weight.m_OEW)/2;
            %Get Atmospheric Data
            [T,sos,P,rho] = atmosisa(a.mission.cruise_alt);
            dyn_pressure = 0.5 * rho * a.mission.cruise_speed^2;
            
            %Calculate Wing Performance
            obj.S = m_avg*1000*9.81/obj.C_L/dyn_pressure;
            b_ker = a.dimension.fuselage_length*(((a.weight.m_maxTO)^2)*4e-6 - 0.002*a.weight.m_maxTO + 1.0949);%empirical relationship based on data for wingspan to length ratios for different MTOWs
            obj.b = b_ker*(1-(3/400)*(11+0.064*a.weight.m_maxTO));
            obj.AR = (obj.b^2)/obj.S;
            old_mac = obj.mac;
            obj.mac = obj.b/obj.AR;
            obj.root_c = obj.root_c*obj.mac/old_mac;%assumes that the ratio of mac to root chord is constant, could also include a relationship based on AR?
        
            %%%% DERIVED CONSTANTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            S_wet_w = obj.S*3; %wetted surface area of the wing %%%changed to 3 to include the tail and horiz stabiliser
            S_wet_f = pi*a.dimension.fuselage_diameter*a.dimension.fuselage_length; %fuselage wetted surface area
            S_ref = obj.S + obj.root_c*a.dimension.fuselage_diameter; %Reference area
        
            %%%% CALCULATE INCOMPRESSIBLE DRAG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Correlations from David Barton's report
        
            %Empirical correlations from Civil Jet Aircraft Design. Reynolds number
            %for the wing based on mean chord, and for the fuselage based on length
        
            %Slight error compared to DBs calculation, unsure why
            c_d_0_w = cf(obj.mac,a.mission.cruise_speed) * 1.4 * (1 + cosd(obj.Sweep)^2 * (3.3 * obj.toc - 0.008 * obj.toc^2 + 27 * obj.toc^3)) * (S_wet_w / S_ref);
            c_d_0_f = cf(a.dimension.cabin_length,a.mission.cruise_speed) * (1 + 2.2 * (a.dimension.cabin_length / a.dimension.fuselage_diameter)^(-1.5) - 0.9 * (a.dimension.cabin_length / a.dimension.fuselage_diameter)^(-3)) * (S_wet_f / S_ref);
        
            c_d_0 = c_d_0_w + c_d_0_f;
            
            k_viscous = 0.38 * c_d_0;
            k_inviscid = 1 / (0.99 * (1 - 2 * (a.dimension.fuselage_diameter / obj.b)^2));
            k1 = k_inviscid / (pi*obj.AR) + k_viscous;
            k2 = 0;
        
            c_d_incompressible = c_d_0 + k2 * obj.C_L + k1 * obj.C_L^2;
        
            %%%% CALCULATE COMPRESSBILE DRAG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
            %Modified Korn equation
            c_d_compressible = 20 * (a.mission.M - obj.M_crit())^4;
        
            obj.C_D = c_d_incompressible + c_d_compressible;

            %Wing Mass Calcs
            obj.wing_loading = a.weight.m_maxTO*1000/obj.S;%kg/m2
            obj.m_wing = 0.86 / 9.81^0.5 * (obj.AR^2 / obj.wing_loading^3 * a.weight.m_maxTO*1000)^0.25 * a.weight.m_maxTO;
            obj.LovD = obj.C_L/obj.C_D;
            %%%%%% MANUAL OVERRIDE to set L/D = 17 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %a.c_d = a.c_l / 17; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
        
        function critical_mach_no = M_crit(obj)
        %function to calculate drag coefficient based on diameter, length, lift
            %coefficient and Mach number
            
            %%%% CALCULATE M_crit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            M_dd = 0.95/cosd(obj.Sweep) - obj.toc/(cosd(obj.Sweep)^2) - obj.C_L/(10*cosd(obj.Sweep)^3);
            critical_mach_no = M_dd - 0.1;
        end
    end
end