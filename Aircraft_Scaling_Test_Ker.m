%%
clear all

%% B737 CONSTANT INPUTS
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


% B737 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
B737 = Aircraft(fuel,mission,dimension);
B737.m_eng_input = 4e3;
B737.eta_input = 0.4;
B737.AR_input = 9.45;
B737.sweep_input = 25;
B737.wing_area_input = 124.6;
save('B737.mat','B737');

% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
B737 = B737.finalise();
save('B737.mat','B737');


%% B777 CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 10000;%km
M = 0.78;
cruise_alt = 10000; %m
max_pax = 370;
cargo = 32113; %kg
load_factor = 1.0;
mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 10;
number_aisles = 2;
N_deck = 1;

dimension = Dimension(mission,seats_per_row,number_aisles,N_deck);
dimension.fuselage_length = 67.73;
dimension.fuselage_diameter = 6.26;
dimension = dimension.finalise();


% B777 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
B777 = Aircraft(fuel,mission,dimension);
save('B777.mat','B777');
% B777.m_eng_input = 5714;
% B777.eta_input = 0.48;
B777.AR_input = 9.61;
B777.sweep_input = 31.6;
B777.wing_area_input = 436.8;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
B777 = B777.finalise();
save('B777.mat','B777');

%% ATR-72-600 CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 1370;%km
M = 0.44;
cruise_alt = 6096; %m
max_pax = 72; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = -504; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo 56 kg for full payload
load_factor = 1.0;
mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 4;
number_aisles = 1;
N_deck = 1;

dimension = Dimension(mission,seats_per_row,number_aisles,N_deck);
dimension.fuselage_length = 27;
dimension.fuselage_diameter = 2.9;
dimension = dimension.finalise();


% ATR-72-600 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
ATR_72_600 = Aircraft(fuel,mission,dimension);
save('ATR_72_600.mat','ATR_72_600');
ATR_72_600.m_eng_input = 960;
ATR_72_600.eta_input = 0.45;
ATR_72_600.sweep_input = 0;
ATR_72_600.AR_input = 12;
ATR_72_600.wing_area_input = 61;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
ATR_72_600 = ATR_72_600.finalise();
save('ATR_72_600.mat','ATR_72_600');

%% A320neo CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 4500;%km
M = 0.78;
cruise_alt = 10000; %m
max_pax = 165; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 2470; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 6;
number_aisles = 1;
N_deck = 1;

dimension = Dimension(mission,seats_per_row,number_aisles,N_deck);
dimension.fuselage_length = 37.57;
dimension.fuselage_diameter = 3.95;
dimension = dimension.finalise();


% A320neo SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
A320neo = Aircraft(fuel,mission,dimension);
save('A320neo.mat','A320neo');
A320neo.m_eng_input = 5714;
% A320neo.eta_input = 0.48;
A320neo.AR_input = 10.3;
A320neo.sweep_input = 25;
A320neo.wing_area_input = 124;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
A320neo = A320neo.finalise();
save('A320neo.mat','A320neo');

%% A330neo - 900 CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 8800;%km
M = 0.78;
cruise_alt = 10000; %m
max_pax = 300; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 15200; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 8;
number_aisles = 2;
N_deck = 1;

dimension = Dimension(mission,seats_per_row,number_aisles,N_deck);
dimension.fuselage_length = 63.66;
dimension.fuselage_diameter = 5.86;
dimension = dimension.finalise();


% A330neo - 900 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
A330neo = Aircraft(fuel,mission,dimension);
save('A330neo.mat','A330neo');
A330neo.m_eng_input = 12890;
A330neo.eta_input = 0.48;
A330neo.AR_input = 8.8;
A330neo.sweep_input = 31.9;
A330neo.wing_area_input = 465;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
A330neo = A330neo.finalise();
save('A330neo.mat','A330neo');

%% A350 - 900 CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 10750;%km
M = 0.78;
cruise_alt = 10000; %m
max_pax = 315; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 21670; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 9;
number_aisles = 2;
N_deck = 1;

dimension = Dimension(mission,seats_per_row,number_aisles,N_deck);
dimension.fuselage_length = 65.26;
dimension.fuselage_diameter = 5.96;
dimension = dimension.finalise();


% A350 - 900 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
A350_900 = Aircraft(fuel,mission,dimension);
save('A350_900.mat','A350_900');
A350_900.m_eng_input = 14554;
A350_900.eta_input = 0.48;
A350_900.AR_input = 9.49;
A350_900.sweep_input = 31.9;
A350_900.wing_area_input = 442;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
A350_900 = A350_900.finalise();
save('A350_900.mat','A350_900');