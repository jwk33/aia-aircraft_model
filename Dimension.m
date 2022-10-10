classdef Dimension
    %Dimension, this class will contain all the dimensions of the aircraft
    %and be used to determine the cross section inside the cabin

    properties %all dimensions in m
        fuselage_diameter(1,1) double
        fuselage_length(1,1) double
        fuselage_internal_diameter(1,1) double
        cabin_length(1,1) double
        cockpit_length(1,1) double
        tank_external_diameter(1,1) double
        tank_external_length(1,1) double
        N_deck(1,1) double
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
            aisle_height = 1.8;
            aisle_length = obj.cabin_length;
            rear_length = 4;
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
            obj.cabin_length = ceil(mission.max_pax/(N_deck*seats_per_row))*seat_length;
            obj.cockpit_length = obj.fuselage_length - obj.cabin_length - obj.rear_length;
            cabin_width = seat_width*seats_per_row + aisle_width*number_aisles;
            obj.tank_external_diameter = obj.fuselage_internal_diameter - obj.cabin_height - 2*obj.tank_tolerance - (cabin_width^2)/obj.fuselage_internal_diameter;
            obj.tank_external_length = obj.cabin_length + obj.rear_length;
        end

        function obj = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end