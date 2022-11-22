classdef FuelBurnModel < matlab.mixin.Copyable
    %FuelBurnModel class handles the operation of the aircraft for the
    %input mission. It calculates fuel mass.
    %   Detailed explanation goes here

    properties (SetAccess = {?Aircraft})
        m_fuel(1,1) double {mustBeNonnegative, mustBeFinite}
        m_fuel_mission(1,1) double {mustBeNonnegative, mustBeFinite}
        m_fuel_reserve(1,1) double {mustBeNonnegative, mustBeFinite}

        m_fuel_climb(1,1) double {mustBeNonnegative, mustBeFinite}
        m_fuel_cruise(1,1) double {mustBeNonnegative, mustBeFinite}
        m_fuel_descent(1,1) double {mustBeNonnegative, mustBeFinite}
    end

    methods
        function obj = FuelBurnModel(aircraft, design_mission)
            % Sets up instance of FuelBurnModel
            %   Defines fuel burn model properties and calculates first
            %   iteration of mass of fuel required given the input take-off
            %   weight and other aircraft properties
            obj = obj.calculate(aircraft,design_mission);
        end

        function obj = FuelBurn_Iteration(obj,aircraft, design_mission)
            % Re-calculates fuel burn during the design iteration loop
            %   Takes design mission and the aircraft at current iteration
            %   to calculate fuel burn for the mission and reserves.
            obj = obj.calculate(aircraft, design_mission);
        end

        function obj = operate(obj,aircraft,oper_mission)
            % Calculates fuel burn for a given operation mission.
            obj = obj.calculate(aircraft, oper_mission);
        end


    end
    methods (Access = private)
        
        function obj = calculate(obj,aircraft, mission)
            % unpack variables from aircraft
            g       = 9.81;
            theta   = mission.angle_TO;
            eta_ov  = aircraft.engine.eta_ov;
            lhv     = aircraft.fuel.lhv;
            LovD    = aircraft.aero.LovD;
            m_TO    = aircraft.weight.m_TO;
            V_cr    = mission.cruise_speed;
            total_distance = mission.range*1e3; %m

            % using default cruise altitude and climb angle
            climb_range = mission.cruise_alt/tand(theta);
            descent_range = climb_range; %TODO: define actualy descent calcualtions
            
            % check that overall distance is greater than (climb + descent
            % range)
            if total_distance > (climb_range + descent_range) 
                h = mission.cruise_alt;
                cruise_range = total_distance-(climb_range+descent_range);
            else % no cruise region. climb for half the journey and descend for half the journey.
                climb_range = total_distance / 2;
                descent_range = climb_range;
                h = climb_range * tand(theta);
                cruise_range = 0;
            end
            
            % CLIMB SEGMENT
            m_toc = m_TO*(1 - (mission.cruise_speed)/(2*eta_ov*lhv))*exp((-g*h)*(1+(cosd(theta)^2)/(LovD*sind(theta)))/(eta_ov*lhv));%kg
            obj.m_fuel_climb = m_TO - m_toc;%kg

            % CRUISE SEGMENT
            obj.m_fuel_cruise = m_toc*(1-exp(-cruise_range*g/(lhv*eta_ov*LovD)));%kg
            
            % DESCENT SEGMENT
            obj.m_fuel_descent = 0.1*obj.m_fuel_climb;%kg

            % OVERALL MISSION
            obj.m_fuel_mission = (obj.m_fuel_cruise+obj.m_fuel_climb+obj.m_fuel_descent);%kg including a 5% reserve
            
            % RESERVES
            reserve_range = 45*60*mission.cruise_speed; %m
            % reserves calculated at the end of cruise
            obj.m_fuel_reserve = (m_toc - obj.m_fuel_cruise)*(1-exp(-reserve_range*g/(lhv*eta_ov*LovD))) + 0.05* obj.m_fuel_mission;%kg
            
            % TOTAL FUEL
            obj.m_fuel = (obj.m_fuel_mission + obj.m_fuel_reserve);%kg
        end
    end
end