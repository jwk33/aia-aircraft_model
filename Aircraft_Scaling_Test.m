close all
clear all


%% CONSTANT INPUTS
load("Fuels\Ker.mat","Ker")
load("Fuels\LH2.mat","LH2")

range = 3790;%km
M = 0.78;
cruise_alt = 10000; %m
max_pax = 180;
cargo = 2959; %kg
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 6;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,N_deck);
dimension.fuselage_length = 39.47;
dimension.fuselage_diameter = 3.74;
dimension = dimension.finalise();



%% SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
B737 = Aircraft(fuel,design_mission,dimension);
save('B737.mat','B737');

% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
B737 = B737.finalise();
save('B737.mat','B737');