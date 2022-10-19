function [fuselage_length, fuselage_diameter] = Find_Dimensions(mission,seats_per_row,number_aisles,N_deck)
    %For now stick with the rectangel geometry. But have scope here
    %to look at alterantive designs
    cabin_thickness = 0.15;%m
    seat_height = 1.8;
    seat_width = 0.45;
    seat_length = 0.45+0.8;
    bag_height = 0.25;
    bag_length = 1.8;
    bag_width = 0.45;
    aisle_width = 0.5;
    aisle_height = 1.8+0.25;
    cockpit_length = 4;
    tank_tolerance = 0.2;
    cabin_height = 1.8+0.25;%only used for initial tank sizing calculation
    fuselage_length = ceil(mission.max_pax/(N_deck*seats_per_row))*seat_length + cockpit_length;
    cabin_width = seat_width*seats_per_row + aisle_width*number_aisles;
    fuselage_diameter = (cabin_width^2 + cabin_height^2)^0.5 + 2*cabin_thickness;
end