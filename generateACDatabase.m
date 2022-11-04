close all
clear all

%% load constants
load("Ker_Fuel.mat","Ker")
M = 0.79;
cruise_alt = 10000; %m

%% Aircraft Size Dependent Inputs

% Short haul
SH = {};
SH.range = 3000;
SH.max_pax = 85;
SH.seats_per_row = 6;
SH.number_aisles = 1;
SH.N_deck = 1;


% Medium haul
MH.range = 6500;
MH.max_pax = 197;
MH.seats_per_row = 8;
MH.number_aisles = 2;
MH.N_deck = 1;

% Long haul
LH.range = 14000;
LH.max_pax = 436;
LH.seats_per_row = 15;
LH.number_aisles = 2;
LH.N_deck = 2;

%% Generate Aircraft
m_cargo = 0;
AR = 10;
sweep = 30;

SH.design_mission = Mission(SH.range,M,cruise_alt, SH.max_pax, 1.0, m_cargo); % design mission is always at 100% load factor

SH.dimension = Dimension(SH.design_mission, SH.seats_per_row, SH.number_aisles, SH.N_deck,0,0);
SH.dimension = SH.dimension.finalise();

SH.ac = Aircraft(Ker, SH.design_mission, SH.dimension);

SH.ac.m_eng_input = 960;
SH.ac.eta_input = 0.45;
SH.ac.AR_input = AR;
SH.ac.sweep_input = sweep;
SH.ac.wing_area_input = 100;

% Medium haul

MH.design_mission = Mission(MH.range,M,cruise_alt, MH.max_pax, 1.0, m_cargo); % design mission is always at 100% load factor

MH.dimension = Dimension(MH.design_mission, MH.seats_per_row, MH.number_aisles, MH.N_deck,0,0);
MH.dimension = MH.dimension.finalise();

MH.ac = Aircraft(Ker, MH.design_mission, MH.dimension);

MH.ac.m_eng_input = 960;
MH.ac.eta_input = 0.45;
MH.ac.AR_input = AR;
MH.ac.sweep_input = sweep;
MH.ac.wing_area_input = 145;

% Long haul
LH.design_mission = Mission(LH.range,M,cruise_alt, LH.max_pax, 1.0, m_cargo); % design mission is always at 100% load factor

LH.dimension = Dimension(LH.design_mission, LH.seats_per_row, LH.number_aisles, LH.N_deck,0,0);
LH.dimension = LH.dimension.finalise();

LH.ac = Aircraft(Ker, LH.design_mission, LH.dimension);

LH.ac.m_eng_input = 960;
LH.ac.eta_input = 0.45;
LH.ac.AR_input = AR;
LH.ac.sweep_input = sweep;
LH.ac.wing_area_input = 850;


%% Run all cases

year = [2021, 2035, 2050];
optimism = ["less", "basic", "more"];
load_factor = [0.7, 0.75, 0.8];
aircraft = ["Short Haul", "Medium Haul", "Long Haul"];
fuel = ["Fossil Jet Fuel"];
range_array = 500:100:18500;

n_entries = length(year) * length(optimism);

FuelkWhPass_cells = cell(n_entries,1);
FuelBurnKgm_cells = cell(n_entries,1);
TakeOffWeight_cells = cell(n_entries,1);


count = 1;

for i=1:length(year)
    for j=1:length(optimism)
        for k=1:length(aircraft)
            if aircraft(k) == "Short Haul"
                current = SH;
            elseif aircraft(k) == "Medim Haul"
                current = MH;
            elseif aircraft(k) == "Long Haul"
                current = LH;
            end
            
            for l=1:length(fuel)

                for m =1:length(load_factor)
                    % update year
                    current.ac.year = year(i);
                    current.ac.optimism = optimism(j);
                    if count == 7
                        disp("error here")
                    end
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


                    FuelBurnKgm_cells{count} = FuelBurnKgm_array;
                    FuelkWhPass_cells{count} = FuelkWhPass_array;
                    TakeOffWeight_cells{count} = TakeOffWeight_array;

                    count = count + 1;
                end
            end
        end
    end
end




%% Generate Table

% AircraftDataTable_new = table('VariableNames',());







