classdef Dimension
    %Dimension, this class will contain all the dimensions of the aircraft
    %and be used to determine the cross section inside the cabin

    properties %all dimensions in m
        fuselage_diameter(1,1) double {mustBeNonnegative, mustBeFinite}
        fuselage_length(1,1) double {mustBeNonnegative, mustBeFinite}
        fuselage_internal_diameter(1,1) double {mustBeNonnegative, mustBeFinite}
        cabin_length(1,1) double {mustBeNonnegative, mustBeFinite}
        aisle_length(1,1) double {mustBeNonnegative, mustBeFinite}
        rear_length(1,1) double {mustBeNonnegative, mustBeFinite}
        tank_external_diameter(1,1) double {mustBeNonnegative, mustBeFinite}
        tank_external_length(1,1) double {mustBeNonnegative, mustBeFinite}
        N_deck(1,1) double {mustBeNonnegative, mustBeFinite}
        number_aisles double
        max_seats double
        seats_per_row double
        cabin_width double
    end

    properties (Constant)
        cabin_thickness = 0.15;%m
        seat_height = 1.6;
        seat_width = 0.4;
        seat_length = 0.81;
        bag_height = 0.25;
        bag_length = 0.81;
        bag_width = 0.4;
        aisle_width = 0.5;
        aisle_height = 1.6+0.25;
        cockpit_length = 4;
        tank_tolerance = 0.2;
        cabin_height = 1.6+0.25;%only used for initial tank sizing calculation
        toilet_length = 2;
        kitchen_length = 4;
    end

    methods
        function obj = Dimension(design_mission,seats_per_row,number_aisles,N_deck)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.max_seats = design_mission.max_pax;
            obj.seats_per_row = seats_per_row;
            obj.number_aisles = number_aisles;
            obj.N_deck = N_deck;

            
        end

        function obj = finalise(obj)
            %For now stick with the rectangle geometry. But have scope here
            %to look at alterantive designs
            obj.cabin_width = obj.seat_width*obj.seats_per_row + obj.aisle_width*obj.number_aisles;
            
            if obj.fuselage_length == 0 % no input fuselage dimensions so calculate min fuselage length
                obj.fuselage_length = ceil(obj.max_seats/(obj.N_deck*obj.seats_per_row))*obj.seat_length + obj.cockpit_length + obj.toilet_length + obj.kitchen_length;
                obj.fuselage_diameter = (obj.cabin_width^2 + obj.cabin_height^2)^0.5 + 2*obj.cabin_thickness;
            end

            obj.fuselage_internal_diameter = obj.fuselage_diameter - 2*obj.cabin_thickness;
            obj.cabin_length = ceil(obj.max_seats/(obj.N_deck*obj.seats_per_row))*obj.seat_length;
            obj.aisle_length = obj.cabin_length;
            obj.rear_length = obj.fuselage_length - obj.cabin_length - obj.cockpit_length - obj.toilet_length - obj.kitchen_length;
            obj.cabin_width = obj.seat_width*obj.seats_per_row + obj.aisle_width*obj.number_aisles;
            obj.tank_external_diameter = obj.fuselage_internal_diameter/2 - obj.cabin_height - 2*obj.tank_tolerance + ((obj.fuselage_diameter^2)/4 - (obj.cabin_width^2)/4)^0.5;
            obj.tank_external_length = obj.cabin_length + obj.rear_length;
        end
    end
end