classdef Dimension
    %Dimension, this class will contain all the dimensions of the aircraft
    %and be used to determine the cross section inside the cabin

    properties %all dimensions in m
        fuselage_diameter(1,1) double {mustBeNonnegative, mustBeFinite}
        fuselage_length(1,1) double {mustBeNonnegative, mustBeFinite}
        fuselage_internal_diameter(1,1) double {mustBeNonnegative, mustBeFinite}
        cabin_length(1,1) double {mustBeNonnegative, mustBeFinite}
        cabin_height (1,1) double 
        aisle_length(1,1) double {mustBeNonnegative, mustBeFinite}
        tank_external_diameter(1,1) double {mustBeNonnegative, mustBeFinite}
        tank_external_length(1,1) double {mustBeNonnegative, mustBeFinite}
        N_deck(1,1) double {mustBeNonnegative, mustBeFinite}
        number_aisles double
        max_seats double
        seats_per_row double
        cabin_width double
        cockpit_length double
        rear_length double
    end

    properties (Constant)
        fuselage_thickness = 0.15;%m
        seat_height = 1.6;
        seat_width = 0.4;
        seat_length = 0.81;
        bag_height = 0.25;
        bag_length = 0.81;
        bag_width = 0.4;
        aisle_width = 0.5;
        aisle_height = 1.6+0.25;
        tank_tolerance = 0.2;
        toilet_length = 2;
        kitchen_length = 4;
        cockpit_angle = 30;%To be changed ASAP
        rear_angle = 30;%To be changed ASAP
    end

    methods
        function obj = Dimension(design_mission,seats_per_row,number_aisles,N_deck,tank_diameter,tank_length_percentage)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.max_seats = design_mission.max_pax;
            obj.seats_per_row = seats_per_row;
            obj.number_aisles = number_aisles;
            obj.N_deck = N_deck; 
            obj.cabin_width = obj.seat_width*obj.seats_per_row + obj.aisle_width*obj.number_aisles;
            obj.cabin_height = N_deck*(obj.seat_height + obj.bag_height);
            obj.tank_external_diameter = tank_diameter;
            d = obj.tank_external_diameter + 2*obj.tank_tolerance;
            if tank_diameter == 0
                obj.fuselage_internal_diameter = (obj.cabin_width^2 + obj.cabin_height^2)^0.5;
            elseif d > sqrt(0.25*obj.cabin_width^2 + 0.25*obj.cabin_height) - obj.cabin_height/2
                obj.fuselage_internal_diameter = (0.25*obj.cabin_width^2 + (d+obj.cabin_height)^2)/(d+obj.cabin_height);%if tank pushes fuselage to bottom
            else 
                obj.fuselage_internal_diameter = (obj.cabin_width^2 + obj.cabin_height^2)^0.5;%if tank is sufficiently small
            end
            obj.fuselage_diameter = obj.fuselage_internal_diameter + 2*obj.fuselage_thickness;

            if N_deck == 1
                number_toilets = ceil(obj.max_seats/100);
                obj.cockpit_length = obj.fuselage_diameter/(2*tand(obj.cockpit_angle));
                obj.rear_length = obj.fuselage_diameter/(2*tand(obj.rear_angle));
                obj.cabin_length = ceil(obj.max_seats/(obj.seats_per_row))*obj.seat_length + number_toilets*obj.toilet_length + obj.kitchen_length;
                obj.fuselage_length = obj.cabin_length + obj.cockpit_length + obj.rear_length;
            else
                number_toilets = ceil(obj.max_seats/N_deck*100);%avg toilets per deck
                obj.cockpit_length = obj.fuselage_diameter/(2*tand(obj.cockpit_angle));
                obj.rear_length = obj.fuselage_diameter/(tand(obj.rear_angle));
%                 cab_length = ceil(obj.max_seats/(obj.seats_per_row))*obj.seat_length + number_toilets*obj.toilet_length + 2*obj.kitchen_length;
                delta_cab_length = floor(obj.cabin_height/obj.seat_length*tand(obj.rear_angle))*obj.seat_length;%extra cabin space on each deck as you go up
                overall_cab_length = ceil(obj.max_seats/(obj.seats_per_row))*obj.seat_length + number_toilets*N_deck*obj.toilet_length + N_deck*obj.kitchen_length;
                cab_length = ceil((overall_cab_length - 0.5*delta_cab_length*N_deck*(N_deck-1))/obj.seat_length*N_deck)*obj.seat_length;% top cabin
                obj.cabin_length = cab_length + (N_deck-1)*delta_cab_length;
                obj.fuselage_length = cab_length + obj.cockpit_length + obj.rear_length; 
            end
            if tank_length_percentage > 100
                obj.tank_external_length = obj.cabin_length;
            elseif tank_length_percentage < 0
                obj.tank_external_length = 0;
            else
                obj.tank_external_length = tank_length_percentage*obj.cabin_length/100;
            end
        end

        function obj = finalise(obj)
            %For now stick with the rectangle geometry. But have scope here
            %to look at alterantive designs
            obj.aisle_length = obj.cabin_length;
        end
    end
end