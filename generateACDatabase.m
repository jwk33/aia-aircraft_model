close all
clear all

%% load constants
load("Ker_Fuel.mat","Ker")
cruise_alt = 10000; %m

%% Aircraft Size Dependent Inputs

% Short haul
SH = {};
SH.range = 4000;
SH.M = 0.79;
SH.m_cargo = 2500;
SH.max_pax = 175;
SH.seats_per_row = 6;
SH.number_aisles = 1;
SH.N_deck = 1;


% Medium haul
MH.range = 9000;
MH.M = 0.81;
MH.m_cargo = 20000;
MH.max_pax = 300;
MH.seats_per_row = 8;
MH.number_aisles = 2;
MH.N_deck = 1;

% Long haul
LH.range = 14000;
LH.M = 0.83;
LH.m_cargo = 30000;
LH.max_pax = 500;
LH.seats_per_row = 10;
LH.number_aisles = 2;
LH.N_deck = 2;

%% Generate Aircraft
SH.design_mission = Mission(SH.range,SH.M,cruise_alt, SH.max_pax, 1.0, SH.m_cargo); % design mission is always at 100% load factor

SH.dimension = Dimension(SH.design_mission, SH.seats_per_row, SH.number_aisles, SH.N_deck,0,0);
SH.dimension = SH.dimension.finalise();

SH.ac = Aircraft(Ker, SH.design_mission, SH.dimension);

SH.ac.m_eng_input = 6000;
SH.ac.eta_input = 0.45;
SH.ac.AR_input = 10;
SH.ac.sweep_input = 25;
SH.ac.wing_area_input = 130;

% Medium haul

MH.design_mission = Mission(MH.range,MH.M,cruise_alt, MH.max_pax, 1.0, MH.m_cargo); % design mission is always at 100% load factor

MH.dimension = Dimension(MH.design_mission, MH.seats_per_row, MH.number_aisles, MH.N_deck,0,0);
MH.dimension = MH.dimension.finalise();

MH.ac = Aircraft(Ker, MH.design_mission, MH.dimension);

MH.ac.m_eng_input = 13000;
MH.ac.eta_input = 0.475;
MH.ac.AR_input = 9;
MH.ac.sweep_input = 30;
MH.ac.wing_area_input = 470;

% Long haul
LH.design_mission = Mission(LH.range,LH.M,cruise_alt, LH.max_pax, 1.0, LH.m_cargo); % design mission is always at 100% load factor

LH.dimension = Dimension(LH.design_mission, LH.seats_per_row, LH.number_aisles, LH.N_deck,0,0);
LH.dimension = LH.dimension.finalise();

LH.ac = Aircraft(Ker, LH.design_mission, LH.dimension);

LH.ac.m_eng_input = 25000;
LH.ac.eta_input = 0.5;
LH.ac.AR_input = 8;
LH.ac.sweep_input = 32;
LH.ac.wing_area_input = 800;


%% Run all cases

year = [2021, 2035, 2050];
optimism = ["less", "basic", "more"];
load_factor = [0.7, 0.75, 0.8];
aircraft = ["Short Haul", "Medium Haul", "Long Haul"];
fuel = ["Fossil Jet Fuel"];
range_array = 500:100:18500;

n_entries = length(year) * length(optimism) * length(aircraft) * length(load_factor);

Year_cells = cell(n_entries,1);
Optimism_cells = cell(n_entries,1);
Aircraft_cells = cell(n_entries,1);
Fuel_cells = cell(n_entries,1);
LoadFactor_cells = cell(n_entries,1);
Range_cells = cell(n_entries,1);
Passengers_cells = cell(n_entries,1);
WingSpan_cells = cell(n_entries,1);
Altitude_cells = cell(n_entries,1);
ClimbAngle_cells = cell(n_entries,1);
CruiseSpeed_cells = cell(n_entries,1);
ClimbSpeed_cells = cell(n_entries,1);
ApproachSpeed_cells = cell(n_entries,1);
MaxRange_cells = cell(n_entries,1);
PropEfficiency_cells = cell(n_entries,1);
ThermalEfficiency_cells = cell(n_entries,1);
LoD_cells = cell(n_entries,1);
FuelkWhPass_cells = cell(n_entries,1);
FuelBurnKgm_cells = cell(n_entries,1);
TakeOffWeight_cells = cell(n_entries,1);


count = 1;

for i=1:length(year)
    for j=1:length(optimism)
        for k=1:length(aircraft)
            if aircraft(k) == "Short Haul"
                current = SH;
            elseif aircraft(k) == "Medium Haul"
                current = MH;
            elseif aircraft(k) == "Long Haul"
                current = LH;
            end
            
            for l=1:length(fuel)

                for m =1:length(load_factor)
                    % update year
                    current.ac.year = year(i);
                    current.ac.optimism = optimism(j);
                    current.ac = current.ac.finalise();

                    %calculate max range at load factor
                    current.oper_mission = copy(current.design_mission);
                    current.oper_mission.load_factor = load_factor(m);
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
                    
                    Year_cells{count} = current.ac.year;
                    Optimism_cells{count} = current.ac.optimism;
                    Aircraft_cells{count} = aircraft(k);
                    Fuel_cells{count} = current.ac.fuel.name;
                    LoadFactor_cells{count} = current.ac.oper_mission.load_factor;
                    Passengers_cells{count} = current.ac.oper_mission.pax;
                    MaxRange_cells{count} = current.max_range;
                    PropEfficiency_cells{count} = current.ac.engine.eta_prop;
                    ThermalEfficiency_cells{count} = current.ac.engine.eta_eng;
                    WingSpan_cells{count} = current.ac.aero.b;
                    LoD_cells{count} = current.ac.aero.LovD;
                    Altitude_cells{count} = current.ac.design_mission.cruise_alt;
                    ClimbAngle_cells{count} = current.ac.design_mission.angle_TO;
                    CruiseSpeed_cells{count} = current.ac.design_mission.cruise_speed;
                    ClimbSpeed_cells{count} = current.ac.design_mission.cruise_speed; %TODO climb speed necessary?
                    ApproachSpeed_cells{count} = current.ac.design_mission.cruise_speed; % TODO approach speed
                    Range_cells{count} = range_array;
                    FuelBurnKgm_cells{count} = FuelBurnKgm_array;
                    FuelkWhPass_cells{count} = FuelkWhPass_array;
                    TakeOffWeight_cells{count} = TakeOffWeight_array;

                    count = count + 1;
                end
            end
        end
    end
end

aircraftTableData = [
                    Year_cells,...
                    Optimism_cells,...
                    Aircraft_cells,...
                    Fuel_cells,...
                    LoadFactor_cells,...
                    Passengers_cells,...
                    MaxRange_cells,...
                    PropEfficiency_cells,...
                    ThermalEfficiency_cells,...
                    WingSpan_cells,...
                    LoD_cells,...
                    Altitude_cells,...
                    ClimbAngle_cells,...
                    CruiseSpeed_cells,...
                    ClimbSpeed_cells,...
                    ApproachSpeed_cells,...
                    Range_cells,...
                    FuelBurnKgm_cells,...
                    FuelkWhPass_cells,...
                    TakeOffWeight_cells...
                    ];

aircraftTable = cell2table(aircraftTableData,'VariableNames',{'Year', 'AircraftOptimism','Aircraft','Fuel',...
    'LoadFactor','Passengers','MaxRange','PropEfficiency','ThermalEfficciency','WingSpan','LoD','Altitude',...
    'ClimbAngle','CruiseSpeed','ClimbSpeed','ApproachSpeed','Range','FuelBurnkgm',...
    'FuelkWhPass','TakeOffWeight'});

disp("Table generated")


%% Generate Table

% AircraftDataTable_new = table('VariableNames',());







