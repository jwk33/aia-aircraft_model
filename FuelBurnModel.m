classdef FuelBurnModel < handle
    %FuelBurnModel class handles the operation of the aircraft for the
    %input mission. It calculates fuel mass.
    %   Detailed explanation goes here

    properties (SetAccess = private)
        m_fuel(1,1) double {mustBeNonnegative, mustBeFinite}
        m_fuel_mission(1,1) double {mustBeNonnegative, mustBeFinite}
        m_fuel_reserve(1,1) double {mustBeNonnegative, mustBeFinite}

        m_fuel_climb(1,1) double {mustBeNonnegative, mustBeFinite}
        m_fuel_cruise(1,1) double {mustBeNonnegative, mustBeFinite}
        m_fuel_descent(1,1) double {mustBeNonnegative, mustBeFinite}
    end

    methods
        function obj = FuelBurnModel(aircraft,fuel,mission,aero,engine)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            g = 9.81;
            theta = mission.angle_TO;
            if mission.range*1000 > 2*mission.cruise_alt/tand(theta)
                h = mission.cruise_alt;
            else
                h = mission.range*1000*1000*tand(theta)/2;
            end
            eta_ov = engine.eta_prop*engine.eta_eng;
            lhv = fuel.lhv;
            LovD = aero.LovD;
            m_maxTO = aircraft.weight.m_maxTO;

            m_toc = m_maxTO*(1 - (mission.cruise_speed)/(2*eta_ov*lhv))*exp((-g*h)*(1+(cosd(theta)^2)/(LovD*sind(theta)))/(eta_ov*lhv));%kg
%             disp(m_toc)
            obj.m_fuel_climb = m_maxTO - m_toc;%kg
            climb_range = h/tand(theta);
            obj.m_fuel_descent = 0.1*obj.m_fuel_climb;%kg
            descent_range = climb_range;
%             disp(obj.m_fuel_climb)
            cruise_range = mission.range*1000-climb_range-descent_range;
            obj.m_fuel_cruise = m_toc*(1-exp(-cruise_range*g/(lhv*eta_ov*LovD)));%kg
            
            obj.m_fuel_mission = (obj.m_fuel_cruise+obj.m_fuel_climb+obj.m_fuel_descent);%kg including a 5% reserve
            reserve_range = 45*60*mission.cruise_speed; %m
            obj.m_fuel_reserve = (m_toc- obj.m_fuel_mission)*(1-exp(-reserve_range*g/(lhv*eta_ov*LovD))) + 0.05*obj.m_fuel_mission;%kg
            
            obj.m_fuel = (obj.m_fuel_mission + obj.m_fuel_reserve);%kg
        end

        function obj = FuelBurn_Iteration(obj,aircraft)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            g = 9.81;
            theta = aircraft.mission.angle_TO;
            if aircraft.mission.range*1000 > 2*aircraft.mission.cruise_alt/tand(theta)
                h = aircraft.mission.cruise_alt;
            else
                h = aircraft.mission.range*1000*tand(theta)/2;
            end
            eta_ov = aircraft.engine.eta_prop*aircraft.engine.eta_eng;
            lhv = aircraft.fuel.lhv;
            LovD = aircraft.aero.LovD;

            m_toc = aircraft.weight.m_maxTO*(1 - (aircraft.mission.cruise_speed)/(2*eta_ov*lhv))*exp((-g*h)*(1+(cosd(theta)^2)/(LovD*sind(theta)))/(eta_ov*lhv));%kg
%             disp(m_toc)l
            obj.m_fuel_climb = aircraft.weight.m_maxTO - m_toc;%kg
%             disp(obj.m_fuel_climb)
            climb_range = h/tand(theta);
            obj.m_fuel_descent = 0.1*obj.m_fuel_climb;%kg
            descent_range = climb_range;

            cruise_range = aircraft.mission.range*1000-climb_range-descent_range;
            obj.m_fuel_cruise = m_toc*(1-exp(-cruise_range*g/(lhv*eta_ov*LovD)));%kg

            obj.m_fuel_mission = (obj.m_fuel_cruise+obj.m_fuel_climb+obj.m_fuel_descent);%kg including a 5% reserve
            reserve_range = 45*60*aircraft.mission.cruise_speed; %m
            obj.m_fuel_reserve = (m_toc- obj.m_fuel_mission)*(1-exp(-reserve_range*g/(lhv*eta_ov*LovD))) + 0.05* obj.m_fuel_mission;%kg

            
            obj.m_fuel = (obj.m_fuel_mission + obj.m_fuel_reserve);%kg
        end
    end
end