%% Make a PR diagram for a given aircraft
close all
clear all

ranges_tested = 3000:500:15000;
output_cell2 = cell(5,length(ranges_tested));
output_cell3 = cell(5,length(ranges_tested));

for f = 1:length(ranges_tested)
    %% use this space to setup the aircraft
    range = ranges_tested(f);
    passengers = ceil(0.031894*range +55);
    year = 2021;
    
    
    
    
    
    %% Ignore all code below this point except:
    %% Fiddle in the next section with the exact parameters of the aircraft
    %% Fiddle with the graph plotting in the last section
    %load constants
    load("Fuels\Ker.mat","Ker")
    load("Fuels\LH2.mat","LH2")
    
    % define tank structural material
    load("Materials\Aluminium.mat", "aluminium")
    struct_material = aluminium;
    
    
    % define tank insulation material
    load("Materials\MLI.mat", "MLI")
    ins_material = MLI;
    
    cruise_alt = 10000; %m
    
    %% Aircraft Size Dependent Inputs
    % Short haul
    SH = {};
    SH.range = range;
    
     
    if passengers >= 157
        SH.m_cargo = 26917*log(passengers) - 136030;
        SH.M = 0.77313 + passengers*9.375*10^(-5);
    else
        SH.m_cargo = 0;
        SH.M = 0.78;
    end
    
    if passengers>=300
        SH.eta_eng = 0.5;
    else
        SH.eta_eng = 0.45 + passengers*1.66666666*10^(-4);
    end
    
    if passengers <= 180
        SH.seats_per_row = 6;
    elseif passengers >= 500
        SH.seats_per_row = 10;
    else
     SH.seats_per_row = floor(0.0125*passengers+4);
    end
    
    SH.max_pax = passengers;
    % SH.m_eng = 5000;
    % SH.M = 0.79;
    % SH.m_cargo = 2726; %2500;
    SH.eta_prop = 0.8;
    % SH.eta_eng = 0.4;
    SH.number_engines = 2;
    
    % SH.seats_per_row = 6;
    SH.N_deck = 1;
%     SH.seats_abreast_array = [4,5,6,7,8,9];
    SH.seats_abreast_array = SH.seats_per_row;
    
    
    SH.design_mission = Mission(SH.range,SH.M,cruise_alt, SH.max_pax, 1.0, SH.m_cargo);
    % 
    % MH = {};
    % MH.range = 3900;
    % MH.M = 0.79;
    % MH.m_cargo = 2726; %2500;
    % MH.max_pax = 180;
    % MH.eta_eng = 0.4;
    % MH.number_engines = 2;
    % MH.m_eng = 5000;
    % MH.eta_prop = 0.8;
    % 
    % MH.seats_per_row = 6;
    % MH.N_deck = 1;
    % MH.seats_abreast_array = [4,5,6,7,8,9];
    
    
    % MH.design_mission = Mission(MH.range,MH.M,cruise_alt, MH.max_pax, 1.0, MH.m_cargo);
    size_inputs.SH = SH;
    % size_inputs.MH = MH;
    size_initials = fieldnames(size_inputs);
    
    %Generate Kerosene Aircraft 
    %NOTE: Fuel is immutable so aircraft instance cannot be shared across fuels
    Ker_group = {};
    
    for el=1:length(size_initials)
        size = char(size_initials(el));
        Ker_group.(size) = size_inputs.(size);
    end
    %Generate Hydrogen Aircraft
    LH2_group = {};
    
    for el=1:length(size_initials)
        size = char(size_initials(el));
        LH2_group.(size) = size_inputs.(size);
    end
    
    %Clear Unused Variables
    clear size
    clear size_initials
    clear size_inputs
    clear cruise_alt
    clear aluminium
    clear MLI
    clear el
    clear SH
    clear MH
    
    %% Which Cases to run you can edit these and have arrays or just single examples. ie you can look at all years
    load_factor_array = 0:0.02:1;%Leave this alone
    aircraft_array = "Short Haul";%leave this alone
    
    % year_array = [2021, 2035, 2050];
    year_array = year; %Chosen years to investigate
    % optimism_array = ["less", "basic", "more"];
    optimism_array = "basic"; %Chosen tech to investigate
    fuel_array = ["Fossil Jet Fuel", "Liquid Hydrogen"]; %Chosaen fuels to investigate
    range_array = [200:50:950 1000:100:18100];
    
    n_entries = length(year_array) * length(optimism_array) * length(fuel_array) * length(aircraft_array) * length(load_factor_array);
    
    Year = cell(n_entries,1);
    AircraftOptimism = cell(n_entries,1);
    AC = cell(n_entries,1);
    Fuel = cell(n_entries,1);
    LoadFactor = cell(n_entries,1);
    Range = cell(n_entries,1);
    Passengers = cell(n_entries,1);
    WingSpan = cell(n_entries,1);
    Altitude = cell(n_entries,1);
    MaxRange = cell(n_entries,1);
    PropEfficiency = cell(n_entries,1);
    ThermalEfficiency = cell(n_entries,1);
    LoD = cell(n_entries,1);
    OEW = cell(n_entries,1);
    ZFW = cell(n_entries,1);
    MTOW = cell(n_entries,1);
    ClimbAngle = cell(n_entries,1);
    CruiseSpeed = cell(n_entries,1);
    ClimbSpeed = cell(n_entries,1);
    ApproachSpeed = cell(n_entries,1);
    TakeOffWeight = cell(n_entries,1);
    FuelkWhPass = cell(n_entries,1);
    FuelBurnKgm = cell(n_entries,1);
    DesignRange = cell (n_entries,1);
    AcObject = cell (n_entries,1);
    
    
    count = 1;
    
    for i=1:length(year_array)
        for j=1:length(optimism_array)
            for l=1:length(fuel_array)
                switch fuel_array(l)
                    case "Fossil Jet Fuel"
                        fuel = Ker;
                        group = Ker_group;
                    case "Liquid Hydrogen"
                        fuel = LH2;
                        group = LH2_group;
                    otherwise
                        warning('Fuel Entry [%s] Invalid',fuel_array(l))
                        continue
                end
    
                for k=1:length(aircraft_array)
                    switch(aircraft_array(k))
                        case 'Short Haul'
                            current = group.SH;
                        case 'Medium Haul'
                            current = group.MH;
                        case 'Long Haul'
                            current = group.LH;
                        otherwise
                            warning('Aircraft Entry [%s] Invalid]', aircraft_array(k))
                            continue
                    end
                    switch fuel_array(l)
                        case "Fossil Jet Fuel"
                            % setup aircraft dimensions
                            current.dimensions = Dimension(current.design_mission, current.seats_per_row, current.N_deck);
                            
                            % setup aircraft
                            current.ac = Aircraft(fuel,current.design_mission,current.dimensions);
                            if any(ismember(fields(current),'eta_eng'))
                                current.ac.manual_input.eta_eng = current.eta_eng;
                            end
                            if any(ismember(fields(current),'eta_prop'))
                                current.ac.manual_input.eta_prop = current.eta_prop;
                            end
                            if any(ismember(fields(current),'m_eng'))
                                current.ac.manual_input.m_eng = current.m_eng;
                            end
                            if any(ismember(fields(current),'number_engines'))
                                current.ac.manual_input.number_engines = current.number_engines;
                            end
    
                            % update year
                            current.ac.year = year_array(i);
                            current.ac.optimism = optimism_array(j);
            
                            % iterate to design aircraft
                            current.ac = current.ac.finalise();
                        case "Liquid Hydrogen"
                            year = year_array(i);
                            optimism = optimism_array(j);
                            
                            current.struct_material = struct_material;
                            current.ins_material = ins_material;
                            current.fuel = fuel;
        
                            % design h2 aircraft
                            current.ac = designH2AC(current, year, optimism);
                            %current.ac.text_gen("H2_current")
                        otherwise
                            warning('Fuel Entry [%s] Invalid',fuel_array(l))
                            continue
    
                    end
                    
                    
                    for m =1:length(load_factor_array)
                        
                        %calculate max range at load factor
                        current.oper_mission = copy(current.design_mission);
    
                        current.oper_mission.load_factor = load_factor_array(m);
                        current.oper_mission = current.oper_mission.update();
                        
                        current.max_range = current.ac.max_range(current.oper_mission);
    
                        n_range = length(range_array);
                        FuelkWhPass_array = NaN(1,n_range);
                        TakeOffWeight_array = NaN(1,n_range);
                        FuelBurnKgm_array = NaN(1,n_range);
                        
                        range_array_sliced = find(range_array <= current.max_range); % slice it so only valid ranges are checked
                        for n=1:length(range_array_sliced)
                            range = range_array(n);
                            current.oper_mission.range = range;
                            
                            current.ac = current.ac.operate(current.oper_mission);
                            m_fuel = current.ac.oper_mission.weight.m_Fuel;
                            m_TO = current.ac.oper_mission.weight.m_TO;
                    
                            % load data into array
                            FuelBurnKgm_array(n) = m_fuel/(range*1e3); % this includes reserves
                            FuelkWhPass_array(n) = m_fuel * fuel.lhv/(3.6e6*current.oper_mission.pax); % includes reserves
                            TakeOffWeight_array(n) = m_TO;
                        end
                        
                        Year{count} = current.ac.year;
                        switch current.ac.optimism
                            case "less"
                                AircraftOptimism{count} = "Less Technology";
                            case "basic"
                                AircraftOptimism{count} = "Basic Technology";
                            case "more"
                                AircraftOptimism{count} = "More Technology";
                            otherwise
                                AircraftOptimism{count} = "Unknown";
                                warning('Optimism unrecognised: %s', current.ac.optimism)
                        end
                        AC{count} = aircraft_array(k);
                        Fuel{count} = current.ac.fuel.name;
                        LoadFactor{count} = current.ac.oper_mission.load_factor;
                        Passengers{count} = current.ac.oper_mission.pax;
                        MaxRange{count} = current.max_range;
                        PropEfficiency{count} = current.ac.engine.eta_prop;
                        ThermalEfficiency{count} = current.ac.engine.eta_eng;
                        WingSpan{count} = current.ac.aero.b;
                        LoD{count} = current.ac.aero.LovD;
                        OEW{count} = current.ac.weight.m_OEW;
                        ZFW{count} = current.ac.weight.m_ZFW;
                        MTOW{count} = current.ac.weight.m_maxTO;
                        Altitude{count} = current.ac.design_mission.cruise_alt;
                        ClimbAngle{count} = current.ac.design_mission.angle_TO;
                        CruiseSpeed{count} = current.ac.design_mission.cruise_speed;
                        ClimbSpeed{count} = current.ac.design_mission.cruise_speed; %TODO climb speed necessary?
                        ApproachSpeed{count} = current.ac.design_mission.cruise_speed; % TODO approach speed
                        Range{count} = range_array;
                        TakeOffWeight{count} = TakeOffWeight_array;
                        FuelBurnKgm{count} = FuelBurnKgm_array;
                        FuelkWhPass{count} = FuelkWhPass_array;
                        DesignRange{count} = current.ac.design_mission.range;
                        AcObject{count} = current.ac;
    
                        count = count + 1;
                    end
                end
            end
        end
    end
    
    Aircraft = AC; % needed because Aircraft is also a class name
    aircraftDataTable = table(...
                        Year,...
                        AircraftOptimism,...
                        Aircraft,...
                        Fuel,...
                        LoadFactor,...
                        Passengers,...
                        MaxRange,...
                        PropEfficiency,...
                        ThermalEfficiency,...
                        WingSpan,...
                        Altitude,...
                        ClimbAngle,...
                        CruiseSpeed,...
                        ClimbSpeed,...
                        ApproachSpeed,...
                        Range,...
                        TakeOffWeight,...
                        FuelBurnKgm,...
                        FuelkWhPass ...
                        );
    
    
    aircraftDataTableWhole = table(...
                        Year,...
                        AircraftOptimism,...
                        Aircraft,...
                        Fuel,...
                        LoadFactor,...
                        Passengers,...
                        MaxRange,...
                        PropEfficiency,...
                        ThermalEfficiency,...
                        WingSpan,...
                        LoD,...
                        OEW,...
                        ZFW,...
                        MTOW,...
                        Altitude,...
                        ClimbAngle,...
                        CruiseSpeed,...
                        ClimbSpeed,...
                        ApproachSpeed,...
                        Range,...
                        TakeOffWeight,...
                        FuelBurnKgm,...
                        FuelkWhPass,...
                        DesignRange,...
                        AcObject...
                        );
    
    %% Save table
    save("generatedaircraft.mat","aircraftDataTable")
    save("generatedaircraft_Whole.mat","aircraftDataTableWhole")
    
    %% clear variables
    
    
    disp("Table generated")
    
    % %% create PR diagrams
    output_cell = cell(10,2);
    
    %Aircraft
    output_cell{1,1} = copy(aircraftDataTableWhole{length(load_factor_array),"AcObject"}{1,1});
    output_cell{1,2} = copy(aircraftDataTableWhole{end,"AcObject"}{1,1});
    
    %Ranges
    output_cell{2,1} = aircraftDataTableWhole{1,"Range"}{1,1};
    output_cell{2,2} = aircraftDataTableWhole{1,"Range"}{1,1};
    
    %Max Range for each load factor
    for i=1:length(load_factor_array)
        output_cell{3,1}(i,1) = aircraftDataTableWhole{i,"MaxRange"}{1,1};
        output_cell{3,2}(i,1) = aircraftDataTableWhole{i+length(load_factor_array),"MaxRange"}{1,1};
    end
    
    
    output_cell{4,1} = nan(length(load_factor_array),length(output_cell{2,1}));
    output_cell{4,2} = nan(length(load_factor_array),length(output_cell{2,1}));
    output_cell{5,1} = nan(length(load_factor_array),length(output_cell{2,1}));
    output_cell{5,2} = nan(length(load_factor_array),length(output_cell{2,1}));
    output_cell{6,1} = nan(length(load_factor_array),length(output_cell{2,1}));
    output_cell{6,2} = nan(length(load_factor_array),length(output_cell{2,1}));
    output_cell{7,1} = nan(length(load_factor_array),length(output_cell{2,1}));
    output_cell{7,2} = nan(length(load_factor_array),length(output_cell{2,1}));
    output_cell{8,1} = nan(length(load_factor_array),length(output_cell{2,1}));
    output_cell{8,2} = nan(length(load_factor_array),length(output_cell{2,1}));
    output_cell{9,1} = nan(length(load_factor_array),length(output_cell{2,1}));
    output_cell{9,2} = nan(length(load_factor_array),length(output_cell{2,1}));
    output_cell{10,1} = nan(length(load_factor_array),length(output_cell{2,1}));
    output_cell{10,2} = nan(length(load_factor_array),length(output_cell{2,1}));
    
    %Load Factors
    for i=1:length(load_factor_array)
        max_range_index = find(output_cell{2,1} <= output_cell{3,1}(i), 1,'last');
        output_cell{4,1}(i,1:max_range_index) = load_factor_array(i);
        max_range_index = find(output_cell{2,2} <= output_cell{3,2}(i), 1,'last');
        output_cell{4,2}(i,1:max_range_index) = load_factor_array(i);
    end 
    
    %Passengers
    output_cell{5,1} = output_cell{4,1}.*output_cell{1,1}.design_mission.max_pax;
    output_cell{5,2} = output_cell{4,2}.*output_cell{1,2}.design_mission.max_pax;
    
    %Payloads
    cargo_mass = output_cell{1,1}.design_mission.m_cargo;
    output_cell{6,1} = output_cell{5,1}.*output_cell{1,1}.weight.m_pax + cargo_mass;
    output_cell{6,2} = output_cell{5,2}.*output_cell{1,2}.weight.m_pax + cargo_mass;
    
    %Fuel Burn & Fuel Burn/RPK
    for i=1:length(load_factor_array)
        max_range_index = find(output_cell{2,1} <= output_cell{3,1}(i), 1,'last');
        for j=1:max_range_index
            output_cell{7,1}(i,j) = aircraftDataTableWhole{i,"FuelBurnKgm"}{1,1}(j).*output_cell{2,1}(1,j)*1000;%kg
            output_cell{8,1}(i,j) = output_cell{7,1}(i,j)./(output_cell{2,1}(1,j).*output_cell{6,1}(i,j));
    
            output_cell{7,2}(i,j) = aircraftDataTableWhole{i+length(load_factor_array),"FuelBurnKgm"}{1,1}(j).*output_cell{2,2}(1,j)*1000;%kg
            output_cell{8,2}(i,j) = output_cell{7,2}(i,j)./(output_cell{2,2}(1,j).*output_cell{6,2}(i,j));
        end
    end
    
    %Energy 
    output_cell{9,1} = output_cell{7,1}*output_cell{1,1}.fuel.lhv/1e6;
    output_cell{10,1} = output_cell{8,1}*output_cell{1,1}.fuel.lhv/1e6;
    
    output_cell{9,2} = output_cell{7,2}*output_cell{1,2}.fuel.lhv/1e6;
    output_cell{10,2} = output_cell{8,2}*output_cell{1,2}.fuel.lhv/1e6;
    
    clearvars -except aircraftDataTable aircraftDataTableWhole Ker_group LH2_group output_cell f ranges_tested output_cell2 output_cell3
    
    
    
    %% Creating the first knee data 2 cells are created
    % cell2 is the data for kerosene
    %cell3 is the data for hydrogen
    % they contain data as described below, for th eknee range, passengers,
    % fuel in kg/RPK and energy in MJ/RPK
    % Aircraft
    output_cell2{1,f} = output_cell{1,1};
    output_cell3{1,f} = output_cell{1,2};
    % Range array
    output_cell2{2,f} = ranges_tested(f);
    output_cell3{2,f} = ranges_tested(f);
    % Passengers Array
    output_cell2{3,f} = output_cell{5,1}(end,1);
    output_cell3{3,f} = output_cell{5,2}(end,1);
    % Fuel/RPK Burn Array
    index = find(isnan(output_cell{8,1}(end,:)),1,'first') -1;
    output_cell2{4,f} = output_cell{8,1}(end,index);
    index = find(isnan(output_cell{8,2}(end,:)),1,'first') -1;
    output_cell3{4,f} = output_cell{8,2}(end,index);
    % Energy/RPK Array
    output_cell2{5,f} = output_cell2{4,f}.*output_cell{1,1}.fuel.lhv/1e6;
    output_cell3{5,f} = output_cell3{4,f}.*output_cell{1,2}.fuel.lhv/1e6;
end
%% PLOTS
close all
%Example first knee energy/RPK for kerosene
figure(1)
for i = 1:width(output_cell2)
    x(i) = output_cell2{2,i};
    y(i) = output_cell2{5,i};
end
plot(x,y)
%example for hydrogen
figure(2)
for i = 1:width(output_cell3)
    x(i) = output_cell3{2,i};
    y(i) = output_cell3{5,i};
end
plot(x,y)

figure(3)
for i=1:width(output_cell2)
    x1(i) = output_cell2{2,i};
    y1(i) = output_cell2{1,i}.weight.m_OEW;
    x2(i) = output_cell3{2,i};
    y2(i) = output_cell3{1,i}.weight.m_OEW;
%     x(i) = x1(i)-x2(i);
    y(i) = y1(i)-y2(i);
end

plot(x,y)
% plot(x1,y1)
% hold on
% plot(x2,y2)

figure(4)
for i=1:width(output_cell2)
    x1(i) = output_cell2{2,i};
    y1(i) = output_cell2{1,i}.weight.m_fuselage;
    x2(i) = output_cell3{2,i};
    y2(i) = output_cell3{1,i}.weight.m_fuselage;
%     x(i) = x1(i)-x2(i);
    y(i) = y1(i)-y2(i);
end

plot(x,y)
plot(x1,y1)
hold on
plot(x2,y2)

figure(5)
for i=1:width(output_cell2)
    x1(i) = output_cell2{2,i};
    y1(i) = output_cell2{1,i}.weight.m_wing;
    x2(i) = output_cell3{2,i};
    y2(i) = output_cell3{1,i}.weight.m_wing;
%     x(i) = x1(i)-x2(i);
    y(i) = y1(i)-y2(i);
end

plot(x,y)
plot(x1,y1)
hold on
plot(x2,y2)

figure(6)
for i=1:width(output_cell2)
    x1(i) = output_cell2{2,i};
    y1(i) = output_cell2{1,i}.weight.m_fuel_sys;
    x2(i) = output_cell3{2,i};
    y2(i) = output_cell3{1,i}.weight.m_fuel_sys;
%     x(i) = x1(i)-x2(i);
    y(i) = y1(i)-y2(i);
end

plot(x,y)
plot(x1,y1)
hold on
plot(x2,y2)

figure(7)
for i=1:width(output_cell2)
    x1(i) = output_cell2{2,i};
    y1(i) = output_cell2{1,i}.weight.m_engine;
    x2(i) = output_cell3{2,i};
    y2(i) = output_cell3{1,i}.weight.m_engine;
%     x(i) = x1(i)-x2(i);
    y(i) = y1(i)-y2(i);
end

plot(x,y)
plot(x1,y1)
hold on
plot(x2,y2)

figure(8)
for i=1:width(output_cell2)
    x1(i) = output_cell2{2,i};
    y1(i) = output_cell2{1,i}.weight.m_systems;
    x2(i) = output_cell3{2,i};
    y2(i) = output_cell3{1,i}.weight.m_systems;
%     x(i) = x1(i)-x2(i);
    y(i) = y1(i)-y2(i);
end

plot(x,y)
plot(x1,y1)
hold on
plot(x2,y2)

figure(9)
for i=1:width(output_cell2)
    x1(i) = output_cell2{2,i};
    y1(i) = output_cell2{1,i}.weight.m_tail;
    x2(i) = output_cell3{2,i};
    y2(i) = output_cell3{1,i}.weight.m_tail;
%     x(i) = x1(i)-x2(i);
    y(i) = y1(i)-y2(i);
end

plot(x,y)
plot(x1,y1)
hold on
plot(x2,y2)