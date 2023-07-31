function ac = designH2AC(ac_inputs, year, optimism)
    seats_abreast_array = ac_inputs.seats_abreast_array;
    ac_list = cell(size(seats_abreast_array));
    minFuel = 9999999;
    

    for i=1:length(seats_abreast_array)
        seats_abreast = seats_abreast_array(i);
    
        c = Convergence();
        c.conv_var = "Length Error";
        length_frac = 0.1;
        
        tank_type = "Cylindrical";
        c.conv_i = 1;
        diam_frac = 1.0;
        while abs(c.conv_err) > c.conv_margin && c.conv_i <= c.max_i
            if c.conv_i ~= 1
                
                length_frac = length_frac *  (1 - c.conv_err);
            end
            

            dimension = Dimension(ac_inputs.design_mission,seats_abreast,ac_inputs.N_deck,diam_frac,length_frac);
            dimension = dimension.finalise();

            if dimension.tank_external_length_i <= dimension.tank_external_diameter_i
                % set tank to spherical dimensions (%TODO:
                % add spherical tank function)
                length_frac = dimension.tank_external_diameter_i/dimension.cabin_length; % set tank length to the diameter of sphere
                dimension = Dimension(ac_inputs.design_mission,seats_abreast,ac_inputs.N_deck,1.0,length_frac);
                dimension = dimension.finalise(); % this is necessary to update fuselage length to new tank length
            end

            ac_inputs.ac = copy(sizeAC(ac_inputs, dimension, year, optimism, tank_type));
            
            c.conv_err = (ac_inputs.ac.tank.m_fuelMax - ac_inputs.ac.weight.m_Fuel)/ac_inputs.ac.tank.m_fuelMax;
            
            c.conv_i = c.conv_i +1;

            if (abs(dimension.tank_external_length_i - dimension.tank_external_diameter_i) < 1e-10  && c.conv_err > 0 )
                % this means that fuel required is less than the available
                % volume in a spherical tank that fills the available
                % fuselage diameter. Therefore, must reduce diameter of
                % spherical tank
                
                tank_type = "Spherical";
                disp('H2 Aircraft Design: Designing with Spherical Tanks')
                break
            end
        end

        % Sizing spherical tank
        if tank_type == "Spherical"
            c = Convergence();
            c.conv_var = "Diameter Error";
            diam_frac = 1.0;
            
            c.conv_i = 1;
           
            
            while abs(c.conv_err) > c.conv_margin && c.conv_i <= c.max_i
                if c.conv_i ~= 1
                    diam_frac = diam_frac *  (1 - c.conv_err)^(1/3);
                end
                
                if diam_frac > 1.0
                    warning("H2 Aircraft Design: Solution may not converge")
                    diam_frac = 1.0;
                end
                tank_diam = diam_frac * (dimension.fuselage_internal_diameter - 2*dimension.tank_tolerance);
                tank_length = tank_diam;
                length_frac = tank_length/dimension.cabin_length; % set tank length to the diameter of sphere
                
                dimension = Dimension(ac_inputs.design_mission,seats_abreast,ac_inputs.N_deck,diam_frac,length_frac);
                dimension = dimension.finalise();
                
                ac_inputs.ac = copy(sizeAC(ac_inputs, dimension, year, optimism, tank_type));
            
                c.conv_err = (ac_inputs.ac.tank.m_fuelMax - ac_inputs.ac.weight.m_Fuel)/ac_inputs.ac.tank.m_fuelMax;
            
                c.conv_i = c.conv_i +1;

            end
        end


        
        if abs(c.conv_err) < c.conv_margin && c.conv_i <= c.max_i
            c.conv_bool = 1;
            ac_list{i} = copy(ac_inputs.ac);
        else
            c.conv_bool = 0;
            warning('H2 Aircraft Design: Unable to find a solution for %.0f seats abreast', seats_abreast)
        end
    
        if ~isempty(ac_list{i}) && ac_list{i}.weight.m_Fuel<minFuel
            ac = copy(ac_list{i});
            minFuel = ac_inputs.ac.weight.m_Fuel;
        end

    end
    sprintf("H2 Solution Converged: %.0f seats abreast | %.2fm Fuse Length ",ac.dimension.seats_per_row, ac.dimension.fuselage_length)
end

function ac = sizeAC(ac_inputs, dimension, year, optimism, tank_type)

        % SETUP A FUEL TANK
            
        h2_tank = FuelTank(ac_inputs.fuel,ac_inputs.struct_material, ac_inputs.ins_material);
        h2_tank.fuelTankType = tank_type;
        h2_tank = h2_tank.finalise(dimension);
        
        % SETUP AN INSTANCE OF AIRCRAFT CLASS        
        ac = Aircraft(ac_inputs.fuel,ac_inputs.design_mission,dimension);
        
        ac.tank = copy(h2_tank);
        
        % handle ac inputs
        if any(ismember(fields(ac_inputs),'eta_eng'))
            ac.manual_input.eta_eng = ac_inputs.eta_eng;
        end
        if any(ismember(fields(ac_inputs),'number_engines'))
            ac.manual_input.number_engines = ac_inputs.number_engines;
        end
        if any(ismember(fields(ac_inputs),'m_eng'))
            ac.manual_input.m_eng = ac_inputs.m_eng;
        end
        if any(ismember(fields(ac_inputs),'eta_prop'))
            ac.manual_input.eta_prop = ac_inputs.eta_prop;
        end
        
        
        % update year
        ac.year = year;
        ac.optimism = optimism;
        
        % All inputs defined. Now for the aircraft sizing loop to begin to
        % calculate MTOW
        ac = ac.finalise();
end