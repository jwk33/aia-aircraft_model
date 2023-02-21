%% Make a PR diagram for a given aircraft
close all
clear all

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
SH.range = 3900;
SH.M = 0.79;
SH.m_cargo = 2726; %2500;
SH.max_pax = 180;
SH.seats_per_row = 6;
SH.N_deck = 1;
SH.eta_eng = 0.45;
SH.number_engines = 2;
SH.seats_abreast_array = [4,5,6,7,8,9];

SH.design_mission = Mission(SH.range,SH.M,cruise_alt, SH.max_pax, 1.0, SH.m_cargo);
size_inputs.SH = SH;
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

%% Which Cases to run you can edit these and have arrays or just single examples. ie you can look at all years
load_factor_array = 0:0.1:1;%Leave this alone
aircraft_array = "Short Haul";%leave this alone

% year_array = [2021, 2035, 2050];
year_array = 2021; %Chosen years to investigate
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
                        current.ac.manual_input.eta_eng = current.eta_eng;
                        current.ac.manual_input.number_engines = current.number_engines;
    
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

% clearvars -except aircraftDataTable aircraftDataTableWhole Ker_group LH2_group
disp("Table generated")

% %% create PR diagrams
figure_number = 0;
for i=1:length(load_factor_array):height(aircraftDataTableWhole)
    ac = aircraftDataTableWhole{i,"AcObject"}{1,1};
%     disp(i)
    figure_number = figure_number + 1;
    payloads = zeros(length(load_factor_array)+1,1);
    ranges = zeros(length(load_factor_array)+1,1);
    fuel_burns = zeros(length(load_factor_array)+1,1);
    erpk = zeros(length(load_factor_array)+1,1);


    for k = 1:length(load_factor_array)
        j = k+i-1;
        payloads(end-k+1) = aircraftDataTableWhole{j,"Passengers"}{1,1};
        ranges(end-k+1) = aircraftDataTableWhole{j,"MaxRange"}{1,1};
        fuel_array = aircraftDataTableWhole{j,"FuelBurnKgm"}{1,1};
        fuel_burns(end-k+1) = fuel_array(find(~isnan(fuel_array),1,'last'))*ranges(end-k+1)*1000;
        erpk(end-k+1) = (fuel_burns(end-k+1)*aircraftDataTableWhole{j,"AcObject"}{1,1}.fuel.lhv/(10^6))/(ranges(end-k+1)*payloads(end-k+1));
    end
    payloads(1) = max(payloads);
    fuel_burns(1) = 0;
    ranges(1) = 0;
    erpk(1) = erpk(2);
    figure(figure_number)
    plot(ranges,payloads)
    title([aircraftDataTableWhole{i,"Aircraft"}{1,1},num2str(ac.year),ac.optimism,ac.fuel.name])
    xlabel('Range (km)')
    ylabel('Passengers')
    xlim([0,ceil(max(ranges)/1000)*1000])
    ylim([0,ceil(max(payloads)/100)*100])

%     figure_number = figure_number + 1;
%     figure(figure_number)
%     plot(ranges,erpk)
%     title([aircraftDataTableWhole{i,"Aircraft"}{1,1},num2str(ac.year),ac.optimism,ac.fuel.name])
%     xlabel('Range (km)')
%     ylabel('Energy/RPK (MJ/RPK)')
%     xlim([0,ceil(max(ranges)/1000)*1000])
%     ylim([0,3])

    figure_number = figure_number+1;
    max_R = aircraftDataTableWhole{i+length(load_factor_array)-1,"MaxRange"}{1,1};
    max_R_index = find(aircraftDataTableWhole{i+length(load_factor_array)-1,"Range"}{1,1} >= max_R,1,'first');
    fuel_burns2 = zeros(max_R_index,1);
    erpk2 = zeros(max_R_index+length(load_factor_array),1);
    Ranges2 = zeros(max_R_index+length(load_factor_array),1);
    ac_index = i+length(load_factor_array)-1;
    for j = 1:max_R_index
        Ranges2(j) = aircraftDataTableWhole{ac_index,"Range"}{1,1}(j);
        fuel_burns2(j) = aircraftDataTableWhole{ac_index,"FuelBurnKgm"}{1,1}(j)*Ranges2(j)*1000;
        erpk2(j) = (fuel_burns2(j)*aircraftDataTableWhole{ac_index,"AcObject"}{1,1}.fuel.lhv/(10^6))/(Ranges2(j)*aircraftDataTableWhole{ac_index,"Passengers"}{1,1});
    end
    Ranges2(max_R_index+1:end) = ranges(2:end);
    erpk2(max_R_index+1:end) = erpk(2:end);
    figure(figure_number)
    plot(Ranges2,erpk2)
    title([aircraftDataTableWhole{i,"Aircraft"}{1,1},num2str(ac.year),ac.optimism,ac.fuel.name])
    xlabel('Range (km)')
    ylabel('Energy/RPK (MJ/RPK)')
    xlim([0,ceil(max(ranges)/1000)*1000])
    ylim([0,3])
end