%%
clear all
close all

%% DD CONSTANT INPUTS
load("Fuels\Ker.mat","Ker")

range = 12222;%km
M = 0.83;
cruise_alt = 10000; %m
max_pax = 525;%737 Max - 8
cargo = 31160; %kg
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 10;
N_deck = 2;

dimension = Dimension(design_mission,seats_per_row,N_deck,0,0);
% dimension.fuselage_length = 39.12;
% dimension.fuselage_diameter = 4.01;
dimension = dimension.finalise();


% B737 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
A380 = Aircraft(fuel,design_mission,dimension);
% A380.manual_input.m_eng = 24984;
A380.manual_input.eta_eng = 0.5;
% A380.manual_input.AR = 7.53;
% A380.manual_input.sweep = 30;
% A380.manual_input.wing_area = 845;

A380.year = 2021;
save('./saved-ac/A380.mat','A380');

% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
A380 = A380.finalise();
save('./saved-ac/A380.mat','A380');

%% B737 CONSTANT INPUTS
load("Fuels\Ker.mat","Ker")

range = 4815;%km
M = 0.79;
cruise_alt = 10000; %m
max_pax = 178;%737-800
cargo = 2726; %kg
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 6;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,N_deck,0,0);
% dimension.fuselage_length = 39.12;
% dimension.fuselage_diameter = 4.01;
dimension = dimension.finalise();


% B737 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
B737 = Aircraft(fuel,design_mission,dimension);
% B737.manual_input.m_eng = 5560;
B737.manual_input.eta_eng = 0.39;
% B737.manual_input.AR = 10.16;
% B737.manual_input.sweep = 25;
%B737.manual_input.wing_area = 127;

B737.year = 2021;
save('./saved-ac/B737.mat','B737');

% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
B737 = B737.finalise();
save('./saved-ac/B737.mat','B737');
B737.text_gen("B737")


%% B777300ER CONSTANT INPUTS
load("Fuels\Ker.mat","Ker")

range = 10550;%km
M = 0.84;
cruise_alt = 10000; %m
max_pax = 396;
cargo = 29462; %kg
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 9;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,N_deck,0,0);
% dimension.fuselage_length = 73.08;
% dimension.fuselage_diameter = 6.2;
dimension = dimension.finalise();


% B777 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
B777 = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/B777.mat','B777');
% B777.manual_input.m_eng = 17524;
B777.manual_input.eta_eng = 0.5;
% B777.manual_input.AR = 9.61;
% B777.manual_input.sweep = 31.6;
% B777.manual_input.wing_area = 436.8;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
B777 = B777.finalise();
save('./saved-ac/B777.mat','B777');

%% ATR-72-600 CONSTANT INPUTS
load("Fuels\Ker.mat","Ker")

range = 1370;%km
M = 0.44;
cruise_alt = 6096; %m
max_pax = 72; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = -504; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo 56 kg for full payload
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 4;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,N_deck,0,0);
% dimension.fuselage_length = 27;
% dimension.fuselage_diameter = 2.9;
dimension = dimension.finalise();


% ATR-72-600 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
ATR_72_600 = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/ATR_72_600.mat','ATR_72_600');
% ATR_72_600.manual_input.m_eng = 960;
ATR_72_600.manual_input.eta_eng = 0.45;
% ATR_72_600.manual_input.sweep = 0;
% ATR_72_600.manual_input.AR = 12;
% ATR_72_600.manual_input.wing_area = 61;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
ATR_72_600 = ATR_72_600.finalise();
save('./saved-ac/ATR_72_600.mat','ATR_72_600');

%% A320neo CONSTANT INPUTS
load("Fuels\Ker.mat","Ker")

range = 4500;%km
M = 0.78;
cruise_alt = 10000; %m
max_pax = 165; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 2470; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 6;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,N_deck,0,0);
% dimension.fuselage_length = 37.57;
% dimension.fuselage_diameter = 3.95;
dimension = dimension.finalise();


% A320neo SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
A320neo = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/A320neo.mat','A320neo');
% A320neo.manual_input.m_eng = 5714;
A320neo.manual_input.eta_eng = 0.42;
A320neo.manual_input.bpr = 11;
A320neo.manual_input.AR = 10.3;
A320neo.manual_input.sweep = 25;
A320neo.manual_input.wing_area = 122.6;

% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
A320neo = A320neo.finalise();
save('./saved-ac/A320neo.mat','A320neo');
A320neo.text_gen("A320neo")

%% A330neo - 900 CONSTANT INPUTS
load("Fuels\Ker.mat","Ker")

range = 8800;%km
M = 0.84;
cruise_alt = 11000; %m
max_pax = 300; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 15200; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 8;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,N_deck,0,0);
% dimension.fuselage_length = 63.66;
% dimension.fuselage_diameter = 5.86;
dimension = dimension.finalise();


% A330neo - 900 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
A330neo = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/A330neo.mat','A330neo');
% A330neo.manual_input.m_eng = 12890;
A330neo.manual_input.eta_eng = 0.48;
A330neo.manual_input.AR = 10;
A330neo.manual_input.sweep = 31.9;
A330neo.manual_input.wing_area = 410;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
A330neo = A330neo.finalise();
save('./saved-ac/A330neo.mat','A330neo');
A330neo.text_gen("A330neo")
%% A350 - 900 CONSTANT INPUTS
load("Fuels\Ker.mat","Ker")

range = 10750;%km
M = 0.85;
cruise_alt = 10000; %m
max_pax = 325; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 20650; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 9;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,N_deck,0,0);
% dimension.fuselage_length = 65.26;
% dimension.fuselage_diameter = 5.96;
dimension = dimension.finalise();


% A350 - 900 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
A350_900 = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/A350_900.mat','A350_900');
% A350_900.manual_input.m_eng = 14554;
A350_900.manual_input.eta_eng = 0.45;
A350_900.manual_input.bpr = 9.6;
A350_900.manual_input.AR = 9.49;
A350_900.manual_input.sweep = 35;
% A350_900.manual_input.wing_area = 442;

A350_900.year = 2035;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
A350_900 = A350_900.finalise();
save('./saved-ac/A350_900.mat','A350_900');
A350_900.text_gen("A350")

%% A350 - 1000 CONSTANT INPUTS
load("Fuels\Ker.mat","Ker")

range = 10370;%km
M = 0.85;
cruise_alt = 10000; %m
max_pax = 366; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 30668; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 9;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,N_deck,0,0);
% dimension.fuselage_length = 66.80;
% dimension.fuselage_diameter = 5.96;
dimension = dimension.finalise();


% A350 - 1000 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
A350_1000 = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/A350_1000.mat','A350_1000');
% A350_1000.manual_input.m_eng = 15100;
A350_1000.manual_input.eta_eng = 0.5;
% A350_1000.manual_input.AR = 9.03;
% A350_1000.manual_input.sweep = 31.9;
% A350_1000.manual_input.wing_area = 464.3;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
A350_1000 = A350_1000.finalise();
save('./saved-ac/A350_1000.mat','A350_1000');

%% B787 - 10 CONSTANT INPUTS
load("Fuels\Ker.mat","Ker")

range = 7777;%km
M = 0.85;
cruise_alt = 11000; %m
max_pax = 330; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 23616; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 9;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,N_deck,0,0);
% dimension.fuselage_length = 55.91;
% dimension.fuselage_diameter = 5.94;
dimension = dimension.finalise();


% A350 - 1000 SETUP AN INSTANCE OF AIRCRAFT CLASS

fuel = Ker;
B787_10 = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/B787_10.mat','B787_10');
% B787_10.manual_input.m_eng = 12240;
B787_10.manual_input.eta_eng = 0.5;
% B787_10.manual_input.AR = 9.59;
% B787_10.manual_input.sweep = 32.2;
B787_10.manual_input.wing_area = 377;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
B787_10 = B787_10.finalise();
save('./saved-ac/B787_10.mat','B787_10');

%% B787 - 10 CONSTANT INPUTS
load("Fuels\Ker.mat","Ker")

range = 7777;%km
M = 0.85;
cruise_alt = 11000; %m
max_pax = 330; %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
cargo = 23616; %kg %input to match the data on payload range from brochure. 72PAX @ 95kg no cargo
load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

seats_per_row = 9;
N_deck = 1;

dimension = Dimension(design_mission,seats_per_row,N_deck,0,0);
% dimension.fuselage_length = 55.91;
% dimension.fuselage_diameter = 5.94;
dimension = dimension.finalise();



fuel = Ker;
B787_10 = Aircraft(fuel,design_mission,dimension);
save('./saved-ac/B787_10.mat','B787_10');
% B787_10.manual_input.m_eng = 12240;
B787_10.manual_input.eta_eng = 0.2;
% B787_10.manual_input.AR = 9.59;
% B787_10.manual_input.sweep = 32.2;
% B787_10.manual_input.wing_area = 377;
% All inputs defined. Now for the aircraft sizing loop to begin to
% calculate MTOW
B787_10 = B787_10.finalise();
save('./saved-ac/B787_10.mat','B787_10');

%% running to max range

oper_mission = copy(design_mission);
oper_mission.load_factor = 1.0;
oper_mission = oper_mission.update();
max_range = B787_10.max_range(oper_mission);
%%
% running aircraft at operating point
oper_mission = copy(design_mission);
oper_mission.range = max_range;
oper_mission.load_factor = 1.0;
oper_mission.pax = oper_mission.max_pax * oper_mission.load_factor;
B787_10 = B787_10.operate(oper_mission);

