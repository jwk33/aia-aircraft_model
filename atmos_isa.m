function p = atmos_isa(h)
%atmos_isa Returns pressure in Pa for input altitude in m
%   Detailed explanation goes here
p0 = 101.325e3; %MPa

tic
load("isa_table.mat", "isa_table")
toc

p_array = p0 .* isa_table.p_frac;
alt_m = isa_table.alt_m;

p = interp1(alt_m, p_array, h);
end