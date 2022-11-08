close all
clear all
%% CONSTANT INPUTS

load("LH2_Fuel.mat","LH2")

range = 3790;%km
M = 0.78;
cruise_alt = 10000; %m
max_pax = 180;
cargo = 2959; %kg
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 6;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,N_deck,1,0.5,0,0);
dimension = dimension.finalise();

%% Setup a fuel tank
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


h2_tank = FuelTank(LH2,struct_material, ins_material);
h2_tank = h2_tank.finalise(dimension);

%% SETUP AN INSTANCE OF AIRCRAFT CLASS

H737 = Aircraft(LH2,design_mission,dimension);
H737.tank = h2_tank;
save('./saved-ac/H737.mat','H737');

H737.m_eng_input = 4e3;
H737.eta_input = 0.5;
H737.AR_input = 10;
H737.sweep_input = 30;
H737.wing_area_input = 150;


% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
H737 = H737.finalise();
save('./saved-ac/H737.mat','H737');