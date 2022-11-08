clear all
%% load constants
load("Ker_Fuel.mat","Ker")
load("aircraftDataTable.mat","aircraftDataTable")
table = aircraftDataTable;
count_max = height(table);

for count =1:count_max
    pax = cell2mat(table.Passengers(count));
    eta_prop = cell2mat(table.PropEfficiency(count));
    eta_therm = cell2mat(table.ThermalEfficiency(count));
    LoD = cell2mat(table.LoD(count));
    OEW = cell2mat(table.OEW(count));
    range_array = cell2mat(table.Range(count));
    fuelBurn_array = cell2mat(table.FuelBurnKgm(count));
    TOW_array = cell2mat(table.TakeOffWeight(count));
    max_range = cell2mat(table.MaxRange(count));
    altitude = cell2mat(table.Altitude(count));
    theta_cl = cell2mat(table.ClimbAngle(count));

    eta_ov = eta_prop * eta_therm;
    
    % check that NaNs are placed at ranges beyond max range
    % find location of NaN
    [row,col] = find(isnan(TOW_array));
    i_NaN = col(1);
    assert(isequaln(TOW_array(i_NaN:end),fuelBurn_array(i_NaN:end)), "NaNs in arrays are not the same")
    assert(range_array(i_NaN) > max_range && range_array(i_NaN-1) < max_range, "NaNs placed incorrectly")

    % remove all NaNs
    fuelBurn_array = rmmissing(fuelBurn_array);
    TOW_array = rmmissing(TOW_array);
    range_array = range_array(1:length(TOW_array));

    % check takeoff weight
    m_payload = pax.*102;
    m_fuel = fuelBurn_array.*(1e3.*range_array);
    TOW_array_check = m_payload + OEW + m_fuel;
    TOW_err = (TOW_array_check - TOW_array)./TOW_array_check;
    TOW_err_mean = mean(TOW_err);

    % sanity check with breguet
    m_zf = m_payload + OEW;
    r_climb = altitude/tand(theta_cl)*2;
    m_fuel_check = m_zf.*(exp(((range_array.*1e3 - r_climb).*9.81)/(43.2e6*LoD*eta_ov))-1) + 0.02.*TOW_array;
    m_fuel_err = (m_fuel - m_fuel_check)./m_fuel;
    m_fuel_err_mean = mean(m_fuel_err);

end