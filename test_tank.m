clear all
load("LH2_fuel.mat", "LH2")
ins_material = structfun(@(x) x,load('MLI.mat','MLI'));

struct_material = structfun(@(x) x,load('Aluminium.mat','aluminium'));
%%

diam_array = 4:2:8;
length_array = 1:0.1:5;
close
hold on
for i=1:length(diam_array)
    diameter = diam_array(i);
    l = [];
    AR = [];
    eta_grav = [];
    for j=1:length(length_array)
        tic
        
        len = length_array(j) * diameter;
        dimension = {};
        dimension.tank_external_length_i = len;
        dimension.tank_external_diameter_i = diameter;
    
        h2_tank = FuelTank(LH2, struct_material, ins_material);
        if len == diameter
            h2_tank.fuelTankType ="Spherical";
        end
        h2_tank.finalise(dimension);
        grav = h2_tank.gravimetric_efficiency;
        toc

        l = [l len];
        AR = [AR len/diameter];
        eta_grav = [eta_grav grav];
    end
    scatter(l, eta_grav)
end
ylim([50,100])
ylabel('Gravimetric Efficiency')
xlabel('Length (m)')
disp("tank calculated")

%%


tic
        
len = 3.9;
diameter = 3.9;
dimension = {};
dimension.tank_external_length_i = len;
dimension.tank_external_diameter_i = diameter;

h2_tank = FuelTank(LH2, struct_material, ins_material);
h2_tank.fuelTankType = "Spherical";
h2_tank.finalise(dimension);
grav = h2_tank.gravimetric_efficiency;
toc
%%
tic
        
len = 10;
diameter = len-0.1;
dimension = {};
dimension.tank_external_length_i = len;
dimension.tank_external_diameter_i = diameter;

h2_tank = FuelTank(LH2, struct_material, ins_material);
h2_tank.fuelTankType = "Cylindrical";
h2_tank.finalise(dimension);
grav = h2_tank.gravimetric_efficiency;
toc