classdef FuelBurnModel < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties (SetAccess = public)
        m_fuel(1,1) double {mustBeNonnegative, mustBeFinite}
    end

    methods
        function obj = FuelBurnModel(fuel,mission,aero,engine)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            g = 9.81;
            theta = mission.angle_TO;
            if mission.range*1000 > 2*mission.cruise_alt/tand(theta)
                h = mission.cruise_alt;
            else
                h = mission.range*1000*1000*tand(theta)/2;
            end
            eta_ov = engine.prop_eff*engine.eng_eff;
            lhv = fuel.lhv;
            LovD = aero.LovD;
            if mission.range*0.02 - 19.79 > 30
                m_maxTO = mission.range*0.02 - 19.79;
            else
                m_maxTO = 30;
            end
            m_maxTO = 1000;

            m_toc = m_maxTO*1000*(1 - (mission.cruise_speed)/(2*eta_ov*lhv))*exp((-g*h)*(1+(cosd(theta)^2)/(LovD*sind(theta)))/(eta_ov*lhv));%kg
%             disp(m_toc)
            climb_fuel = m_maxTO*1000 - m_toc;%kg
            climb_range = h/tand(theta);
            descent_fuel = 0.1*climb_fuel;%kg
            descent_range = climb_range;
%             disp(climb_fuel)
            cruise_range = mission.range*1000-climb_range-descent_range;
            cruise_fuel = m_toc*(1-exp(-cruise_range*g/(lhv*eta_ov*LovD)));%kg

            obj.m_fuel = (cruise_fuel+climb_fuel+descent_fuel)/1000;%tonnes
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
            eta_ov = aircraft.engine.prop_eff*aircraft.engine.eng_eff;
            lhv = aircraft.fuel.lhv;
            LovD = aircraft.aero.LovD;

            m_toc = aircraft.weight.m_maxTO*1000*(1 - (aircraft.mission.cruise_speed)/(2*eta_ov*lhv))*exp((-g*h)*(1+(cosd(theta)^2)/(LovD*sind(theta)))/(eta_ov*lhv));%kg
%             disp(m_toc)
            climb_fuel = aircraft.weight.m_maxTO*1000 - m_toc;%kg
%             disp(climb_fuel)
            climb_range = h/tand(theta);
            descent_fuel = 0.1*climb_fuel;%kg
            descent_range = climb_range;

            cruise_range = aircraft.mission.range*1000-climb_range-descent_range;
            cruise_fuel = m_toc*(1-exp(-cruise_range*g/(lhv*eta_ov*LovD)));%kg

            obj.m_fuel = (cruise_fuel+climb_fuel+descent_fuel)/1000;%tonnes
        end
    end
end