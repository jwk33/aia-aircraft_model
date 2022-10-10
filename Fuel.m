classdef Fuel
    %Fuel object
    
    % builds physical model for different fuel types
    properties (SetAccess = immutable)
        lhv {mustBePositive, mustBeFinite}
        density {mustBePositive, mustBeFinite}
        UseTankModel logical
    end
    
    methods
        function obj = Fuel(lhv, density, UseTankModel)
            % construct Fuel object
            obj.lhv = lhv;
            obj.density = density;
            obj.UseTankModel = UseTankModel;
        end
    end
end