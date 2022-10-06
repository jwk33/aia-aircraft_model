function M = sizeaircraft()
    % define aircraft components
    LH = Fuel(70.17, 1.20E+08);
    FF = Fuel(807.50, 4.32E+07);
    fuelTank1 = FuelTank(LH, "UseTankModel", 1);
    fuelTank2 = FuelTank(FF, "UseTankModel", 0);
    eng1 = Engine(LH);
    eng2 = Engine(FF, "engEff", 0.41);
    aircraft1 = Aircraft(eng1, fuelTank1, 3000, 85);
    aircraft2 = Aircraft(eng2, fuelTank2, 14000, 310);
    
    % carry out sizing
    M = aircraft2.sizing("ConvMarg", eps);
end