classdef Technology
    %

    properties %
        tech_factor struct
        key(1,:) char
        LoD_factor(1,1) double
        eta_factor(1,1) double
        mzf_factor(1,1) double
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
            obj.eta_factor = obj.tech_factor.eta(obj.key);
            obj.mzf_factor = obj.tech_factor.MZF(obj.key);
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

            eta_base = engine.eta_eng;
            eta_base_inv = 1/eta_base;
            eta_new_inv = eta_base_inv * obj.eta_factor;
            eta_new = 1/eta_new_inv;
            engine.eta_eng = eta_new;
            engine.eta_ov = engine.eta_eng * engine.eta_prop;
            
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