classdef Technology
    %

    properties %
        tech_factor struct
        key(1,:) char
        LoD_factor(1,1) double
        
        mzf_factor(1,1) double
        eta_factor_ov(1,1) double {mustBeInRange(eta_factor_ov, 0,1)}
        eta_factor_th(1,1) double {mustBeInRange(eta_factor_th, 0,1)}
        eta_factor_prop(1,1) double {mustBeInRange(eta_factor_prop, 0,1)}
    end


    methods
        function obj = Technology(aircraft)
            arguments
                aircraft Aircraft
            end
            load("Tech_Factor.mat","tech_factor");
            obj.tech_factor = tech_factor;
            obj = obj.update(aircraft);
        end

        function obj = update(obj,aircraft)
            obj.key = string(aircraft.year) + "-" + aircraft.optimism;
            obj.LoD_factor = obj.tech_factor.LoD(obj.key);
            obj.mzf_factor = obj.tech_factor.MZF(obj.key);
            obj.eta_factor_ov = obj.tech_factor.eta_ov(obj.key);
            obj.eta_factor_th = obj.tech_factor.eta_th(obj.key);
            obj.eta_factor_prop = obj.tech_factor.eta_prop(obj.key);
        end

        function aero = improve_LoD(obj,aero)
            arguments
                obj
                aero Aero
            end

            LoD_base = aero.LovD;
            LoD_base_inv = 1/LoD_base;
            LoD_new_inv = LoD_base_inv * obj.LoD_factor;
            LoD_new = 1/LoD_new_inv;
            aero.LovD = LoD_new;
            
        end

        function engine = improve_eta(obj,engine)
            arguments
                obj
                engine Engine
            end
            
            % Improve engine thermal efficiency
            eta_th_base = engine.eta_eng_base;
            eta_th_base_inv = 1/eta_th_base;
            eta_th_new_inv = eta_th_base_inv * obj.eta_factor_th;
            eta_th_new = 1/eta_th_new_inv;
            engine.eta_eng = eta_th_new;


            % Improve engine propulsive efficiency
            eta_prop_base = engine.eta_prop_base;
            eta_prop_base_inv = 1/eta_prop_base;
            eta_prop_new_inv = eta_prop_base_inv * obj.eta_factor_prop;
            eta_prop_new = 1/eta_prop_new_inv;
            engine.eta_prop = eta_prop_new;
            
            % Update engine overall efficiency
            engine.eta_ov = engine.eta_eng * engine.eta_prop;

            eta_ov_old = eta_th_base * eta_prop_base;

            assert(abs( (1/engine.eta_ov)/(1/eta_ov_old) - obj.eta_factor_ov) < 1e-5, "Tech Improvements applied incorrectly. \n Expected factor %.3f \n Calculated factor %.3f", obj.eta_factor_ov, (1/engine.eta_ov)/(1/eta_ov_old))
            
        end

        function weight = improve_oew(obj,weight, aircraft,mission)
            arguments
                obj
                weight Weight
                aircraft Aircraft
                mission Mission
            end
            
            mzf_base = weight.m_OEW + weight.m_payload;
            mzf_delta = mzf_base*(obj.mzf_factor-1);
            weight.m_mzf_delta = mzf_delta;
            
            weight = weight.finalise(aircraft,mission);
        
        end

    end
end