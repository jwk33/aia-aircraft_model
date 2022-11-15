
range = 10e3; %km
M = 0.81;
cruise_alt = 10e3; %m
max_pax = 370;
cargo = 31.113e3;%32.113e3; %kg

load_factor = 1.0;
design_mission = Mission(range, M, cruise_alt, max_pax,load_factor, cargo);

N_deck = 1;
seats_per_row = 10;
year = 2050;
optimism = "basic";

%% kerosene aircraft

load("Ker_fuel.mat","Ker");

dimension = Dimension(design_mission, seats_per_row, N_deck);
dimension = dimension.finalise();

ac_Ker = Aircraft(Ker, design_mission, dimension);

% ac_Ker.manual_input.eta_eng = 0.55;
% ac_Ker.manual_input.eta_prop = 0.7;
ac_Ker.manual_input.bpr = 9;
ac_Ker.year = year;
ac_Ker.optimism = optimism;
ac_Ker = ac_Ker.finalise();

ac_Ker.text_gen("Ker")
%% Hydrogen Aircraft
tic
load("LH2_Fuel.mat","LH2")

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

length_frac_array = 0.2:0.01:1.0;
seats_abreast_array = [7,8,9,10,11,12,13,14];
acTemplate = Aircraft(LH2,design_mission,dimension);
acMat = repmat(acTemplate,[length(seats_abreast_array),length(length_frac_array)]);

for i = 1:length(seats_abreast_array)
    seats_abreast = seats_abreast_array(i);
    for j=1:length(length_frac_array)
        
        length_frac = length_frac_array(j);
    
        dimension = Dimension(design_mission,seats_abreast,N_deck,1.0,length_frac,0,0);
        dimension = dimension.finalise();
    
        % SETUP A FUEL TANK
        h2_tank = FuelTank(LH2,struct_material, ins_material);
        h2_tank = h2_tank.finalise(dimension);
        
        % SETUP AN INSTANCE OF AIRCRAFT CLASS        
        ac = Aircraft(LH2,design_mission,dimension);
        
    
        ac.tank = h2_tank;
        
        ac.manual_input.eta_eng = 0.48;
        ac.year = year;
        ac.optimism = optimism;
        
        % All inputs defined. Now for the aircraft sizing loop to begin to
        % calculate MTOW
        ac = ac.finalise();
    
        acMat(i,j) = copy(ac);
        
    end
end
fuelBurn = zeros(size(acMat));
fuelTank = zeros(size(acMat));
fuelErr = zeros(size(acMat));

for i=1:length(seats_abreast_array)
    for j=1:length(length_frac_array)
        fuelBurn(i,j) = acMat(i,j).weight.m_Fuel;
        fuelTank(i,j) = acMat(i,j).tank.m_fuelMax;
        fuelErr(i,j) = fuelTank(i,j) - fuelBurn(i,j);
        
    end
end

[row,col] = find(fuelErr > 0);


assert(length(row) >=1, "No Solution Found")


acMat_new = cell(size(acMat));

fuelBurn_new = NaN(size(acMat));
fuelTank_new = NaN(size(acMat));

n = length(row); %number of valid entries

x = acMat();

for i=1:n
    x = row(i);
    y = col(i);
    acMat_new{x,y} = copy(acMat(x,y));
    fuelBurn_new(x,y) = fuelBurn(x,y);
    fuelTank_new(x,y) = fuelTank_new(x,y);
end

minFuel = min(fuelBurn_new(:));
[row, col] = find(fuelBurn_new == minFuel);
if length(row) > 1
    disp("check minimum")
end
ac_H2 = acMat(row,col);
ac_H2.text_gen("H2_whole");
toc
%% H2 Aircraft Optimised
tic
load("LH2_Fuel.mat","LH2")

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



seats_abreast_array = [7,8,9,10,11,12,13,14];
ac_list = cell(size(seats_abreast_array));
minFuel = 999999;
for j=1:length(seats_abreast_array)
    seats_abreast = seats_abreast_array(j);

    c = Convergence();
    c.conv_var = "Length Error";
    length_frac = 0.1;
    
    i = 1;
    while abs(c.conv_err) > c.conv_margin && i <= c.max_i
        if i ~= 1
            
            length_frac = length_frac *  (1 - c.conv_err);
        end
    
        dimension = Dimension(design_mission,seats_abreast,N_deck,1.0,length_frac,0,0);
        dimension = dimension.finalise();
        
        % SETUP A FUEL TANK
        h2_tank = FuelTank(LH2,struct_material, ins_material);
        h2_tank = h2_tank.finalise(dimension);
        
        % SETUP AN INSTANCE OF AIRCRAFT CLASS        
        ac = Aircraft(LH2,design_mission,dimension);
    
        ac.tank = h2_tank;
            
        ac.manual_input.eta_eng = 0.48;
        
        ac.year = year;
        ac.optimism = optimism;
        % All inputs defined. Now for the aircraft sizing loop to begin to
        % calculate MTOW
        ac = ac.finalise();
        
        c.conv_err = (ac.tank.m_fuelMax - ac.weight.m_Fuel)/ac.tank.m_fuelMax;
        
        i = i +1;
    end
    
    if abs(c.conv_err) < c.conv_margin && i <= c.max_i
        c.conv_i = i;
        c.conv_bool = 1;
        disp("Solution converged")

        ac_list{j} = copy(ac);
    else
        c.conv_bool = 0;
    end

    if ~isempty(ac_list{j}) && ac_list{j}.weight.m_Fuel<minFuel
        ac_best = ac_list{j};
        minFuel = ac_best.weight.m_Fuel;

    end
end


ac_best.text_gen("H2_optim")

toc

%% h2 test function
tic
ac_inputs = {};
ac_inputs.range =range;
ac_inputs.M = M;
ac_inputs.m_cargo = cargo;
ac_inputs.max_pax = max_pax;
ac_inputs.seats_abreast_array = seats_abreast_array;
ac_inputs.N_deck = N_deck;
ac_inputs.eta = 0.48;
ac_inputs.number_engines = 2;
ac_inputs.design_mission = copy(design_mission);
ac_inputs.struct_material = struct_material;
ac_inputs.ins_material = ins_material;
ac_inputs.fuel = LH2;

ac_inputs.ac = designH2AC(ac_inputs,year,optimism);
ac_inputs.ac.text_gen("H2_Func")
toc
