close
clc
clear

%%
range = 10e3; %km
M = 0.81;
cruise_alt = 10e3; %m
max_pax = 370;
cargo = 31.113e3;%32.113e3; %kg

load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

N_deck = 1;
seats_per_row = 10;
year = 2021;
optimism = "basic";

%% kerosene aircraft

load("Fuels\Ker.mat","Ker");

dimension = Dimension(design_mission, seats_per_row, N_deck);
dimension = dimension.finalise();

ac_Ker = Aircraft(Ker, design_mission, dimension);

% ac_Ker.manual_input.eta_eng = 0.55;
% ac_Ker.manual_input.eta_prop = 0.7;
%ac_Ker.manual_input.bpr = 9;
ac_Ker.year = year;
ac_Ker.optimism = optimism;
ac_Ker = ac_Ker.finalise();

ac_Ker.text_gen("Ker")

%%
tic
load("Fuels\CH4.mat", "CH4")

ins_material = structfun(@(x) x,load('Materials\MLI.mat','MLI'));

struct_material = structfun(@(x) x,load('Materials\Aluminium.mat','aluminium'));

ac_inputs = {};
ac_inputs.range =range;
ac_inputs.M = M;
ac_inputs.m_cargo = cargo;
ac_inputs.max_pax = max_pax;
ac_inputs.seats_abreast_array = seats_per_row;
ac_inputs.N_deck = N_deck;
%ac_inputs.eta = 0.48;
ac_inputs.number_engines = 2;
ac_inputs.design_mission = copy(design_mission);
ac_inputs.struct_material = struct_material;
ac_inputs.ins_material = ins_material;
ac_inputs.fuel = CH4;

ac_inputs.ac = designH2AC(ac_inputs,year,optimism);
ac_inputs.ac.text_gen("CH4")
toc

%% h2 test function

load("Fuels\LH2.mat", "LH2")
tic

ac_inputs = {};
ac_inputs.range =range;
ac_inputs.M = M;
ac_inputs.m_cargo = cargo;
ac_inputs.max_pax = max_pax;
ac_inputs.seats_abreast_array = seats_per_row;
ac_inputs.N_deck = N_deck;
%ac_inputs.eta = 0.48;
ac_inputs.number_engines = 2;
ac_inputs.design_mission = copy(design_mission);
ac_inputs.struct_material = struct_material;
ac_inputs.ins_material = ins_material;
ac_inputs.fuel = LH2;

ac_inputs.ac = designH2AC(ac_inputs,year,optimism);
ac_inputs.ac.text_gen("H2")
toc