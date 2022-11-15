close all
clear all
clc
%% load constants
load("Ker_Fuel.mat","Ker")
load("LH2_fuel.mat","LH2")

% define tank structural material
load("Aluminium.mat", "aluminium")
struct_material = aluminium;


% define tank insulation material
load("MLI.mat", "MLI")
ins_material = MLI;

cruise_alt = 10000; %m

%% Aircraft Size Dependent Inputs

% Short haul
SH = {};
SH.range = 3900;
SH.M = 0.79;
SH.m_cargo = 2959; %2500;
SH.max_pax = 180;
SH.seats_per_row = 6;
SH.N_deck = 1;
SH.eta_eng = 0.45;
SH.number_engines = 2;
SH.seats_abreast_array = [4,5,6,7,8,9];

SH.design_mission = Mission(SH.range,SH.M,cruise_alt, SH.max_pax, 1.0, SH.m_cargo);


% Medium haul
MH.range = 9000;
MH.M = 0.81;
MH.m_cargo = 0; %20000;
MH.max_pax = 300;
MH.seats_per_row = 8;
MH.N_deck = 1;
MH.eta_eng = 0.475;
MH.number_engines = 2;
MH.seats_abreast_array = [7,8,9,10,11,12,13,14];
MH.design_mission = Mission(MH.range,MH.M,cruise_alt, MH.max_pax, 1.0, MH.m_cargo);

% Long haul
LH.range = 14000;
LH.M = 0.83;
LH.m_cargo = 0; % 30000;
LH.max_pax = 500;
LH.seats_per_row = 10;
LH.N_deck = 2;
LH.eta = 0.5;
LH.number_engines = 4;
LH.seats_abreast_array = [7,8,9,10,11,12,13,14];
LH.design_mission = Mission(LH.range,LH.M,cruise_alt, LH.max_pax, 1.0, LH.m_cargo); % design mission is always at 100% load factor

size_inputs.SH = SH;
size_inputs.MH = MH;
size_inputs.LH = LH;
size_initials = fieldnames(size_inputs);
%% Generate Kerosene Aircraft 
%NOTE: Fuel is immutable so aircraft instance cannot be shared across fuels
Ker_group = {};

for el=1:length(size_initials)
    size = char(size_initials(el));
    Ker_group.(size) = size_inputs.(size);
end


% Ker.SH.ac.manual_input.m_eng = 6000;
% Ker.SH.ac.manual_input.AR = 10;
% Ker.SH.ac.manual_input.sweep = 25;
% Ker.SH.ac.manual_input.wing_area = 130;


% Medium haul



% Ker.MH.ac.manual_input.m_eng = 13000;
% Ker.MH.ac.manual_input.AR = 9;
% Ker.MH.ac.manual_input.sweep = 30;
% Ker.MH.ac.manual_input.wing_area = 470;


% Long haul



%LH.ac.manual_input.AR = 8;
%LH.ac.manual_input.sweep = 32;
%LH.ac.manual_input.wing_area = 800;

%% Generate Hydrogen Aircraft
LH2_group = {};

for el=1:length(size_initials)
    size = char(size_initials(el));
    LH2_group.(size) = size_inputs.(size);
end

%% Clear Unused Variables
clear size
clear size_initials
clear size_inputs
clear cruise_alt
clear aluminium
clear MLI
clear el
clear SH
clear MH
clear LH
%% Run all cases

year_array = [2021, 2035, 2050];
optimism_array = ["less","basic", "more"];
load_factor_array = [0.7, 0.75, 0.8];
aircraft_array = ["Short Haul", "Medium Haul","Long Haul",];
fuel_array = ["Fossil Jet Fuel", "Liquid Hydrogen"];
range_array = 500:100:18500;

n_entries = length(year_array) * length(optimism_array) * length(fuel_array) * length(aircraft_array) * length(load_factor_array);

Year = cell(n_entries,1);
Optimism = cell(n_entries,1);
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
ClimbAngle = cell(n_entries,1);
CruiseSpeed = cell(n_entries,1);
ClimbSpeed = cell(n_entries,1);
ApproachSpeed = cell(n_entries,1);
TakeOffWeight = cell(n_entries,1);
FuelkWhPass = cell(n_entries,1);
FuelBurnKgm = cell(n_entries,1);
DesignRange = cell (n_entries,1);



count = 1;

for i=1:length(year_array)
    for j=1:length(optimism_array)
        for l=1:length(fuel_array)
            if fuel_array(l) == "Fossil Jet Fuel"
                fuel = Ker;
                group = Ker_group;
            elseif fuel_array(l) == "Liquid Hydrogen"
                fuel = LH2;
                group = LH2_group;
            else
                disp("Fuel Entry Invalid")
                continue
            end

            for k=1:length(aircraft_array)
                if aircraft_array(k) == "Short Haul"
                    current = group.SH;
                elseif aircraft_array(k) == "Medium Haul"
                    current = group.MH;
                elseif aircraft_array(k) == "Long Haul"
                    current = group.LH;
                end
                
                if fuel_array(l) == "Fossil Jet Fuel"
                    % setup aircraft dimensions
                    current.dimensions = Dimension(current.design_mission, current.seats_per_row, current.N_deck);
                    
                    % setup aircraft
                    current.ac = Aircraft(fuel,current.design_mission,current.dimensions);
                    current.ac.manual_input.eta_eng = current.eta_eng;
                    current.ac.manual_input.number_engines = current.number_engines;

                    % update year
                    current.ac.year = year_array(i);
                    current.ac.optimism = optimism_array(j);
    
                    % iterate to design aircraft
                    current.ac = current.ac.finalise();
                elseif fuel_array(l) == "Liquid Hydrogen"
                    year = year_array(i);
                    optimism = optimism_array(j);
                    
                    current.struct_material = struct_material;
                    current.ins_material = ins_material;
                    current.fuel = LH2;

                    % design h2 aircraft
                    current.ac = designH2AC(current, year, optimism);
                    current.ac.text_gen("H2_current")
                    if aircraft_array(k) == "Long Haul"
                        disp("stop here")
                    end
                
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

                    for n=1:length(range_array)
                        range = range_array(n);
                        if range <= current.max_range
                            current.oper_mission.range = range;
                            
                            current.ac = current.ac.operate(current.oper_mission);
                            m_fuel = current.ac.oper_mission.weight.m_Fuel;
                            m_TO = current.ac.oper_mission.weight.m_TO;
                    
                            % load data into array
                            FuelBurnKgm_array(n) = m_fuel/(range*1e3); % this includes reserves
                            FuelkWhPass_array(n) = m_fuel * Ker.lhv * 2.77778e-7/current.oper_mission.pax; % includes reserves
                            TakeOffWeight_array(n) = m_TO;
                        end


                    end
                    
                    Year{count} = current.ac.year;
                    Optimism{count} = current.ac.optimism;
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
                    

                    count = count + 1;
                end
            end
        end
    end
end

Aircraft = AC; % needed because Aircraft is also a class name
aircraftDataTable = table(...
                    Year,...
                    Optimism,...
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
                    Altitude,...
                    ClimbAngle,...
                    CruiseSpeed,...
                    ClimbSpeed,...
                    ApproachSpeed,...
                    Range,...
                    TakeOffWeight,...
                    FuelBurnKgm,...
                    FuelkWhPass,...
                    DesignRange...
                    );

%% clear variables

clear Year
clear Optimism
clear Aircraft
clear Fuel
clear LoadFactor
clear Passengers
clear MaxRange
clear PropEfficiency
clear ThermalEfficiency
clear WingSpan
clear LoD
clear OEW
clear Altitude
clear ClimbAngle
clear CruiseSpeed
clear ClimbSpeed
clear ApproachSpeed
clear Range
clear TakeOffWeight
clear FuelBurnKgm
clear FuelkWhPass_array
clear DesignRange
disp("Table generated")


%% Save table
save("aircraftDataTable.mat","aircraftDataTable")
%%
% tableTest = table(Year, FuelBurnKgm);






