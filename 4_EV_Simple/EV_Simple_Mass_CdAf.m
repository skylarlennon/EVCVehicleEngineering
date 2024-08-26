%% EV Simple Parameters
% Run this file to fill the workspace with the vehicle parameters, load the
% drive cycle, run the EV_Simple Simulink simulation, and plot the results
clc;clear;close all

%% Drive cycle input data
% Load the time-speed data from the spreadsheet
driveCycleData = readmatrix('time_speed_elevation_distance_theta_data.xlsx');

% Extract time and speed columns
time = driveCycleData(:, 1);
speed = driveCycleData(:, 2);
elevation = driveCycleData(:, 3);
distance = driveCycleData(:, 4);
timeSpeedData = timeseries(speed,time);
time_step = time(2);
dataSize = length(speed);

%% Model Parameters
%Simulation Params
StopTime = time(end);

%Environment
airDensity = 1.293;
aeroDragCoeff = 0.17;
frontArea = 0.951; %m^2
cdaf = airDensity*aeroDragCoeff;
gravity = 9.81;
inclinationAngle = 0; %Eventually change this dynamically based on the position [TOOD]

%PID Controller
P_Driver = 250;
I_Driver = 1;
D_Driver = 0;

%Vehicle
MaxBrakeForce = 1000; %N
rollingResistCoeff = 0.01;
massVeh = 173; %kg

%Motor
MotorMaxTorque = 15;
MotorMaxPower = 2e3;
MotorMaxSpeed = 2000/60*2*pi; %radps
MotorKc = 0.0452;
MotorKw = 5.0664e-5;
MotorKi = 0.0167;
MotorC = 628.2974;

%Battery
AccessoryLoad = 100;
internalResistance = 0.05;
openCircuitVoltage = 52;
energyCapacity = 2;
initialSOC = 0.95;

%Transmission
Spinloss = 6;
% GearRatio = 3.55; %driven/driving
GearRatio = 5;
wheelRadius = 0.34;

%% Simulate
%Percent bounds
boundPercent = 0.2;
numPoints = 10;
initialCdAf = aeroDragCoeff*frontArea;
lowerBoundCdAf = initialCdAf*(1-boundPercent);
upperBoundCdAf = initialCdAf*(1+boundPercent);
lowerBoundMass = massVeh*(1-boundPercent);
upperBoundMass = massVeh*(1+boundPercent);
CdAfRange = linspace(lowerBoundCdAf,upperBoundCdAf,numPoints);
massRange = linspace(lowerBoundMass,upperBoundMass,numPoints);
[MASS,CDAF] = meshgrid(massRange,CdAfRange);
TOT_ENERGY = ones(numPoints);

for m=1:length(massRange)
    massVeh = massRange(m);
    for n=1:length(CdAfRange)
        cdaf = CdAfRange(n);
        sim("EV_Simple.slx")
        TOT_ENERGY(m,n) = results(end,6);
    end
end

% try regresion & see how the map changes



%% Plot Results
figure(1)
contour(MASS,CDAF,TOT_ENERGY)
xlabel('Mass (kg)')
ylabel('Cd*Af')
zlabel('Total Energy Consumed (J)')
title('Total Energy = f(Mass,CdAf)')
colorbar('eastoutside');
c2 = colorbar;
c2.Label.String = 'Total Energy (J)'; % Label the colorbar
c2.FontSize = 12; % Set the font size for the colorbar label


