classdef FuelTank < handle
    %FuelTank object
    
    % set up fuel tank properties
    properties
        length_int(1,1) double {mustBeNonnegative, mustBeFinite} % interior. diameter if sphere
        length_ext(1,1) double {mustBeNonnegative, mustBeFinite}
        length_ext_max(1,1) double {mustBeNonnegative, mustBeFinite}
        diam_ext_max(1,1) double {mustBeNonnegative, mustBeFinite}
        diam_ext(1,1) double {mustBeNonnegative, mustBeFinite}
        diam_int(1,1) double {mustBeNonnegative, mustBeFinite}
        fuelTankType (1,:) char {mustBeMember(fuelTankType,{'Cylinder', 'Sphere'})} = 'Cylinder';
        
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
        fuel_mass(1,1) double {mustBeNonnegative, mustBeFinite} % fuel mass (kg)
        fuel_volume(1,1) double {mustBeNonnegative, mustBeFinite} % fuel volume (m3)
        t_total(1,1) double {mustBeNonnegative, mustBeFinite}
        t_structure(1,1) double {mustBeNonnegative, mustBeFinite}
        t_insulation(1,1) double {mustBeNonnegative, mustBeFinite}
        m_empty(1,1) double {mustBeNonnegative, mustBeFinite}
        m_structure(1,1) double {mustBeNonnegative, mustBeFinite}
        m_insulation(1,1) double {mustBeNonnegative, mustBeFinite}
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
        
        function obj = finalise(obj)
            % uses all input tank properties to work out structural and
            % insulation thickness + mass to get empty mass and gravimetric
            % efficiency
            
            % find internal diameter/length given external diameter
            obj.diam_int = obj.diam_ext_max;
            obj.length_int = obj.length_ext_max;

            obj.find_fuel_mass()
            obj.find_t_total()

            

            while obj.diam_ext > obj.diam_ext_max
                % update internal diameter so diam_ext matches diam_ext_max
                obj.diam_int = obj.diam_int*0.999;

                % find fuel volume and mass for given dimensions
                obj.find_fuel_mass()
                
                % find thicknesses
                obj.find_t_total()
                
                % update internal length to accomodate for the tank
                % thickness
                obj.length_int = obj.length_ext_max - 2*obj.t_total;
            end

            % find mass of insulation
            obj.find_m_structure()
            obj.find_m_insulation()

            % put it all together: calculate tank empty mass and
            % gravimetric efficiency
            obj.find_t_total()
            obj.find_m_empty()
            obj.find_gravimetric_efficiency()
        end


        function obj = find_gravimetric_efficiency(obj)
            % percentage of fuel weight out of total weight of tank 
            obj.gravimetric_efficiency = 100 * obj.fuel_mass / (obj.fuel_mass + obj.m_empty);
        end
        
        
        
        function obj = volume(obj)
            %calculate internal volume
            formatSpec = char("Tank Internal Volume:\t %.2f (m^2) \n");
            radius = obj.diam_int / 2;
            caps_volume = 4*pi/3 * radius^3; % 2 hemispheres
            cylinder_length = obj.length_int - obj.diam_int;
            cylinder_volume = cylinder_length * pi * radius^2;
            obj.fuel_volume = caps_volume + cylinder_volume;
            
            fprintf(formatSpec,obj.fuel_volume);
        end
       
    end
    methods (Access = private)

        function obj = find_fuel_mass(obj)
            % calculate fuel mass from tank volume
            obj.volume()
            obj.fuel_mass = obj.fuel.density * obj.fuel_volume;
        end
        
        function obj = find_t_total(obj)
            % find total thickness of the tank (insulation + structural)
            obj.find_t_structure()
            obj.find_t_insulation()
            
            obj.t_total = obj.t_structure + obj.t_insulation;

            % update external dimensions
            obj.length_ext = obj.length_int + 2*obj.t_total;
            obj.diam_ext = obj.diam_int + 2*obj.t_total;
        end
        
        function obj = find_m_empty(obj)
           % find total mass of the tank when empty
           obj.find_m_structure()
           obj.find_m_insulation()
           
           obj.m_empty = obj.m_structure + obj.m_insulation;
        end

        function obj = find_t_structure(obj)
            % find structural thickness required for pressure specification
            denominator = sqrt(1 - sqrt(3)*obj.design_pressure*0.1 / obj.structural_material.yield_strength);
            thickness = obj.diam_int/2 * (1/denominator - 1)*obj.safety_margin; % m
            minimum_thickness = 7e-3;
            obj.t_structure = max(thickness, minimum_thickness);
        end
        
        function obj = find_m_structure(obj)
            
            % find structural mass given structural thickness
            
            L = obj.length_int;
            D = obj.diam_int;
            t = obj.t_structure;
            R = D/2;
            rho = obj.structural_material.density;
            cylinder_mass = rho*(pi*((t+R)^2 - R^2))*(L-D);
            caps_mass = rho*4*pi/3 * ((t+R)^3 - R^3);   % mass of hemisphere
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
            alpha = 2*pi*(Tins - Tliq)*obj.length_int/Q_boil;
            R = obj.diam_int / 2;
            beta = (1/k_wall)*log((R + obj.t_structure)/R);
            gamma = alpha - beta;
            min_thickness = (R + obj.t_structure)*(exp(gamma*k_ins) - 1);

            obj.t_insulation = min_thickness * obj.safety_margin;
        end
        
        function obj = find_m_insulation(obj)
            D = obj.diam_int;
            R = D / 2;   % m
            L = obj.length_int;
            t = obj.t_insulation;
            w_t = obj.t_structure;
            cylinder_mass = obj.insulation_material.density*pi*((R + w_t + t)^2 - (R + w_t)^2) * (L - D);
            caps_mass = obj.insulation_material.density*4*pi/3 * ((R + w_t + t)^3 - (R + w_t)^3);
            obj.m_insulation = cylinder_mass + caps_mass;
        end
        
    end
end