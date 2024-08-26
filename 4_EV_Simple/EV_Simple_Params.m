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
theta = driveCycleData(:,5);
timeSpeedData = timeseries(speed,time);
timeThetaData = timeseries(theta,time);
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
GearRatio = 4;
wheelRadius = 0.34;

%% Simulate
sim('EV_Simple.slx')


motorTorqueOut = results(:,14);
motorSpeedOut = results(:,15);
vehPosOut = results(:,28);

%% Plot Results

% Drive Cycle Adherance w Time
figure(1)
grid on
hold on
plot(tout, speedCommand)
plot(tout, speedVehicle)
hold off
xlabel('Time (s)')
ylabel('Speed (m/s)')
legend('Drive Cycle Speed','Vehicle Speed')
title('Drive Cycle Adherance')

% TODO: Drive Cycle Adherance w Distance
% figure(2)
% grid on
% hold on
% plot(distance, speed)
% plot(vehPosOut, speedVehicle)
% hold off
% xlabel('Distance (m)')
% ylabel('Speed (m/s)')
% legend('Drive Cycle Speed','Vehicle Speed')
% title('Drive Cycle Adherance')

% Torque Speed
% Calculate the speed at which the torque starts to decrease
thresholdSpeed = MotorMaxPower / MotorMaxTorque;
envelopeSpeed = linspace(0, MotorMaxSpeed, 1000); % Speed from 0 to maxSpeed
% Calculate torque
envelopeTorque = zeros(size(envelopeSpeed));
for i = 1:length(envelopeSpeed)
    if envelopeSpeed(i) <= thresholdSpeed
        envelopeTorque(i) = MotorMaxTorque;
    else
        envelopeTorque(i) = MotorMaxPower / envelopeSpeed(i);
    end
end

figure(3)
grid on
xlabel('Speed (radps)')
ylabel('Torque (Nm)')
xlim([0 MotorMaxSpeed])
ylim([0 MotorMaxTorque])
legend('Torque-Speed Envelope', 'Torque-Speed Operating Points')
titleString = sprintf('Torque Speed Data for %d Nm, %d kW Motor',MotorMaxTorque, MotorMaxPower/1e3);
title(titleString)
hold on
plot(envelopeSpeed, envelopeTorque, 'LineWidth', 2, 'DisplayName', 'Torque-Speed Envelope'); % The envelope line
scatter(motorSpeedOut,motorTorqueOut)
hold off

% figure(3)
% hold on
% plt = plot(envelopeSpeed, envelopeTorque, 'LineWidth', 2, 'DisplayName', 'Torque-Speed Envelope'); % The envelope line
% grid on
% xlabel('Speed (radps)')
% ylabel('Torque (Nm)')
% xlim([0 MotorMaxSpeed])
% ylim([0 MotorMaxTorque])
% legend('show') % Ensure the legend only includes the envelope line
% titleString = sprintf('Torque Speed Data for %d Nm, %d kW Motor', MotorMaxTorque, MotorMaxPower/1e3);
% title(titleString)
% 
% % Loop to plot the data points sequentially
% for i = 1:length(motorTorqueOut)
%     % Plot the current data point without adding to the legend
%     scatter(motorSpeedOut(i), motorTorqueOut(i), 'filled', 'MarkerFaceColor', 'b', 'HandleVisibility', 'off');
% 
%     pause(0.01); % Pause to create the animation effect
% end
% 
% hold off

%Distance vs Elevation & Distance vs Speed
% figure(4)
% hold on
% yyaxis left
% plot(distance, elevation)
% ylabel('Relative Elevation (m)')
% 
% yyaxis right
% plot(distance,speed)
% ylabel('Drive Cycle Speed')
% xlim([0 1440])
% hold off
% grid on
% 
% 
% figure(5)
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
% 
