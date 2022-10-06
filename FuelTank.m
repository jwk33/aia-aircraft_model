classdef FuelTank < handle
    %FuelTank object
    
    % set up fuel tank properties
    properties
        intLength(1,1) double {mustBeNonnegative, mustBeFinite} % interior
        % diameter if sphere
        fuelTankType (1,:) char {mustBeMember(fuelTankType,{'Cylinder', 'Sphere'})} = 'Cylinder';
    end
    
    properties (SetAccess = immutable)
        useTankModel logical % Use tank model in weight determination - relevant
        % for new tank models (such as liquid hydrogen)
        fuel Fuel
    end
    
    properties (Constant)
        fusThickness = 120.0;
        excThickness = 450.0;
        intExtFactor = 0.98;
    end
    
    methods
        function obj = FuelTank(fuel, bool)
            arguments
                fuel;
                bool.UseTankModel logical = 0;
            end
            obj.fuel = fuel;
            obj.useTankModel = bool.UseTankModel;
            
        end
        function obj = updateInteriorLength(obj, wf, tow, dt)
            arguments
                obj
                wf(1,1) double {mustBeInRange(wf,0,1)} % fuel fraction
                tow(1,1) double {mustBePositive, mustBeFinite} % take-off weight
                dt(1,1) double {mustBePositive, mustBeFinite} % tube diameter
            end
            % Update interior length of fuel tank, given aircraft param
            obj.intLength = obj.interiorLength(wf, tow, dt);
        end
        function wfr = weightFrac(obj, dt, wf)
            % obtain weight fraction of fuel tank
            arguments
                obj
                dt(1,1) double {mustBePositive, mustBeFinite}% Tube diameter (external)
                wf(1,1) double {mustBeInRange(wf,0,1)} % Fuel weight fraction
            end
            wfr = obj.fuelTankMass(dt, wf);
            
            if isnan(wfr)
                wfr = 0;
            end
        end
    end
    methods (Access = private)
        function df = interiorLength(obj, wf, tow, dt)
            % Find interior length of fuel, given aircraft parameters
            arguments
                obj;
                wf(1,1) double {mustBeInRange(wf,0,1)}; % Fuel weight/ MTOW
                tow(1,1) double {mustBePositive, mustBeFinite}; % take-off weight
                dt(1,1) double {mustBePositive, mustBeFinite}; % diameter of fuselage
            end
            rho = obj.fuel.density;
            val1 = (wf*tow*1000)/(2*rho);
            val2 = pi/6*((dt - 2*(obj.fusThickness + obj.excThickness)/1000 ...
                )*obj.intExtFactor)^3;
            if val1 > val2
                df = (val1 - val2)*4/(pi*((dt - 2*(obj.fusThickness ...
                    + obj.excThickness)/1000)*obj.intExtFactor)^2) ...
                    + (dt - 2*(obj.fusThickness ...
                    + obj.excThickness)/1000)*obj.intExtFactor;
            else
                df = (val1 * 6*pi)^(1/3);
            end
        end
        function fm = fuelTankMass(obj, dt, wf)
            % Obtain estimate of fuelTankMass
            arguments
                obj
                dt(1,1) double {mustBePositive, mustBeFinite} % Fuselage diameter
                wf(1,1) double {mustBeInRange(wf,0,1)}% Fuel weight/ MTOW weight
            end
            if obj.useTankModel
                if obj.intLength > dt
                    % cylinder
                    g = obj.gec(dt, obj.intLength);
                    fm = (1/g - 1)*wf;
                    obj.fuelTankType = 'Cylinder';
                else
                    % sphere
                    g = obj.ges(obj.intLength);
                    fm = (1/g - 1)*wf;
                    obj.fuelTankType = 'Sphere';
                end
            else
                fm = 0;
            end
        end
        function g = gec(obj, dt, tL)
            arguments
                obj %#ok<INUSA>
                dt(1,1) double {mustBePositive, mustBeFinite} % fuselage tube diameter
                tL(1,1) double {mustBePositive, mustBeFinite} % fuel tank interior length
            end
            fDiamArray = [3	3.5	4  4.5  5.5	5.9	6.3	6.8	7.3	7.8];
            tLenArray = 2.5:0.5:16;
            gecArray = [0.4782, 0.5189, 0.6331, NaN, NaN, NaN, NaN, NaN, NaN, NaN;
                0.4998, 0.5468, 0.5774, 0.6698, NaN, NaN, NaN, NaN, NaN, NaN;
                0.5145, 0.5652, 0.5999, 0.6238, NaN, NaN, NaN, NaN, NaN, NaN;
                0.5252, 0.5783, 0.6155, 0.6422, 0.7249, NaN, NaN, NaN, NaN, NaN;
                0.5332, 0.5880, 0.6270, 0.6555, 0.6923, 0.7421, NaN, NaN, NaN, NaN;
                0.5395, 0.5955, 0.6357, 0.6655, 0.7051, 0.7158, 0.7573, NaN, NaN, NaN;
                0.5445, 0.6015, 0.6426, 0.6733, 0.7148, 0.7265, 0.7360, 0.7739, NaN, NaN;
                0.5487, 0.6064, 0.6482, 0.6795, 0.7225, 0.7348, 0.7450, 0.7554, 0.7837, NaN;
                0.5521, 0.6105, 0.6528, 0.6847, 0.7288, 0.7415, 0.7522, 0.7632, 0.7678, 0.7837;
                0.5551, 0.6139, 0.6567, 0.6890, 0.7339, 0.7470, 0.7580, 0.7696, 0.7747, 0.7705;
                0.5576, 0.6168, 0.6600, 0.6926, 0.7382, 0.7515, 0.7629, 0.7748, 0.7804, 0.7768;
                0.5598, 0.6194, 0.6628, 0.6957, 0.7419, 0.7554, 0.7670, 0.7792, 0.7852, 0.7821;
                0.5617, 0.6216, 0.6653, 0.6984, 0.7450, 0.7588, 0.7705, 0.7830, 0.7893, 0.7865;
                0.5634, 0.6235, 0.6674, 0.7008, 0.7478, 0.7617, 0.7736, 0.7862, 0.7927, 0.7903;
                0.5649, 0.6252, 0.6693, 0.7029, 0.7502, 0.7642, 0.7762, 0.7890, 0.7957, 0.7936;
                0.5663, 0.6268, 0.6711, 0.7047, 0.7523, 0.7664, 0.7786, 0.7915, 0.7984, 0.7965;
                0.5675, 0.6282, 0.6726, 0.7064, 0.7542, 0.7684, 0.7806, 0.7937, 0.8007, 0.7990;
                0.5686, 0.6294, 0.6740, 0.7079, 0.7559, 0.7702, 0.7825, 0.7957, 0.8028, 0.8013;
                0.5696, 0.6306, 0.6752, 0.7092, 0.7574, 0.7718, 0.7842, 0.7974, 0.8047, 0.8033;
                0.5705, 0.6316, 0.6764, 0.7105, 0.7588, 0.7733, 0.7857, 0.7990, 0.8063, 0.8051;
                0.5713, 0.6326, 0.6774, 0.7116, 0.7601, 0.7746, 0.7871, 0.8004, 0.8079, 0.8068;
                0.5721, 0.6334, 0.6784, 0.7126, 0.7613, 0.7758, 0.7883, 0.8018, 0.8093, 0.8082;
                0.5728, 0.6342, 0.6793, 0.7136, 0.7623, 0.7769, 0.7895, 0.8029, 0.8105, 0.8096;
                0.5735, 0.6350, 0.6801, 0.7145, 0.7633, 0.7779, 0.7905, 0.8041, 0.8117, 0.8109;
                0.5741, 0.6357, 0.6808, 0.7153, 0.7642, 0.7789, 0.7915, 0.8051, 0.8127, 0.8120;
                0.5747, 0.6363, 0.6815, 0.7160, 0.7651, 0.7797, 0.7924, 0.8060, 0.8137, 0.8131;
                0.5752, 0.6369, 0.6822, 0.7167, 0.7658, 0.7805, 0.7932, 0.8069, 0.8146, 0.8140;
                0.5757, 0.6375, 0.6828, 0.7174, 0.7666, 0.7813, 0.7940, 0.8077, 0.8155, 0.8149];
            i_list = find(tLenArray <= tL);
            i = i_list(end);
            j = fDiamArray == dt;
            g = gecArray(i,j);
        end
        function g = ges(obj, tD)
            arguments
                obj %#ok<INUSA>
                tD(1,1) double {mustBePositive, mustBeFinite} % fuel tank interior diameter
            end
            tIntD = [1 1.5 2 2.5 1.82 2.31 2.80 3.29 4.27 4.66 5.06 5.55 6.04 6.53];
            gesArray = [0.3780 0.4789 0.5513 0.6060 0.4782 0.5189 0.6331 0.6698 0.7249 0.7421 0.7573 0.7739 0.7837 0.7837];
            i_list = find(tIntD <= tD);
            i = i_list(end);
            g = gesArray(i);
        end
    end
end