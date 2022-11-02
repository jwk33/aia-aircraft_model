function skin_friction_coefficient = cf(l,U,nu)
    %Calculate Cf for a component - for turbulent flow. l = reference
    %length for Re
%     nu = 3.899*10^(-5); %11000 - is there a toolbox?
%     nu = 2.416e-5;
    skin_friction_coefficient = 0.027/(Re(U,l,nu)^(1/7));
end