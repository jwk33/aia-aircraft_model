classdef Dimension
    %Dimension, this class will contain all the dimensions of the aircraft
    %and be used to determine the cross section inside the cabin

    properties %all dimensions in m
        fuselage_diameter(1,1) double
        fuselage_length(1,1) double
        cockpit_length(1,1) double
        rear_length(1,1) double
        cabin_length(1,1) double
        cabin_thickness(1,1) double
        cabin_diameter(1,1) double
        seat_height(1,1) double
        seat_width(1,1) double
        seat_length(1,1) double
        bag_height(1,1) double
        bag_width(1,1) double
        bag_length(1,1) double
        aisle_width(1,1) double
        aisle_height(1,1) double
        aisle_length(1,1) double
    end

    properties (SetAccess = immutable)
        mission Mission %used to get parameters like number of seats etc.
    end

    methods
        function obj = Dimension(mission)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            if mission.max_pax*0.0161 < 1.5
                obj.fuselage_diameter = 3;
            else
                obj.fuselage_diameter = mission.max_pax*0.0161 + 1.5;
            end
            if mission.max_pax*0.153 + 15 > 80
                obj.fuselage_length = 80;
            else
                obj.fuselage_length = mission.max_pax*0.153 + 15;
            end
            obj.cockpit_length = 4;
            obj.rear_length = 4;
            obj.cabin_length = obj.fuselage_length - obj.cockpit_length - obj.rear_length;
            obj.cabin_thickness = 0.15;
            obj.cabin_diameter = obj.fuselage_diameter - 2*obj.cabin_thickness;
            obj.seat_height = 1.8;
            obj.seat_width = 0.45;
            obj.seat_length = 0.45+0.8;
            obj.bag_height = 0.25;
            obj.bag_length = obj.seat_height;
            obj.bag_width = obj.seat_width;
            obj.aisle_width = 0.5;
            obj.aisle_height = obj.seat_height;
            obj.aisle_length = obj.cabin_length;

        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end