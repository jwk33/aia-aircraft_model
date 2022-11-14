clear all
close all
load("aircraftDataTable.mat")

for r = 1:height(aircraftDataTable)
    %% Import all working variables
    AC = aircraftDataTable{r,3}{1};
    PAX = aircraftDataTable{r,6}{1};
    MR = aircraftDataTable{r,7}{1};
    PE = aircraftDataTable{r,8}{1};
    TE = aircraftDataTable{r,9}{1};
    WS = aircraftDataTable{r,10}{1};
    L_D = aircraftDataTable{r,11}{1};
    OEW = aircraftDataTable{r,12}{1};
    Alt = aircraftDataTable{r,13}{1};
    theta = aircraftDataTable{r,14}{1};
    Vcr = aircraftDataTable{r,15}{1};
    Vcl = aircraftDataTable{r,16}{1};
    Vapp = aircraftDataTable{r,17}{1};
    Range = aircraftDataTable{r,18}{1};
    TOW = aircraftDataTable{r,19}{1};
    FB = aircraftDataTable{r,20}{1};
    F = aircraftDataTable{r,21}{1};
    DR = aircraftDataTable{r,22}{1};
    
    %% Define the limits for each type
    if AC == "Short Haul"
        Passengers_Upper = 140;%LF = 0.8
        Passengers_Lower = 123;%LF = 0.7

        Max_Range_Upper = 6e3;
        Max_Range_Lower = DR;%this is the design point

        PE_Upper = 0.85;
        PE_Lower = 0.75;

        TE_Upper = 0.6;
        TE_Lower = 0.4;

        WS_Upper = 40;
        WS_Lower = 20;

        L_D_Upper = 22;
        L_D_Lower = 15;

        OEW_Upper = 55e3;
        OEW_Lower = 35e3;

        Alt_Upper = 12000;
        ALt_Lower = 9000;

        theta_Upper = 6;
        theta_Lower = 3;
        
        Vcr_Upper = 300;
        Vcr_Lower = 150;

        Vcl_Upper = 300;
        Vcl_Lower = 150;

        Vapp_Upper = 300;
        Vapp_Lower = 150;

    elseif AC == "Medium Haul"
        Passengers_Upper = 240;%LF = 0.8
        Passengers_Lower = 210;%LF = 0.7

        Max_Range_Upper = 13e3;
        Max_Range_Lower = DR;%this is the design point

        PE_Upper = 0.85;
        PE_Lower = 0.75;

        TE_Upper = 0.6;
        TE_Lower = 0.4;

        WS_Upper = 60;
        WS_Lower = 30;

        L_D_Upper = 22;
        L_D_Lower = 15;

        OEW_Upper = 200e3;
        OEW_Lower = 100e3;

        Alt_Upper = 12000;
        ALt_Lower = 9000;

        theta_Upper = 6;
        theta_Lower = 3;
        
        Vcr_Upper = 300;
        Vcr_Lower = 150;

        Vcl_Upper = 300;
        Vcl_Lower = 150;

        Vapp_Upper = 300;
        Vapp_Lower = 150;
    elseif AC == "Long Haul"
        Passengers_Upper = 400;%LF = 0.8
        Passengers_Lower = 350;%LF = 0.7

        Max_Range_Upper = 20e3;
        Max_Range_Lower = DR;%this is the design point

        PE_Upper = 0.85;
        PE_Lower = 0.75;

        TE_Upper = 0.6;
        TE_Lower = 0.4;

        WS_Upper = 80;
        WS_Lower = 50;

        L_D_Upper = 22;
        L_D_Lower = 15;

        OEW_Upper = 350e3;
        OEW_Lower = 200e3;

        Alt_Upper = 12000;
        ALt_Lower = 9000;

        theta_Upper = 6;
        theta_Lower = 3;
        
        Vcr_Upper = 300;
        Vcr_Lower = 150;

        Vcl_Upper = 300;
        Vcl_Lower = 150;

        Vapp_Upper = 300;
        Vapp_Lower = 150;
    else
        disp(['Aircraft not one of the three for row ',num2str(r)])
    end

    %% Check that variables within limits
    if PAX < Passengers_Lower || PAX > Passengers_Upper
        disp(['PAX Error for row ',num2str(r)])
    end

    if MR < Max_Range_Lower || MR > Max_Range_Upper
        disp(['Max Range Error for row ',num2str(r)])
    end

    if PE < PE_Lower || PE > PE_Upper
        disp(['Prop Eff Error for row ',num2str(r)])
    end

    if TE < TE_Lower || TE > TE_Upper
        disp(['THerm Eff Error for row ',num2str(r)])
    end

    if WS < WS_Lower || WS > WS_Upper
        disp(['Wingspan Error for row ',num2str(r)])
    end

    if L_D < L_D_Lower || L_D > L_D_Upper
        disp(['L/D Error for row ',num2str(r)])
    end

    if OEW < OEW_Lower || OEW > OEW_Upper
        disp(['OEW Error for row ',num2str(r)])
    end

    if Alt < ALt_Lower || Alt > Alt_Upper
        disp(['Altitude Error for row ',num2str(r)])
    end

    if theta < theta_Lower || theta > theta_Upper
        disp(['Theta Error for row ',num2str(r)])
    end

    if Vcr < Vcr_Lower || Vcr > Vcr_Upper
        disp(['Cruise Speed Error for row ',num2str(r)])
    end

    if Vcl < Vcl_Lower || Vcl > Vcl_Upper
        disp(['Climb Speed Error for row ',num2str(r)])
    end

    if Vapp < Vapp_Lower || Vapp > Vapp_Upper
        disp(['Approach Speed Error for row ',num2str(r)])
    end


    %% Check that all NaN values are the same index
    I = find(isnan(TOW), 1, 'first');
    J = find(isnan(FB), 1, 'first');
    K = find(isnan(F), 1, 'first');
    if I~=J || I~=K || J~=K
        disp(['NaN index Error for row ',num2str(r)])
    end
    
    %% Check that MTOW is appropriate
    if TOW(I) < OEW_Lower/0.5 || TOW(I) > OEW_Upper/0.5
        disp(['TOW Error for row ',num2str(r)])
    end
    %% Check that Fuel Burns are appropriate
%     if mean(FB) > 0.1 || mean(FB) < 0.001
%         disp(['Fuel Burn Error for row ',num2str(r)])
%     end
%     if mean(FB) > 0.1 || mean(FB) < 0.001
%         disp(['Fuel Burn Error for row ',num2str(r)])
%     end
end
