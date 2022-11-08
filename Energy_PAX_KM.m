close all
clear all

time=[2021 2035 2050];         % time frames into consideration
grad=[0.75 1 1.25];            % gradients of the 3 buckets: conventional, evolutionary and revolutionary respectively
split=[0.6 0.2 0.2];           % efficiency improvement from engine, aero and weight respectively

for i=1:3
A(i,:)=(1-grad/100).^(time(i)-time(1));
end



load('aircraftDataTable.mat')
years = [2021,2035,2050];
Optimisms = ["more","basic","less"];
Aircrafts = ["Short Haul","Medium Haul","Long Haul"];
Design_Ranges = [4000,9000,14000];
load_factor = 0.8;

for f=1:3
    Aircraft = Aircrafts(f);
    for i = 1:3
        optimism = Optimisms(i);
    %     idx = strcmpi([aircraftDataTable{:,2}],optimism);
        for j = 1:3
            year = years(j);
    %         idx = strcmpi([aircraftDataTable{:,2}],optimism) &...
    %             strcmpi([aircraftDataTable{:,3}{1}],Aircraft{1}) &...
    %             [aircraftDataTable{:,1}{1}]==year{1} &...
    %             [aircraftDataTable{:,5}{1}]==load_factor{1};
            for k = 1:height(aircraftDataTable)
                if aircraftDataTable{k,1}{1} == year &&...
                aircraftDataTable{k,2}{1} == optimism &&...
                aircraftDataTable{k,3}{1} == Aircraft &&...
                aircraftDataTable{k,5}{1} == load_factor
    
                    Range = aircraftDataTable{k,22}{1};%km
                    Ranges(f,i,j) = Range;
                    index = find(aircraftDataTable{k,18}{1}==Range);
                    Fuel_Burn = aircraftDataTable{k,21}{1}(index);% fuel burn kwh per passenger =
                    ERPK(j) = Fuel_Burn*3.6/(Range);
                    x(j) = year;
                end
            end
        end
        ERPK_reference = ERPK(1);
        ERPK_display = ERPK/ERPK_reference;
        figure(f)
        hold on
        plot(x,ERPK_display,'DisplayName',optimism)
    end
    figure(f)
    plot(x, A(:,1),'DisplayName','Less Ideal')
    plot(x, A(:,2),'DisplayName','Basic Ideal')
    plot(x, A(:,3),'DisplayName','More Ideal')
    xlabel('Year')
    ylabel('Energy(MJ/Passenger-km)')
    title(Aircraft)
    legend('Location','Best')
end
