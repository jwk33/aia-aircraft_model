clear all
close all
clc
load("aircraftDataTable_Whole.mat", "aircraftDataTableWhole")
aircraftDataTable = aircraftDataTableWhole;
Dodgy_Rows = [];
for r = 1:height(aircraftDataTable)
    %% Import all working variables
    year = aircraftDataTable{r,1}{1};
    optimism = aircraftDataTable{r,2}{1};
    AC = aircraftDataTable{r,3}{1};
    Fuel = aircraftDataTable{r,4}{1};
    LF = aircraftDataTable{r,5}{1};
    PAX = aircraftDataTable{r,6}{1};
    MR = aircraftDataTable{r,7}{1};
    PE = aircraftDataTable{r,8}{1};
    TE = aircraftDataTable{r,9}{1};
    WS = aircraftDataTable{r,10}{1};
    L_D = aircraftDataTable{r,11}{1};
    OEW = aircraftDataTable{r,12}{1};
    ZFW = aircraftDataTable{r,13}{1};
    MTOW = aircraftDataTable{r,14}{1};
    Alt = aircraftDataTable{r,15}{1};
    theta = aircraftDataTable{r,16}{1};
    Vcr = aircraftDataTable{r,17}{1};
    Vcl = aircraftDataTable{r,18}{1};
    Vapp = aircraftDataTable{r,19}{1};
    Range = aircraftDataTable{r,20}{1};
    TOW = aircraftDataTable{r,21}{1};
    FB = aircraftDataTable{r,22}{1};
    F = aircraftDataTable{r,23}{1};
    DR = aircraftDataTable{r,24}{1};
    
    Error = 0;

    %% Define the limits for each type
    if AC == "Short Haul"
        Passengers_Upper = 180;%LF = 0.8
        Passengers_Lower = 123;%LF = 0.7

        Max_Range_Upper = 6e3;
        Max_Range_Lower = DR;%this is the design point

        PE_Upper = 0.85;
        PE_Lower = 0.7;

        TE_Upper = 0.6;
        TE_Lower = 0.4;

        WS_Upper = 40;
        WS_Lower = 20;

        L_D_Upper = 22;
        L_D_Lower = 15;

        OEW_Upper = 55e3;
        OEW_Lower = 35e3;

        MTOW_Upper = 88e3;
        MTOW_Lower = 72e3;

        F_Upper = 12*16.5e3;%kWh
        F_Lower = 12*13.5e3;

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
        Passengers_Upper = 300;%LF = 0.8
        Passengers_Lower = 210;%LF = 0.7

        Max_Range_Upper = 13e3;
        Max_Range_Lower = DR;%this is the design point

        PE_Upper = 0.85;
        PE_Lower = 0.7;

        TE_Upper = 0.6;
        TE_Lower = 0.4;

        WS_Upper = 60;
        WS_Lower = 30;

        L_D_Upper = 22;
        L_D_Lower = 15;

        OEW_Upper = 200e3;
        OEW_Lower = 100e3;

        MTOW_Upper = 275e3;
        MTOW_Lower = 225e3;

        F_Upper = 12*77e3;%kWh
        F_Lower = 12*54e3;

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
        Passengers_Upper = 500;%LF = 0.8
        Passengers_Lower = 350;%LF = 0.7

        Max_Range_Upper = 20e3;
        Max_Range_Lower = DR;%this is the design point

        PE_Upper = 0.85;
        PE_Lower = 0.7;

        TE_Upper = 0.6;
        TE_Lower = 0.4;

        WS_Upper = 80;
        WS_Lower = 50;

        L_D_Upper = 22;
        L_D_Lower = 15;

        OEW_Upper = 350e3;
        OEW_Lower = 200e3;

        MTOW_Upper = 633e3;
        MTOW_Lower = 517e3;

        F_Upper = 12*228e3;%kWh
        F_Lower = 12*186e3;

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
        Error = Error + 1;
    end

    %% Check that variables within limits
    if PAX < Passengers_Lower || PAX > Passengers_Upper
        disp(['PAX Error: ',num2str(PAX)])
        Error = Error + 1;
    end

    if MR < Max_Range_Lower || MR > Max_Range_Upper
        disp(['Max Range Error: ',num2str(MR)])
        Error = Error + 1;
    end

    if PE < PE_Lower || PE > PE_Upper
        disp(['Prop Eff Error: ',num2str(PE)])
        Error = Error + 1;
    end

    if TE < TE_Lower || TE > TE_Upper
        disp(['Therm Eff Error: ',num2str(TE)])
        Error = Error + 1;
    end

    if WS < WS_Lower || WS > WS_Upper
        disp(['Wingspan Error: ',num2str(WS)])
        Error = Error + 1;
    end

    if L_D < L_D_Lower || L_D > L_D_Upper
        disp(['L/D Error: ',num2str(L_D)])
        Error = Error + 1;
    end

%     if OEW < OEW_Lower || OEW > OEW_Upper
%         disp(['OEW Error: ',num2str(round(OEW/1000,0)),'t'])
%         Error = Error + 1;
%     end
% 
%     if MTOW < MTOW_Lower || MTOW > MTOW_Upper
%         disp(['MTOW Error: ',num2str(round(MTOW/1000,0)),'t'])
%         Error = Error + 1;
%     end

    if Alt < ALt_Lower || Alt > Alt_Upper
        disp(['Altitude Error: ',num2str(Alt)])
        Error = Error + 1;
    end

    if theta < theta_Lower || theta > theta_Upper
        disp(['Theta Error: ',num2str(theta)])
        Error = Error + 1;
    end

    if Vcr < Vcr_Lower || Vcr > Vcr_Upper
        disp(['Cruise Speed Error: ',num2str(Vcr)])
        Error = Error + 1;
    end

    if Vcl < Vcl_Lower || Vcl > Vcl_Upper
        disp(['Climb Speed Error: ',num2str(Vcl)])
        Error = Error + 1;
    end

    if Vapp < Vapp_Lower || Vapp > Vapp_Upper
        disp(['Approach Speed Error: ',num2str(Vapp)])
        Error = Error + 1;
    end


    %% Check that all NaN values are the same index
    I = find(isnan(TOW), 1, 'first');
    J = find(isnan(FB), 1, 'first');
    K = find(isnan(F), 1, 'first');
    if I~=J || I~=K || J~=K
        disp(['NaN index Error for row ',num2str(r)])
        Error = Error + 1;
    end

    %% Fuel Checks
    if Fuel == "Fossil Jet Fuel"
        delta_h = 43.2e6;
    else
        delta_h = 120e6;
    end

    Fuel_kWh = F(I-1)*PAX;
    Fuel_Burn_kWh = FB(I-1)*Range(I-1)*1e3*delta_h/(3.6e6);

    if Fuel_kWh < 0.99*Fuel_Burn_kWh || Fuel_kWh > 1.01*Fuel_Burn_kWh
        disp(['Fuel Match Error: ',num2str(round(Fuel_Burn_kWh/Fuel_kWh,2))])
        Error = Error + 1;
    end
    
    if AC == "Short Haul"
        Breguet_Fuel_Burn = ( TOW(I-1)*9.81*Alt/delta_h + ...
            ZFW*(exp((Range(I-1)*1000*9.81)/(TE*PE*L_D*delta_h)) - 1))*1.15; %15% reserve fuel + climb
        Breguet_Fuel_Energy = Breguet_Fuel_Burn*delta_h/(3.6e6);
    else
        Breguet_Fuel_Burn = ( TOW(I-1)*9.81*Alt/delta_h + ...
        ZFW*(exp((Range(I-1)*1000*9.81)/(TE*PE*L_D*delta_h)) - 1))*1.1; %10% reserve fuel + climb
        Breguet_Fuel_Energy = Breguet_Fuel_Burn*delta_h/(3.6e6);
    end

    if Fuel_kWh < 0.9*Breguet_Fuel_Energy || Fuel_kWh > 1.1*Breguet_Fuel_Energy
        warning(['Breguet Error: ',num2str(round(Fuel_kWh,0)),' vs ',num2str(round(Breguet_Fuel_Energy,0))])
        disp(Range(I-1))
        Error = Error + 1;
    end

    %% Functional Checks that numbers match
    if LF == 1
        if TOW(I-1) < 0.99*MTOW || TOW(I-1) > 1.01*MTOW
            disp(['TOW Error: ',num2str(round(TOW(I-1)/1000,0)),' vs ',num2str(round(MTOW/1000,0)),'t'])
            Error = Error + 1;
        end
    end

    Calced_ZFW = TOW(I-1)-Fuel_kWh*3.6e6/delta_h;
    if ZFW < 0.99* Calced_ZFW || ZFW > 1.01*Calced_ZFW
        disp(['ZFW Error: ',num2str(round(ZFW/1000,0)),' vs ',num2str(round(Calced_ZFW/1000,0)),'t'])
            Error = Error + 1;
    end

    if MR < Range(I-1) - 100 || MR > Range(I-1) + 100
        disp(['Max Range Error: ',num2str(round(MR,1)),' vs ',num2str(round(Range(I-1),0)),'km'])
            Error = Error + 1;
    end

    if Error > 0
        disp([num2str(year),optimism,AC,Fuel,num2str(LF)])
        disp('---------------------------------------------------')
    end
end
disp("Check complete")
