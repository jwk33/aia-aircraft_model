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
    end

    properties (SetAccess = immutable)
        mission Mission %used to get parameters like number of seats etc.
    end

    properties (Constant)
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
    end

    methods
        function obj = Dimension(mission,fuselage_diameter,fuselage_length,seats_per_row,number_aisles,N_deck)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.fuselage_diameter = fuselage_diameter;
            obj.fuselage_length = fuselage_length;
            obj.N_deck = N_deck;
            obj.fuselage_internal_diameter = obj.fuselage_diameter - 2*obj.cabin_thickness;
            obj.cabin_length = ceil(mission.max_pax/(N_deck*seats_per_row))*obj.seat_length;
            obj.aisle_length = obj.cabin_length;
            obj.rear_length = obj.fuselage_length - obj.cabin_length - obj.cockpit_length;
            cabin_width = obj.seat_width*seats_per_row + obj.aisle_width*number_aisles;
            obj.tank_external_diameter = obj.fuselage_internal_diameter/2 - obj.cabin_height - 2*obj.tank_tolerance + ((obj.fuselage_diameter^2)/4 - (cabin_width^2)/4)^0.5;
            obj.tank_external_length = obj.cabin_length + obj.rear_length;
        end
    end
end