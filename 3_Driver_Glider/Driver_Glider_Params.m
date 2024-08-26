%% Driver Glider Params
%TODO: Describe the model, non, torque limited, etc. 
%TODO: DESCRIBE HOW THIS IS FOR CEDAR

% Run this file to fill the workspace with the vehicle parameters, load the
% drive cycle, run the EV_Simple Simulink simulation, and plot the results
clc;clear;close all
%% Model Parameters

%Inport Drive Cycle Data
driveCycleData = readmatrix('time_speed_elevation_distance_theta_data.xlsx');

% Extract time and speed columns
time = driveCycleData(:, 1);
speed = driveCycleData(:, 2);
elevation = driveCycleData(:,3);
distance = driveCycleData(:,4);
theta = driveCycleData(:,5);

% Create time series data for time-speed, and time-theta
timeSpeedData = timeseries(speed,time);
timeThetaData = timeseries(theta,time);

%Time Step
time_step = time(2);

%Simulation Params
% StopTime = time(end);
StopTime = 350;

%Environment
airDensity = 1.293;
gravity = 9.81;

%Vehicle
rollingResistCoeff = 0.01;
massVeh = 173; %kg
aeroDragCoeff = 0.17;
frontArea = 0.951; %m^2
Ndriving = 6; 
Ndriven = 18;
GR = Ndriven/Ndriving; %teeth driving / teeth driven
r_wheel = .254; %radius of wheel
torqueMax = 15; % Torque at driving wheel
tractiveForceMax = torqueMax*GR/r_wheel;

%Laps
numLaps = 10; %For plotting later

%PID Controller
P_Driver = 250;
I_Driver = 1;
D_Driver = 0;

%% Simulate
sim('Driver_Glider.slx')

tractivePowerOut = results(:,1);
tractiveEnergyOut = results(:,2);
propellingEnergyOut = results(:,3);
brakingEnergyOut = results(:,4);
vehiclePosOut = results(:,5);
vehicleVeloOut = results(:,6);
%%%%%TODO, ADD RESULTS GATHERING

%% Plot Results
% Drive Cycle Adherance
figure(1)
grid on
hold on
plot(distance, speed)
plot(vehiclePosOut, vehicleVeloOut)
hold off
xlabel('Distance (s)')
ylabel('Speed (m/s)')
legend('Drive Cycle Speed','Simulated Vehicle Speed')
title('Drive Cycle Adherance')

% Torque Speed Operating Points
figure(2)
scatter(motorSpeedOut, motorTorqueOut);
xlabel('Speed (radps)')
ylabel('Torque (Nm)')
title('Motor Torque-Speed Operating Points')
grid on

% Elevation vs Distance & Speed vs Distance
figure(3)
hold on
plot(distance, elevation)
plot(distance, speed)
hold off

%Tractive Force vs Time
figure(4)
plot(simTime,tractiveForceOut)
xlabel('Time (s)')
ylabel('Tractive Force (N)')
grid on

% figure(3)
% %Total Tractive Power
% subplot(3,2,1)
% plot(simTime, results(:,1))
% xlabel('Time (s)')
% ylabel('Power (W)')
% grid on
% 
% %Total Tractive Energy kWh
% subplot(3,2,2)
% plot(simTime, results(:,2))
% xlabel('Time (s)')
% ylabel('Energy (kWh)')
% grid on
% 
% %Propelling Energy
% subplot(3,2,3)
% plot(simTime, results(:,3))
% xlabel('Time (s)')
% ylabel('Propelling Energy (J)')
% grid on
% 
% %Braking Energy
% subplot(3,2,4)
% plot(simTime, results(:,4))
% xlabel('Time (s)')
% ylabel('Braking Energy (J)')
% grid on
% 
% %Vehicle Position
% subplot(3,2,5)
% plot(simTime, results(:,5))
% xlabel('Time (s)')
% ylabel('Vehicle Position (m)')
% grid on
% 
% %Vehicle Velocity
% subplot(3,2,6)
% plot(simTime, results(:,6))
% xlabel('Time (s)')
% ylabel('Velocity (m/s)')
% grid on
% 

