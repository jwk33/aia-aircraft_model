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

            m_toc = (m_maxTO - (m_maxTO*mission.cruise_speed^2)/(2*eta_ov*lhv))*exp(-(g*h)*(1+1/(LovD*tand(theta)))/(eta_ov*lhv));
            climb_fuel = m_maxTO - m_toc;%tonnes
            climb_range = h/tand(theta);
            descent_fuel = 0.1*climb_fuel;%tonnes
            descent_range = climb_range;

            cruise_range = mission.range*1000-climb_range-descent_range;
            cruise_fuel = m_toc*(1-exp(-cruise_range*g/(lhv*eta_ov*LovD)));

            obj.m_fuel = cruise_fuel+climb_fuel+descent_fuel;%tonnes
        end

        function obj = FuelBurn_Iteration(obj,a)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            g = 9.81;
            theta = a.mission.angle_TO;
            if a.mission.range*1000 > 2*a.mission.cruise_alt/tand(theta)
                h = a.mission.cruise_alt;
            else
                h = a.mission.range*1000*tand(theta)/2;
            end
            eta_ov = a.engine.prop_eff*a.engine.eng_eff;
            lhv = a.fuel.lhv;
            LovD = a.aero.LovD;

            m_toc = (a.weight.m_maxTO - (a.weight.m_maxTO*a.mission.cruise_speed^2)/(2*eta_ov*lhv))*exp(-(g*h)*(1+1/(LovD*tand(theta)))/(eta_ov*lhv));
            climb_fuel = a.weight.m_maxTO - m_toc;%tonnes
            climb_range = h/tand(theta);
            descent_fuel = 0.1*climb_fuel;%tonnes
            descent_range = climb_range;

            cruise_range = a.mission.range*1000-climb_range-descent_range;
            cruise_fuel = m_toc*(1-exp(-cruise_range*g/(lhv*eta_ov*LovD)));

            obj.m_fuel = cruise_fuel+climb_fuel+descent_fuel;%tonnes
        end
    end
end