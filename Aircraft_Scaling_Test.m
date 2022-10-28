close all
clear all
%% set fuel properties

Ker = Fuel(43.2e6,807.5,0);
save("Ker_Fuel.mat","Ker")

LH2 = Fuel(120e6,70.17,1);
save("LH2_Fuel.mat","LH2")

%% CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

load("LH2_Fuel.mat","LH2")

range = 3900;%km
M = 0.78;
cruise_alt = 10000; %m
max_pax = 180;
load_factor = 1.0;
mission = Mission(range, M, cruise_alt, max_pax,load_factor);

seats_per_row = 6;
number_aisles = 1;
N_deck = 1;

dimension = Dimension(mission,seats_per_row,number_aisles,N_deck);
dimension.fuselage_length = 37.5;
dimension.fuselage_diameter = 3.74;
dimension = dimension.finalise();

%% Setup a fuel tank
% define tank structural material
density = 2700; %kg/m3
yield_strength = 276e6; %MPa
thermal_conductivity = 0.5; %W / m K
struct_material = Material("Aluminium","Structural",density,yield_strength,thermal_conductivity);


% define tank insulation material
density = 50; %kg/m3
yield_strength = 1e6; %MPa
thermal_conductivity = 1e-4; %W / m K
ins_material = Material("Insulation","Insulation",density,yield_strength,thermal_conductivity);


h2_tank = FuelTank(LH2,struct_material, ins_material);

%% SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
B737 = Aircraft(fuel,mission,dimension);
save('B737.mat','B737');

% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
B737 = B737.finalise();
save('B737.mat','B737');