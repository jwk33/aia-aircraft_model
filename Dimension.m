classdef Dimension < matlab.mixin.Copyable
    %Dimension, this class will contain all the dimensions of the aircraft
    %and be used to determine the cross section inside the cabin

    properties %all dimensions in m
        fuselage_diameter(1,1) double {mustBeNonnegative, mustBeFinite}
        fuselage_length(1,1) double {mustBeNonnegative, mustBeFinite}
        fuselage_internal_diameter(1,1) double {mustBeNonnegative, mustBeFinite}
        cabin_length(1,1) double {mustBeNonnegative, mustBeFinite}
        cabin_height (1,1) double 
        cabin_width double
        aisle_length(1,1) double {mustBeNonnegative, mustBeFinite}
        tank_external_diameter_u(1,1) double {mustBeNonnegative, mustBeFinite}
        tank_external_length_u(1,1) double {mustBeNonnegative, mustBeFinite}
        tank_external_diameter_i(1,1) double {mustBeNonnegative, mustBeFinite}
        tank_external_length_i(1,1) double {mustBeNonnegative, mustBeFinite}
        N_deck(1,1) double {mustBeNonnegative, mustBeFinite}
        number_aisles double % number of aisles per deck
        max_seats double
        seats_per_row double % number of seats abreast per deck
        cockpit_length double
        rear_length double
        cargo_height double
        rear_angle double
        seat_length double
    end

    properties (Constant)
        fuselage_thickness = 0.15;%m
        seat_height = 1.8;
        seat_width = 0.4;
%         seat_length = 0.81;
        bag_height = 0.25;
        bag_length = 0.81;
        bag_width = 0.4;
        aisle_width = 0.55;
        aisle_height = 1.6+0.25;
        tank_tolerance = 0.2;
        toilet_length = 0;
        kitchen_length = 0;
        cockpit_angle = 30;%To be changed ASAP
%         rear_angle = 24.5;%To be changed ASAP
    end

    methods
        function obj = Dimension(design_mission,seats_per_row,N_deck,tank_diameter_i,tank_length_i,tank_diameter_u,tank_length_u) % TODO: refactor dimension istance call
            %UNTITLED2 Construct an instance of this class
            %   The tank inputs are all as percentages. 
            %   For under(over)floor tanks they are as a percentage of 
            %   cabin width and cabin length
            %   For inline it it as a percentage of cabin length and
            %   fuselage diameter (after implementing underfloor)
            
            arguments
                design_mission Mission
                seats_per_row double % number of seats per row per deck
                N_deck double
                tank_diameter_i double {mustBeGreaterThanOrEqual(tank_diameter_i,0)} = 0% fraction of cabin width
                tank_length_i double {mustBeGreaterThanOrEqual(tank_length_i,0)} = 0 % fraction of cabin length
                tank_diameter_u double {mustBeGreaterThanOrEqual(tank_diameter_u,0)} = 0 % fraction of fuselage diameter
                tank_length_u double {mustBeGreaterThanOrEqual(tank_length_u,0)} = 0 % fraction of cabin length
            end

            obj.max_seats = design_mission.max_pax;
            obj.seats_per_row = seats_per_row;
            obj.N_deck = N_deck; 
            
            % set number of aisles
            if seats_per_row <= 6
                obj.number_aisles = 1;
            elseif seats_per_row <= 12
                obj.number_aisles = 2;
            else 
                obj.number_aisles = ceil(seats_per_row/6);
            end

            obj.cabin_width = obj.seat_width*obj.seats_per_row + obj.aisle_width*obj.number_aisles;

            % calculate non-seat fuselage dimensions (cockpit, tail,
            % galleys, cargo etc) (not including tanks)
            if obj.max_seats > 200
                obj.cargo_height = 1.8;
                obj.rear_angle = 30;
                obj.seat_length = 0.796 + 3.111e-4 * obj.max_seats;
                if obj.max_seats > 300
                    cabin_factor = 0.765 + obj.max_seats*1.866e-3;
                else
                    cabin_factor = 1.3;
                end
            else
                obj.cargo_height = 0;
                obj.rear_angle = 30;
                obj.seat_length = 0.8;
                cabin_factor = 1.3;
            end
            obj.cabin_height = N_deck*(obj.seat_height + obj.bag_height) + obj.cargo_height;

            obj.tank_external_diameter_u = tank_diameter_u*obj.cabin_width/100;

            min_fuselage_internal_diameter = (obj.cabin_width^2 + obj.cabin_height^2)^0.5;

            d_u = obj.tank_external_diameter_u + 2*obj.tank_tolerance;
            if d_u > sqrt(0.25*obj.cabin_width^2 + 0.25*obj.cabin_height) - obj.cabin_height/2
                obj.fuselage_internal_diameter = (0.25*obj.cabin_width^2 + (d_u+obj.cabin_height)^2)/(d_u+obj.cabin_height);%if tank pushes fuselage to bottom
            else 
                obj.fuselage_internal_diameter = min_fuselage_internal_diameter;%if tank is sufficiently small
            end
        
            obj.tank_external_diameter_i = tank_diameter_i*(obj.fuselage_internal_diameter - 2*obj.tank_tolerance);

            d_i = obj.tank_external_diameter_i + 2*obj.tank_tolerance;
            if d_i > obj.fuselage_internal_diameter%if tank oversizes min fuselage diameter
                obj.fuselage_internal_diameter = d_i;
            end
            obj.fuselage_diameter = obj.fuselage_internal_diameter + 2*obj.fuselage_thickness;

            if N_deck == 1
                number_toilets = ceil(obj.max_seats/100);
                obj.cockpit_length = obj.fuselage_diameter/(2*tand(obj.cockpit_angle));
                obj.rear_length = obj.fuselage_diameter/(tand(obj.rear_angle));
                obj.cabin_length = ceil(obj.max_seats/(obj.seats_per_row))*obj.seat_length + number_toilets*obj.toilet_length + obj.kitchen_length;
            else
                number_toilets = ceil(obj.max_seats/(N_deck*100));%avg toilets per deck % TODO: how many toilets per deck?
                obj.cockpit_length = obj.fuselage_diameter/(2*tand(obj.cockpit_angle));
                obj.rear_length = obj.fuselage_diameter/(tand(obj.rear_angle));
%                 delta_cab_length = floor(obj.cabin_height/(obj.seat_length*tand(obj.rear_angle)))*obj.seat_length;%extra cabin space on each deck as you go up
                delta_cab_length = 0;
                overall_cab_length = ceil(obj.max_seats/(obj.seats_per_row))*obj.seat_length + number_toilets*N_deck*obj.toilet_length + N_deck*obj.kitchen_length;
                cab_length = ceil((overall_cab_length - 0.5*delta_cab_length*N_deck*(N_deck-1))/(obj.seat_length*N_deck))*obj.seat_length;% top cabin
                obj.cabin_length = cab_length + (N_deck-1)*delta_cab_length;
            end
            
            obj.cabin_length = obj.cabin_length*cabin_factor;    

            
            obj.tank_external_length_u = tank_length_u*obj.cabin_length;
            obj.tank_external_length_i = tank_length_i*obj.cabin_length;


            if tank_length_u > 100
                cab_length = obj.cabin_length*tank_lenght_u;
            else
                cab_length = obj.cabin_length;
            end
            obj.fuselage_length = cab_length + obj.cockpit_length + obj.tank_external_length_i + obj.rear_length;
        end

        

        function obj = finalise(obj)
            %For now stick with the rectangle geometry. But have scope here
            %to look at alterantive designs
            obj.aisle_length = obj.cabin_length;
        end
    end
end