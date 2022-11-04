%%
clear all

%% DD CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 12222;%km
M = 0.83;
cruise_alt = 10000; %m
max_pax = 853;%737 Max - 8
cargo = 0; %kg
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 10;
number_aisles = 2;
N_deck = 2;

dimension = Dimension(design_mission,seats_per_row,number_aisles,N_deck,0,0);
% dimension.fuselage_length = 39.12;
% dimension.fuselage_diameter = 4.01;
dimension = dimension.finalise();


% B737 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
A380 = Aircraft(fuel,design_mission,dimension);
A380.m_eng_input = 24984;
A380.eta_input = 0.5;
A380.AR_input = 7.53;
A380.sweep_input = 30;
A380.wing_area_input = 845;

A380.year = 2021;
save('./saved-ac/A380.mat','A380');

% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
A380 = A380.finalise();
save('./saved-ac/A380.mat','A380');

%% B737 CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 3790;%km
M = 0.79;
cruise_alt = 10000; %m
max_pax = 178;%737 Max - 8
cargo = 2726; %kg
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 6;
number_aisles = 1;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,number_aisles,N_deck,0,0);
% dimension.fuselage_length = 39.12;
% dimension.fuselage_diameter = 4.01;
dimension = dimension.finalise();


% B737 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
B737 = Aircraft(fuel,design_mission,dimension);
B737.m_eng_input = 5560;
% B737.eta_input = 0.4;
B737.AR_input = 10.16;
B737.sweep_input = 25;
B737.wing_area_input = 127;

B737.year = 2021;
save('./saved-ac/B737.mat','B737');

% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
B737 = B737.finalise();
save('./saved-ac/B737.mat','B737');


%% B777300ER CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 10550;%km
M = 0.84;
cruise_alt = 10000; %m
max_pax = 396;
cargo = 29462; %kg
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 9;
number_aisles = 2;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,number_aisles,N_deck,0,0);
% dimension.fuselage_length = 73.08;
% dimension.fuselage_diameter = 6.2;
dimension = dimension.finalise();


% B777 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
B777 = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/B777.mat','B777');
% B777.m_eng_input = 5714;
% B777.eta_input = 0.5;
B777.AR_input = 9.61;
B777.sweep_input = 31.6;
B777.wing_area_input = 436.8;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
B777 = B777.finalise();
save('./saved-ac/B777.mat','B777');

%% ATR-72-600 CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 1370;%km
M = 0.44;
cruise_alt = 6096; %m
max_pax = 72; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = -504; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo 56 kg for full payload
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 4;
number_aisles = 1;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,number_aisles,N_deck,0,0);
% dimension.fuselage_length = 27;
% dimension.fuselage_diameter = 2.9;
dimension = dimension.finalise();


% ATR-72-600 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
ATR_72_600 = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/ATR_72_600.mat','ATR_72_600');
ATR_72_600.m_eng_input = 960;
ATR_72_600.eta_input = 0.45;
ATR_72_600.sweep_input = 0;
ATR_72_600.AR_input = 12;
ATR_72_600.wing_area_input = 61;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
ATR_72_600 = ATR_72_600.finalise();
save('./saved-ac/ATR_72_600.mat','ATR_72_600');

%% A320neo CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 4500;%km
M = 0.78;
cruise_alt = 10000; %m
max_pax = 165; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 2470; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 6;
number_aisles = 1;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,number_aisles,N_deck,0,0);
% dimension.fuselage_length = 37.57;
% dimension.fuselage_diameter = 3.95;
dimension = dimension.finalise();


% A320neo SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
A320neo = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/A320neo.mat','A320neo');
A320neo.m_eng_input = 5714;
% A320neo.eta_input = 0.48;
A320neo.AR_input = 10.3;
A320neo.sweep_input = 25;
A320neo.wing_area_input = 122.6;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
A320neo = A320neo.finalise();
save('./saved-ac/A320neo.mat','A320neo');

%% A330neo - 900 CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 8800;%km
M = 0.82;
cruise_alt = 11000; %m
max_pax = 300; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 15200; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 8;
number_aisles = 2;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,number_aisles,N_deck,0,0);
% dimension.fuselage_length = 63.66;
% dimension.fuselage_diameter = 5.86;
dimension = dimension.finalise();


% A330neo - 900 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
A330neo = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/A330neo.mat','A330neo');
A330neo.m_eng_input = 12890;
A330neo.eta_input = 0.48;
A330neo.AR_input = 10;
A330neo.sweep_input = 31.9;
A330neo.wing_area_input = 410;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
A330neo = A330neo.finalise();
save('./saved-ac/A330neo.mat','A330neo');

%% A350 - 900 CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 10750;%km
M = 0.85;
cruise_alt = 10000; %m
max_pax = 325; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 20650; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 9;
number_aisles = 2;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,number_aisles,N_deck,0,0);
% dimension.fuselage_length = 65.26;
% dimension.fuselage_diameter = 5.96;
dimension = dimension.finalise();


% A350 - 900 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
A350_900 = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/A350_900.mat','A350_900');
A350_900.m_eng_input = 14554;
A350_900.eta_input = 0.5;
A350_900.AR_input = 9.49;
A350_900.sweep_input = 35;
A350_900.wing_area_input = 442;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
A350_900 = A350_900.finalise();
save('./saved-ac/A350_900.mat','A350_900');

%% A350 - 1000 CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 10370;%km
M = 0.85;
cruise_alt = 10000; %m
max_pax = 366; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 30668; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 9;
number_aisles = 2;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,number_aisles,N_deck,0,0);
% dimension.fuselage_length = 66.80;
% dimension.fuselage_diameter = 5.96;
dimension = dimension.finalise();


% A350 - 1000 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
A350_1000 = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/A350_1000.mat','A350_1000');
A350_1000.m_eng_input = 15100;
A350_1000.eta_input = 0.5;
A350_1000.AR_input = 9.03;
A350_1000.sweep_input = 31.9;
A350_1000.wing_area_input = 464.3;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
A350_1000 = A350_1000.finalise();
save('./saved-ac/A350_1000.mat','A350_1000');

%% B787 - 10 CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 7777;%km
M = 0.85;
cruise_alt = 11000; %m
max_pax = 330; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 23616; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 9;
number_aisles = 2;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,number_aisles,N_deck,0,0);
% dimension.fuselage_length = 55.91;
% dimension.fuselage_diameter = 5.94;
dimension = dimension.finalise();


% A350 - 1000 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
B787_10 = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/B787_10.mat','B787_10');
B787_10.m_eng_input = 12240;
B787_10.eta_input = 0.5;
B787_10.AR_input = 9.59;
B787_10.sweep_input = 32.2;
B787_10.wing_area_input = 377;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
B787_10 = B787_10.finalise();
save('./saved-ac/B787_10.mat','B787_10');

%% B787 - 10 CONSTANT INPUTS
load("Ker_Fuel.mat","Ker")

range = 7777;%km
M = 0.85;
cruise_alt = 11000; %m
max_pax = 330; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 23616; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 9;
number_aisles = 2;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,number_aisles,N_deck,0,0);
% dimension.fuselage_length = 55.91;
% dimension.fuselage_diameter = 5.94;
dimension = dimension.finalise();



fuel = Ker;
B787_10 = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/B787_10.mat','B787_10');
B787_10.m_eng_input = 12240;
B787_10.eta_input = 0.5;
B787_10.AR_input = 9.59;
B787_10.sweep_input = 32.2;
B787_10.wing_area_input = 377;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
B787_10 = B787_10.finalise();
save('./saved-ac/B787_10.mat','B787_10');
%%
% running aircraft at operating point
oper_mission = copy(design_mission);
oper_mission.range = range*0.66;
oper_mission.load_factor = 0.50;
oper_mission.pax = oper_mission.max_pax * oper_mission.load_factor;
B787_10 = B787_10.operate(oper_mission);


%% running to max range

oper_mission = copy(design_mission);
oper_mission.load_factor = 1.0;
oper_mission = oper_mission.update();
max_range = B787_10.max_range(oper_mission);