classdef Engine
    %Engine object
    
    % define engine properties
    properties (SetAccess = immutable)
        fuel Fuel
    end
    properties (Hidden, SetAccess = immutable)
        % efficiencies currently set as constant - update in future model
        propEff(1,1) double
        engEff(1,1) double
    end
    methods
        function obj = Engine(fuel, opt)
            % construct engine object
            arguments
                fuel Fuel;
                opt.propEff(1,1) double {mustBeInRange(opt.propEff, 0, 1)} = 0.775;
                opt.engEff(1,1) double {mustBeInRange(opt.engEff, 0, 1)} = 0.420;
            end
            obj.fuel = fuel;
            obj.propEff = opt.propEff;
            obj.engEff = opt.engEff;
        end
        function e = get_etaProp(obj)
            % obtain propulsive efficiency
            e = obj.propEff;
        end
        function e = get_etaEng(obj)
            % obtain engine efficiency
            e = obj.engEff;
        end
    end
end