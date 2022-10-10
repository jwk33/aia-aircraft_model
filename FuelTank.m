classdef FuelTank < handle
    %FuelTank object
    
    % set up fuel tank properties
    properties
        intLength(1,1) double {mustBeNonnegative, mustBeFinite} % interior. diameter if sphere
        intDiameter(1,1) double {mustBeNonnegative, mustBeFinite}
        fuelTankType (1,:) char {mustBeMember(fuelTankType,{'Cylinder', 'Sphere'})} = 'Cylinder';
        structure_thickness(1,1) double {mustBeNonnegative, mustBeFinite}
        insulation_thickness(1,1) double {mustBeNonnegative, mustBeFinite}
        structure_mass(1,1) double {mustBeNonnegative, mustBeFinite}
        insulation_mass(1,1) double {mustBeNonnegative, mustBeFinite}
        empty_mass(1,1) double {mustBeNonnegative, mustBeFinite}
        fuel_mass(1,1) double {mustBeNonnegative, mustBeFinite} % fuel mass (kg)
        gravimetric_efficiency
    end
    
    properties (SetAccess = immutable)
        useTankModel logical % Use tank model in weight determination - relevant
        % for new tank models (such as liquid hydrogen)
        fuel Fuel
        structural_material Material
        insulation_material Material
        
    end
    
    properties (SetAccess = private)
        t_total double {mustBeNonnegative, mustBeFinite}
        t_structure double {mustBeNonnegative, mustBeFinite}
        t_insulation double {mustBeNonnegative, mustBeFinite}
        m_empty double {mustBeNonnegative, mustBeFinite}
        m_structure double {mustBeNonnegative, mustBeFinite}
        m_insulation double {mustBeNonnegative, mustBeFinite}
    end
    
    properties (Constant)
        fusThickness = 120.0;
        excThickness = 450.0;
        intExtFactor = 0.98;
        safety_margin = 2.25;
        storage_pressure = 2.5;
        design_pressure = 3.4;
        
    end
    
    methods
        function obj = FuelTank(fuel,structural_material,insulation_material)
            arguments
                fuel Fuel;
                structural_material Material;
                insulation_material Material;
            end
            obj.fuel = fuel;
            obj.useTankModel = fuel.UseTankModel;
            obj.structural_material = structural_material;
            obj.insulation_material = insulation_material;
            
        end
        
        function obj = find_gravimetric_efficiency(obj)
            % percentage of fuel weight out of total weight of tank 
            obj.gravimetric_efficiency = 100 * obj.fuel_mass / (obj.fuel_mass + obj.empty_mass);
        end
        
        function obj = find_t_total(obj)
            % find total thickness of the tank (insulation + structural)
            obj.find_t_structure()
            obj.find_t_insulation()
            
            obj.t_total = obj.t_structure + obj.t_insulation;
        end
        
        function obj = find_m_empty(obj)
           % find total mass of the tank when empty
           obj.find_m_structure()
           obj.find_m_insulation()
           
           obj.m_empty = obj.m_structure + obj.m_insulation;
        end
        
        function obj = volume(obj)
            %calculate internal volume
            formatSpec = char("Tank Internal Volume:\t %.2f (m^2) \n");
            radius = obj.diameter / 2;
            caps_volume = 4*pi/3 * radius^3; % 2 hemispheres
            cylinder_length = obj.length - obj.diameter;
            cylinder_volume = cylinder_length * pi * radius^2;
            tank_volume = caps_volume + cylinder_volume;
            
            fprintf(formatSpec,tank_volume);
        end
        
        
        function obj = updateInteriorLength(obj, wf, tow, dt)
            arguments
                obj
                wf(1,1) double {mustBeInRange(wf,0,1)} % fuel fraction
                tow(1,1) double {mustBePositive, mustBeFinite} % take-off weight
                dt(1,1) double {mustBePositive, mustBeFinite} % tube diameter
            end
            % Update interior length of fuel tank, given aircraft param
            obj.intLength = obj.interiorLength(wf, tow, dt);
        end
        function wfr = weightFrac(obj, dt, wf)
            % obtain weight fraction of fuel tank
            arguments
                obj
                dt(1,1) double {mustBePositive, mustBeFinite}% Tube diameter (external)
                wf(1,1) double {mustBeInRange(wf,0,1)} % Fuel weight fraction
            end
            wfr = obj.fuelTankMass(dt, wf);
            
            if isnan(wfr)
                wfr = 0;
            end
        end
    end
    methods (Access = private)
        function df = interiorLength(obj, wf, tow, dt)
            % Find interior length of fuel, given aircraft parameters
            arguments
                obj;
                wf(1,1) double {mustBeInRange(wf,0,1)}; % Fuel weight/ MTOW
                tow(1,1) double {mustBePositive, mustBeFinite}; % take-off weight
                dt(1,1) double {mustBePositive, mustBeFinite}; % diameter of fuselage
            end
            rho = obj.fuel.density;
            val1 = (wf*tow*1000)/(2*rho);
            val2 = pi/6*((dt - 2*(obj.fusThickness + obj.excThickness)/1000 ...
                )*obj.intExtFactor)^3;
            if val1 > val2
                df = (val1 - val2)*4/(pi*((dt - 2*(obj.fusThickness ...
                    + obj.excThickness)/1000)*obj.intExtFactor)^2) ...
                    + (dt - 2*(obj.fusThickness ...
                    + obj.excThickness)/1000)*obj.intExtFactor;
            else
                df = (val1 * 6*pi)^(1/3);
            end
        end
        
        function obj = find_t_structure(obj)
            % find structural thickness required for pressure specification
            denominator = sqrt(1 - sqrt(3)*obj.design_pressure*0.1 / obj.structural_material.yield_stress);
            thickness = obj.diameter/2 * (1/denominator - 1)*obj.safety_margin; % m
            minimum_thickness = 7e-3;
            obj.t_structure = max(thickness, minimum_thickness);
        end
        
        function obj = find_m_structure(obj)
            
            % find structural mass given structural thickness
            
            L = obj.length;
            D = obj.diameter;
            t = obj.t_structure;
            R = D/2;
            rho = obj.structural_material.density;
            cylinder_mass = rho*(pi*((t+R)^2 - R^2))*(L-D);
            caps_mass = rho*4*pi/3 * ((t+R)^3 - R^3);
            obj.m_structure = cylinder_mass + caps_mass;
        end
        
        function obj = find_t_insulation(obj)
            % taken from MVM v4.4 'Tank Model' sheet
            
            % define properties
            Tliq = 23.9;            % K
            Tins = 280;             % K
            k_air = 0.026;          % W / m K
            k_wall = 0.5;           % W / m K
            k_ins = 1e-4;           % W / m K

            % calculate allowable heat transfer through insulation
            boil_off_rate = 0.05;   % percentage of contents per hour
            M_boil = boil_off_rate*obj.fuel_mass() / 100;     % kg / hour
            m_boil = M_boil / 3600; % kg / sec
            H_vap = 222700;         % J / kg
            Q_boil = m_boil * H_vap;% W

            % heat transfer calculation to find insulation thickness
            alpha = 2*pi*(Tins - Tliq)*obj.length/Q_boil;
            R = obj.diameter / 2;
            beta = (1/k_wall)*log((R + obj.t_structure)/R);
            gamma = alpha - beta;
            min_thickness = (R + obj.t_structure)*(exp(gamma*k_ins) - 1);

            obj.t_insulation = min_thickness * obj.safety_margin;
        end
        
        function obj = find_m_insulation(obj)
            D = obj.diameter;
            R = D / 2;   % m
            L = obj.length;
            t = obj.insulation_thickness;
            w_t = obj.wall_thickness;
            cylinder_mass = obj.insulation_material.density*pi*((R + w_t + t)^2 - (R + w_t)^2) * (L - D);
            caps_mass = obj.insulation_material.density*4*pi/3 * ((R + w_t + t)^3 - (R + w_t)^3);
            obj.m_insulation = cylinder_mass + caps_mass;
        end
        
        
        function fm = fuelTankMass(obj, dt, wf)
            % Obtain estimate of fuelTankMass
            arguments
                obj
                dt(1,1) double {mustBePositive, mustBeFinite} % Fuselage diameter
                wf(1,1) double {mustBeInRange(wf,0,1)}% Fuel weight/ MTOW weight
            end
            if obj.useTankModel
                if obj.intLength > dt
                    % cylinder
                    g = obj.gec(dt, obj.intLength);
                    fm = (1/g - 1)*wf;
                    obj.fuelTankType = 'Cylinder';
                else
                    % sphere
                    g = obj.ges(obj.intLength);
                    fm = (1/g - 1)*wf;
                    obj.fuelTankType = 'Sphere';
                end
            else
                fm = 0;
            end
        end
        
    end
end