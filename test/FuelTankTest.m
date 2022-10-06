% Test FuelTank
function tests = FuelTankTest
tests = functiontests(localfunctions);
end

function testUpdateInteriorLength(testCase)
% define aircraft components - test two planes against MVM
tol = testCase.TestData.tol;
LH = Fuel(70.17, 1.20E+08);
fuelTank = FuelTank(LH, "UseTankModel", 1);

wf = 0.2;
tow = 40;

% check interior length updates correctly
fuelTank.updateInteriorLength(wf,tow,5);
verifyLessThanOrEqual(testCase,abs(fuelTank.intLength-6.33),tol);
fuelTank.updateInteriorLength(wf,tow,7);
verifyLessThanOrEqual(testCase,abs(fuelTank.intLength-10.24),tol);
% NOTE: the above tests are dependent on the current values of fuelTank
% constants. Changing those will require a change in this test function.
end

function testWeightFrac(testCase)
% define aircraft components - test two planes against MVM
tol = testCase.TestData.tol;
LH = Fuel(70.17, 1.20E+08);
fuelTank = FuelTank(LH, "UseTankModel", 1);

wf = 0.2;

% check weight fraction returns correctly
% Cylinder case
fuelTank.intLength = 15.7;
wft = fuelTank.weightFrac(4.5,wf);
verifyLessThanOrEqual(testCase,abs(wft-0.07906),tol);
verifyEqual(testCase,fuelTank.fuelTankType,'Cylinder');
% Sphere case
fuelTank.intLength = 5.0;
wft = fuelTank.weightFrac(7.5,wf);
verifyLessThanOrEqual(testCase,abs(wft-0.07590),tol);
verifyEqual(testCase,fuelTank.fuelTankType,'Sphere');
% NOTE: the above tests are dependent on the current values of gravimetric
% functions. Changing those will require a change in this test function.
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