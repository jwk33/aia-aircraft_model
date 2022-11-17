classdef FuelTank < matlab.mixin.Copyable
    %FuelTank object
    
    % set up fuel tank properties
    properties
        length_int(1,1) double {mustBeNonnegative, mustBeFinite} % interior. diameter if sphere
        length_ext(1,1) double {mustBeNonnegative, mustBeFinite}
        diam_ext(1,1) double {mustBeNonnegative, mustBeFinite}
        diam_int(1,1) double {mustBeNonnegative, mustBeFinite}
        fuelTankType (1,:) char {mustBeMember(fuelTankType,{'Cylindrical', 'Spherical'})} = 'Cylindrical';
        gravimetric_efficiency(1,1) double {mustBeNonnegative, mustBeFinite}
        m_tank(1,1) double {mustBeNonnegative, mustBeFinite}
    end
    
    properties (SetAccess = immutable)
        useTankModel logical % Use tank model in weight determination - relevant
        fuel Fuel
        structural_material Material
        insulation_material Material
    end
    
    properties (SetAccess = private)
        m_fuelMax(1,1) double {mustBeNonnegative, mustBeFinite} % fuel mass (kg)
        v_fuelMax(1,1) double {mustBeNonnegative, mustBeFinite} % fuel volume (m3)
        t_total(1,1) double {mustBeNonnegative, mustBeFinite}
        t_structure(1,1) double {mustBeNonnegative, mustBeFinite}
        t_insulation(1,1) double {mustBeNonnegative, mustBeFinite}
        m_empty(1,1) double {mustBeNonnegative, mustBeFinite}
        m_structure(1,1) double {mustBeNonnegative, mustBeFinite}
        m_insulation(1,1) double {mustBeNonnegative, mustBeFinite}
    end
    
    properties (Constant)
        fusThickness = 120.0; % TODO: Not needed
        excThickness = 450.0; % TODO: Not needed
        intExtFactor = 0.98; % TODO: Not needed
        safety_margin = 2.25;
        storage_pressure = 0.25e6;%Pa
        design_pressure = 0.34e6;%Pa
    end
    
    methods
        function obj = FuelTank(fuel,struct_material,ins_material)
            obj.useTankModel = fuel.UseTankModel;
            obj.fuel = fuel;
            obj.structural_material = struct_material;
            obj.insulation_material = ins_material;
            

            
        end
        
        function obj = finalise(obj, dimension)
            obj.length_ext = dimension.tank_external_length_i;
            obj.diam_ext = dimension.tank_external_diameter_i;
            
            % for first iteration, assume internal equal to external
            % dimensions

            obj.length_int = obj.length_ext;
            obj.diam_int = obj.diam_ext;

            % put it all together: calculate tank empty mass and
            % gravimetric efficiency
            for i=1:2 % TODO: while loop to ensure thickness has converged
                obj.find_fuel_mass();
                obj.find_t_total();
            end
            obj.find_m_empty();
            obj.find_gravimetric_efficiency();
            obj.m_tank = obj.m_empty; %tonnes
        end
       
        function obj = find_gravimetric_efficiency(obj)
            % percentage of fuel weight out of total weight of tank 
            obj.gravimetric_efficiency = 100 * obj.m_fuelMax / (obj.m_fuelMax + obj.m_empty);
        end
        
        
        
        function obj = volume(obj)
            %calculate internal volume (assume the same as external as thin
            %walls
            %formatSpec = char("Tank Internal Volume:\t %.2f (m^2) \n");
            radius = obj.diam_int / 2;
            caps_volume = 4*pi/3 * radius^3; % 2 hemispheres
            if obj.fuelTankType == "Cylindrical"
                cylinder_length = obj.length_int - obj.diam_int;
                cylinder_volume = cylinder_length * pi * radius^2;
            elseif obj.fuelTankType == "Spherical"
                cylinder_volume = 0;
            else
                warning('fuelTankType unknown %s',obj.fuelTankType)
            end
            obj.v_fuelMax = caps_volume + cylinder_volume;
            
%             fprintf(formatSpec,obj.fuel_volume);
        end
       
    end
    methods (Access = private)

        function obj = find_fuel_mass(obj)
            % calculate fuel mass from tank volume
            obj.volume();
            obj.m_fuelMax = obj.fuel.density * obj.v_fuelMax;
        end
        
        function obj = find_t_total(obj)
            % find total thickness of the tank (insulation + structural)
            obj.find_t_structure();
            obj.find_t_insulation();
            
            obj.t_total = obj.t_structure + obj.t_insulation;

            %update internal dimensions
            obj.length_int = obj.length_ext - 2*obj.t_total;
            obj.diam_int = obj.diam_ext - 2*obj.t_total;
        end
        
        function obj = find_m_empty(obj)
           % find total mass of the tank when empty
           obj.find_m_structure();
           obj.find_m_insulation();
           
           obj.m_empty = obj.m_structure + obj.m_insulation;
        end

        function obj = find_t_structure(obj)
            % find structural thickness required for pressure specification
            minimum_thickness = 1.5e-3;
            % assuming t = A*R_internal, equation can be re-arranged to be
            % t = A/(1+A) * R_external where R_external = R_internal + t
            R_ext = obj.diam_ext/2; % External radius
            P = obj.design_pressure; % Design pressure
            E_struct = obj.structural_material.yield_strength; % Yield strength of structural material
            
            if obj.fuelTankType == "Cylindrical"
                Acc = P/(E_struct - 0.6*P); %cylindrical shell resisting circumferential stresses
                Acl = P/(2*E_struct + 0.4*P );%cylindrical shell resisting longitudinal stresses
            elseif obj.fuelTankType == "Spherical"
                Acc = 0;
                Acl = 0;
            end

            Ah  = P/(2*E_struct - 0.2*P);%spherical shell resisting circumferential stresses
            
            tcc = Acc/(1+Acc) * R_ext * obj.safety_margin;%m
            tcl = Acl/(1+Acl) * R_ext * obj.safety_margin;%m 
            th  = Ah/(1+Ah) * R_ext * obj.safety_margin;%m 
            %http://docs.codecalculation.com/mechanical/pressure-vessel/thickness-calculation.html
            obj.t_structure = max([minimum_thickness,tcc,tcl,th]);
            %A larger diamter for constant everything else increases the
            %thickness, therefore it is fine to calculate this and then
            %shrink the tank down in size but keep the same thickness.

        end
        
        function obj = find_m_structure(obj)
            
            % find structural mass given structural thickness
            
            L = obj.length_int;
            D = obj.diam_int;
            t = obj.t_structure;
            R = D/2;
            rho = obj.structural_material.density;
            if obj.fuelTankType == "Cylindrical"
                cylinder_mass = rho*(pi*((t+R)^2 - R^2))*(L-D);

            elseif obj.fuelTankType == "Spherical"
                cylinder_mass = 0;
            end
            caps_mass = rho*4*pi/3 * ((t+R)^3 - R^3);   % mass of hemisphere
            obj.m_structure = cylinder_mass + caps_mass;
        end
        
        function obj = find_t_insulation(obj)
            % taken from MVM v4.4 'Tank Model' sheet
            
            % define properties
            Tliq = 23.9;            % K
            Tins = 280;             % K
            
            k_wall = obj.structural_material.thermal_conductivity;           % W / m K
            k_ins = obj.insulation_material.thermal_conductivity;           % W / m K

            % calculate allowable heat transfer through insulation
            boil_off_rate = 0.02;   % percentage of contents per hour
            M_boil = boil_off_rate*obj.m_fuelMax / 100;     % kg / hour
            m_boil = M_boil / 3600; % kg / sec
            H_vap = 222700;         % J / kg
            Q_boil = m_boil * H_vap;% W

%             % heat transfer calculation to find insulation thickness
%             alpha = 2*pi*(Tins - Tliq)*obj.length_int/Q_boil;
%             R = obj.diam_int / 2 + obj.t_structure;
            R = obj.diam_ext / 2 ;
%             beta = (1/k_wall)*log((R + obj.t_structure)/R);
%             gamma = alpha - beta;
%             min_thickness = (R + obj.t_structure)*(exp(gamma*k_ins) - 1);
% 
%             obj.t_insulation = min_thickness * obj.safety_margin;

            syms t
            eqn = t == (R-t)*(exp(2*pi*k_ins*(Tins - Tliq)*(obj.length_ext-obj.t_structure-t)/Q_boil - (k_ins/k_wall)*log((R - t)/(R - t - obj.t_structure)))-1);
            obj.t_insulation = vpasolve(eqn,t,obj.t_structure);
        end
        
        function obj = find_m_insulation(obj)
            D = obj.diam_int; % internal diameter
            R = D / 2;   % m
            L = obj.length_int;
            t = obj.t_insulation;
            t_struct = obj.t_structure;
            
            if obj.fuelTankType == "Cylindrical"
                cylinder_vol = pi*((R + t_struct + t)^2 - (R + t_struct)^2) * (L - D);
            elseif obj.fuelTankType == "Spherical"
                cylinder_vol = 0;
            end
            caps_vol = 4*pi/3 * ((R + t_struct + t)^3 - (R + t_struct)^3);
            v_insulation = cylinder_vol + caps_vol;
            obj.m_insulation = v_insulation * obj.insulation_material.density;
        end
        
    end
end