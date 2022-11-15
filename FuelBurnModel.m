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
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj.calculate(aircraft,design_mission);
        end

        function obj = FuelBurn_Iteration(obj,aircraft, design_mission)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj = obj.calculate(aircraft, design_mission);
        end

        function obj = operate(obj,aircraft,oper_mission)
            obj = obj.calculate(aircraft, oper_mission);
        end


    end
    methods (Access = private)
        
        function obj = calculate(obj,aircraft, mission)
            g = 9.81;
            theta = mission.angle_TO;
            if mission.range*1000 > 2*mission.cruise_alt/tand(theta)
                h = mission.cruise_alt;
            else
                h = mission.range*1000*tand(theta)/2;
            end
            eta_ov = aircraft.engine.eta_ov;
            lhv = aircraft.fuel.lhv;
            LovD = aircraft.aero.LovD;
            m_TO = aircraft.weight.m_TO;
            m_toc = m_TO*(1 - (mission.cruise_speed)/(2*eta_ov*lhv))*exp((-g*h)*(1+(cosd(theta)^2)/(LovD*sind(theta)))/(eta_ov*lhv));%kg
%             disp(m_toc)l
            obj.m_fuel_climb = m_TO - m_toc;%kg
%             disp(obj.m_fuel_climb)
            climb_range = h/tand(theta);
            obj.m_fuel_descent = 0.1*obj.m_fuel_climb;%kg
            descent_range = climb_range; %TODO: define actualy descent calcualtions

            cruise_range = mission.range*1000-climb_range-descent_range;
            obj.m_fuel_cruise = m_toc*(1-exp(-cruise_range*g/(lhv*eta_ov*LovD)));%kg

            obj.m_fuel_mission = (obj.m_fuel_cruise+obj.m_fuel_climb+obj.m_fuel_descent);%kg including a 5% reserve

            reserve_range = 45*60*mission.cruise_speed; %m
            % reserves calculated at the end of cruise
            obj.m_fuel_reserve = (m_toc - obj.m_fuel_cruise)*(1-exp(-reserve_range*g/(lhv*eta_ov*LovD))) + 0.05* obj.m_fuel_mission;%kg
            
            obj.m_fuel = (obj.m_fuel_mission + obj.m_fuel_reserve);%kg
        end
    end
end