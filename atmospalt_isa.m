function h = atmospalt_isa(p)
%Returns altitude h in m for a given pressure
%   Detailed explanation goes here
p0 = 101.325e3; %MPa

load("isa_table.mat", "isa_table")

p_array = p0 .* isa_table.p_frac;
alt_m = isa_table.alt_m;

h = interp1(p_array,alt_m,  p);
end