%%
clear all

%% CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 3790;%km
M = 0.78;
cruise_alt = 10000; %m
max_pax = 180;
cargo = 2959; %kg
load_factor = 1.0;
mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 6;
number_aisles = 1;
N_deck = 1;

dimension = Dimension(mission,seats_per_row,number_aisles,N_deck);
dimension.fuselage_length = 39.47;
dimension.fuselage_diameter = 3.74;
dimension = dimension.finalise();


%% SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
B737 = Aircraft(fuel,mission,dimension);
save('B737.mat','B737');

% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
B737 = B737.finalise();
save('B737.mat','B737');