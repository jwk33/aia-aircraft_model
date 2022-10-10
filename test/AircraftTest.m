% Test Aircraft
function tests = AircraftTest
tests = functiontests(localfunctions);
end

function testSizing(testCase)
% define aircraft components - test two planes against MVM
LH = Fuel(70.17, 1.20E+08);
FF = Fuel(807.50, 4.32E+07);
fuelTank1 = FuelTank(LH, "UseTankModel", 1);
fuelTank2 = FuelTank(FF);
eng1 = Engine(LH);
eng2 = Engine(FF);
aircraft1 = Aircraft(eng1, fuelTank1, 3000, 85);
aircraft2 = Aircraft(eng2, fuelTank2, 14000, 310);

% size both aircraft
aircraft1.sizing("ConvMarg", eps);
aircraft2.sizing("ConvMarg", eps);

% verify parameters - default values
% tol = testCase.TestData.tol;
% verifyLessThanOrEqual(testCase,abs(aircraft1.TOW-38.054),tol);
% verifyLessThanOrEqual(testCase,abs(aircraft2.TOW-344.867),0.2);
end

function setupOnce(testCase)
% Setup code - find above directory
testCase.TestData.origPath = pwd;
testCase.TestData.tol = 0.01;
mydir  = pwd;
idcs   = strfind(mydir,'\');
newdir = mydir(1:idcs(end)-1);
cd(newdir)
end

function teardownOnce(testCase)
cd(testCase.TestData.origPath);
end