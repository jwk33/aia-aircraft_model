close all
clear all
%% CONSTANT INPUTS
lhv = 120e6;%J/kg
density = 71;%kg/m3
fuel = Fuel(lhv,density,1);

range = 6000;%km
M = 0.8;
cruise_alt = 10000; %m
max_pax = 198;
load_factor = 0.75;
mission = Mission(range, M, cruise_alt, max_pax,load_factor);

density = 2700; %kg/m3
yield_strength = 276; %MPa
thermal_conductivity = 0.5; %W / m K
struct_material = Material("Aluminium","Structural",density,yield_strength,thermal_conductivity);

density = 50; %kg/m3
yield_strength = 1; %MPa
thermal_conductivity = 1e-4; %W / m K
ins_material = Material("Insulation","Insulation",density,yield_strength,thermal_conductivity);

seats_per_row = 8;
number_aisles = 2;
N_deck = 1;
[fuselage_length, fuselage_diameter] = Find_Dimensions(mission,seats_per_row,number_aisles,N_deck);

fuselage_diameter = fuselage_diameter + 0.5; %m
fuselage_length = fuselage_length + 10; %m
dimension = Dimension(mission,fuselage_diameter,fuselage_length,seats_per_row,number_aisles,N_deck);

%% SETUP AN INSTANCE OF AIRCRAFT CLASS
a = Aircraft(fuel,mission,struct_material,ins_material,dimension);
b = Aircraft(fuel,mission,struct_material,ins_material,dimension);
save('bee','b');
in = Aircraft(fuel,mission,struct_material,ins_material,dimension);
% in = a;
% b = a;


convergence = 0.0001; %Percentage delta in MTOW
max_iterations = 50;
iterations = 1;
convergence_factor = 100;
aircraft_list(1) = b;
while iterations < max_iterations && convergence_factor > convergence
    iterations = iterations + 1;
%     load('bee')
    s = load('bee');
    [a,convergence_factor] = a.iterate(s.b);
    b = a;
    save('bee','b');
    aircraft_list(iterations) = s.b;
end