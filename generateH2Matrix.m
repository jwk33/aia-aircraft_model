close all
clear all
%% CONSTANT INPUTS

load("Fuels\LH2.mat","LH2")

% define tank structural material
density = 2700; %kg/m3
yield_strength = 276e6; %Pa
thermal_conductivity = 236; %W / m K
struct_material = Material("Aluminium","Structural",density,yield_strength,thermal_conductivity);


% define tank insulation material
density = 50; %kg/m3
yield_strength = 1e6; %Pa
thermal_conductivity = 1e-4; %W / m K
ins_material = Material("Insulation","Insulation",density,yield_strength,thermal_conductivity);

% range = 3790;%km
% M = 0.78;
% cruise_alt = 10000; %m
% max_pax = 180;
% cargo = 2959; %kg

range = 9e3; %km
M = 0.81;
cruise_alt = 10e3; %m
max_pax = 300;
cargo = 0;%32.113e3; %kg

load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

N_deck = 1;

seats_abreast_array = 7:1:12;
length_frac_array = 0.2:0.01:1.0;
%% Template

dimensionTemplate = Dimension(design_mission,8,1,0,0,0,0);
acTemplate = Aircraft(LH2,design_mission,dimensionTemplate);
acMat = repmat(acTemplate,[length(seats_abreast_array),length(length_frac_array)]);

%% Generate Matrix

tic
for i=1:length(seats_abreast_array)
    for j=1:length(length_frac_array)
        
        seats_per_row = seats_abreast_array(i);
        length_frac = length_frac_array(j);

        dimension = Dimension(design_mission,seats_per_row,N_deck,1.0,length_frac,0,0);
        dimension = dimension.finalise();
    
        % SETUP A FUEL TANK
        h2_tank = FuelTank(LH2,struct_material, ins_material);
        h2_tank = h2_tank.finalise(dimension);
        
        % SETUP AN INSTANCE OF AIRCRAFT CLASS        
        ac = Aircraft(LH2,design_mission,dimension);
        

        ac.tank = h2_tank;
        
        ac.manual_input.eta_eng = 0.41;
        
        
        % All inputs defined. Now for the aircraft sizing loop to begin to
        % calculate MTOW
        ac = ac.finalise();

        acMat(i,j) = copy(ac);
        
    end
end
toc

%% Compare fuel mass (tank vs fuel burn)
fuelBurn = zeros(size(acMat));
fuelTank = zeros(size(acMat));
fuelErr = zeros(size(acMat));

for i=1:length(seats_abreast_array)
    for j=1:length(length_frac_array)
        fuelBurn(i,j) = acMat(i,j).weight.m_Fuel;
        fuelTank(i,j) = acMat(i,j).tank.m_fuelMax;
        fuelErr(i,j) = fuelTank(i,j) - fuelBurn(i,j);
        
    end
end

%%
[row,col] = find(fuelErr > 0);


assert(length(row) >=1, "No Solution Found")


acMat_new = cell(size(acMat));

fuelBurn_new = NaN(size(acMat));
fuelTank_new = NaN(size(acMat));

n = length(row); %number of valid entries

x = acMat();

for i=1:n
    x = row(i);
    y = col(i);
    acMat_new{x,y} = copy(acMat(x,y));
    fuelBurn_new(x,y) = fuelBurn(x,y);
    fuelTank_new(x,y) = fuelTank_new(x,y);
end

%% check min fuel burn

minFuel = min(fuelBurn_new(:));
[row, col] = find(fuelBurn_new == minFuel);
if length(row) > 1
    disp("check minimum")
end
bestAC = acMat(row,col);
bestAC.text_gen();


