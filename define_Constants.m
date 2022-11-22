close all
clear
clc

%%
% define tank structural material
density = 2700; %kg/m3
yield_strength = 276e6; %Pa
thermal_conductivity = 236; %W / m K
name = "Aluminium";
aluminium = Material(name,"Structural",density,yield_strength,thermal_conductivity);
save("Materials\Aluminium.mat", "aluminium")

density = 50; %kg/m3
yield_strength = 1e6; %Pa
thermal_conductivity = 1e-4; %W / m K
name = "Multi-Layered Insulation";
MLI = Material(name,"Insulation",density,yield_strength,thermal_conductivity);
save("Materials\MLI.mat", "MLI")


density = 32; %kg/m3
yield_strength = 1e6; %Pa
thermal_conductivity = 6e-3; %W / m K
name = "Polyurethane Foam";
PU_Foam = Material(name,"Insulation",density,yield_strength,thermal_conductivity);
save("Materials\PU-Foam.mat", "PU_Foam")
%% Fuels
name = "Liquid Hydrogen";
lhv = 120e6; %J/kg
density = 70.17; %kg/m3
useTankModel = 1.0;
Temperature = 20.13; %K % Fuel storage temperature
specific_CO2 = 0;
LH2 = Fuel(name, lhv,density, specific_CO2,Temperature,useTankModel);
save("Fuels\LH2.mat", "LH2")

name = "Fossil Jet Fuel";
lhv = 43.2e6; %J/kg
density = 807.5; %kg/m3
specific_CO2 = 3.15;
Ker = Fuel(name, lhv,density, specific_CO2);
save("Fuels\Ker.mat", "Ker")

name = "Methane";
lhv = 50.0e6; %J/kg
density = 422.8; %kg/m3
Temperature = 111.15; % K % Fuel storage temperature
useTankModel = 1;
specific_CO2 = 2.75;
CH4 = Fuel(name, lhv,density, specific_CO2,Temperature,useTankModel);
save("Fuels\CH4.mat", "CH4")

clearvars -except LH2 Ker CH4