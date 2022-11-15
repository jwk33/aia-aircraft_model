function ac = designH2AC(ac_inputs, year, optimism)
    struct_material = ac_inputs.struct_material;
    ins_material = ac_inputs.ins_material;
    fuel = ac_inputs.fuel;

    seats_abreast_array = ac_inputs.seats_abreast_array;
    ac_list = cell(size(seats_abreast_array));
    minFuel = 9999999;

    for i=1:length(seats_abreast_array)
        seats_abreast = seats_abreast_array(i);
    
        c = Convergence();
        c.conv_var = "Length Error";
        length_frac = 0.1;
        
        c.conv_i = 1;
        while abs(c.conv_err) > c.conv_margin && c.conv_i <= c.max_i
            if c.conv_i ~= 1
                
                length_frac = length_frac *  (1 - c.conv_err);
            end
        
            dimension = Dimension(ac_inputs.design_mission,seats_abreast,ac_inputs.N_deck,1.0,length_frac,0,0);
            dimension = dimension.finalise();

            if dimension.tank_external_length_i <= dimension.tank_external_diameter_i
                % set tank to spherical dimensions (%TODO:
                % add spherical tank function)

                length_frac = dimension.tank_external_diameter_i/dimension.cabin_length; % set tank length to the diameter of sphere
                dimension = Dimension(ac_inputs.design_mission,seats_abreast,ac_inputs.N_deck,1.0,length_frac,0,0);
                dimension = dimension.finalise();
            end

            % SETUP A FUEL TANK
            
            h2_tank = FuelTank(fuel,struct_material, ins_material);

            h2_tank = h2_tank.finalise(dimension);
            
            % SETUP AN INSTANCE OF AIRCRAFT CLASS        
            ac_inputs.ac = Aircraft(fuel,ac_inputs.design_mission,dimension);
        
            ac_inputs.ac.tank = h2_tank;
                
            ac_inputs.ac.manual_input.eta_eng = ac_inputs.eta_eng;
            ac_inputs.ac.manual_input.number_engines = ac_inputs.number_engines;
            
            % update year
            ac_inputs.ac.year = year;
            ac_inputs.ac.optimism = optimism;
            
            % All inputs defined. Now for the aircraft sizing loop to begin to
            % calculate MTOW
            ac_inputs.ac = ac_inputs.ac.finalise();
            
            c.conv_err = (ac_inputs.ac.tank.m_fuelMax - ac_inputs.ac.weight.m_Fuel)/ac_inputs.ac.tank.m_fuelMax;
            
            c.conv_i = c.conv_i +1;
        end
        
        if abs(c.conv_err) < c.conv_margin && c.conv_i <= c.max_i
            c.conv_bool = 1;
            ac_list{i} = copy(ac_inputs.ac);
        else
            c.conv_bool = 0;
        end
    
        if ~isempty(ac_list{i}) && ac_list{i}.weight.m_Fuel<minFuel
            ac = copy(ac_list{i});
            minFuel = ac_inputs.ac.weight.m_Fuel;
        end

    end
    sprintf("H2 Solution Converged: %.0f seats abreast | %.2fm Fuse Length ",ac.dimension.seats_per_row, ac.dimension.fuselage_length)
end