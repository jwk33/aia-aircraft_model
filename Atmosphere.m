classdef Atmosphere < matlab.mixin.Copyable 
    %Atmosphere object with information on tempurature, density, speed of
    %sound, and pressure
    
    % define atmosphere for flight
    properties (SetAccess = immutable)
        M(1,1) double % Mach number
        altitude(1,1) double % Altitude in m
        FL(1,1) double % flight level in 100ft
        T(1,1) double % Temperature %K
        rho(1,1) double % Density %kg/m3
        sos(1,1) double %Speed of Sound %m/s
        P(1,1) double % Pressure %Pa
        nu(1,1) double % Kinematic viscosity %m2/s
        
        V(1,1) double % Velocity %m/s
    end

    properties (Constant)
        p_sl = 101.325e3; %Pa
        t_sl = 273.15 + 15; %K
        rho_sl = 1.225; %kg/m3
        nu_sl = 14.64e-5; %m2/s
        a_sl = 340; %m/s
    end
    
    methods
        function obj = Atmosphere(altitude, M)
            % Initialise an Atmosphere Object. For a given altitude and Mach No. 
            % calculates atmospheric parameters like:
            % 
            % Temperature           ( T   ) : K
            % Density               ( rho ) : kg/m3
            % Speed of sound        ( sos ) : m/s
            % Pressure              ( p   ) : Pa
            % Kinematic Viscosity   ( nu  ) : m2/s
            % Velocity              ( V   ) : m/s
            % Flight Level          ( FL  ) : 100ft
            
            arguments
                altitude(1,:) double % m
                M (1,1)       double {mustBeInRange(M, 0,1)}% 
            end

            load("isa_table.mat", "isa_table")

            
            obj.altitude = altitude;
            obj.M = M;

            alt_m = isa_table.alt_m; % Altitude array in m
            p_array = obj.p_sl .* isa_table.p_frac;
            t_array = isa_table.T;
            rho_array = obj.rho_sl .* isa_table.rho_frac;
            nu_array = obj.nu_sl .* isa_table.nu_frac;
            sos_array = isa_table.v_s;

            obj.P = interp1(alt_m, p_array, altitude);
            obj.T = interp1(alt_m, t_array, altitude);
            obj.rho = interp1(alt_m, rho_array, altitude);
            obj.sos = interp1(alt_m, sos_array, altitude);
            obj.nu = interp1(alt_m, nu_array, altitude);

            obj.FL = obj.altitude * 3.281/100;
            obj.V = obj.M * obj.sos;

            kvisc = (0.1456e-5)*(obj.T^0.5)/(1 + 110/obj.T);
            obj.nu = kvisc/obj.rho;


        end

        function [dyn_pressure, nu] = atmos_dynP(obj, speed)
            arguments
                obj Atmosphere
                speed (1,1) double = obj.V
            end
            nu = obj.nu;
            dyn_pressure = 0.5 * obj.rho * speed ^2;
        end

        function h = atmospalt_isa(p)
            %Returns altitude h in m for a given pressure
            %   Detailed explanation goes here
            p0 = 101.325e3; %MPa
            
            load("isa_table.mat", "isa_table")
            
            p_array = p0 .* isa_table.p_frac;
            alt_m = isa_table.alt_m;
            
            h = interp1(p_array,alt_m,  p);
        end
    end
end