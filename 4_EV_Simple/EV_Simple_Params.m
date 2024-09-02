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
StopTime = time(end);
numLaps = 10;

%% Model Parameters
%PID Controller
P_Driver = 225;
I_Driver = 0.40;
D_Driver = 0;

%Environment
airDensity = 1.293;
gravity = 9.81;

%Vehicle
maxBrakeForce = 2000; %N
rollingResistCoeff = 0.01;
massVeh = 173; %kg
aeroDragCoeff = 0.17;
frontArea = 0.951; %m^2
cdaf = airDensity*aeroDragCoeff;

%Motor
motorMaxTorque = 15;
motorMaxPower = 2e3;
motorMaxSpeed = 2000/60*2*pi; %radps

%Drivetrain
r_wheel = .254; %radius of wheel
Ndriving = 6; 
Ndriven = 24;
GR = Ndriven/Ndriving; %teeth driving / teeth driven
%To calculate drivetrain losses
Spinloss = 6;

%For motor efficiency calculations
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

%% Simulate
sim('EV_Simple.slx')

socOut = results(:,1);
batteryPowerLossesOut = results(:,2);
batteryEnergyLosses = results(:,3);
voltageAtTerminals = results(:,4);
batteryPowerAtTerminals = results(:,5);
bateryEnergyAtTerminals = results(:,6);
batteryCurent(:,7) = results(:,7);
motorPowerOut = results(:,8);
motorEnergyOut = results(:,9);
motorPowerInputOut = results(:,10);
motorEnergyInputOut = results(:,11);
motorPowerLossesOut = results(:,12);
motorEnergyLossesOut = results(:,13);
motorTorqueOut = results(:,14);
motorSpeedOut = results(:,15);
drivelinePowerLossOut = results(:,16);
drivelineLossesOutkWh = results(:,17);
drivelineLossesOutJ = results(:,18);
drivelineTorqueOut = results(:,19); 
% motorSpeedOut1 = results(:,20); redundant
netTractiveForceOut = results(:,21);
tractivePowerOut = results(:,22);
totalTractiveEnergyOutkWh = results(:,23);
totalTractiveEnergyOutJ = results(:,24);
propellingEnergyOut = results(:,25);
brakingEnergyOut = results(:,26);
velocityOut = results(:,27);
vehPosOut = results(:,28);

%% Plot Drive Cycle Adherance Over Time
figure(1)
grid on
hold on

yyaxis left
plot(tout, referenceVelocityOut,'-b')
plot(tout, actualVelocityOut,'-r')
ylabel('Velocity (m/s)')

yyaxis right
plot(tout,elevation,'-k')
h = ylabel('Elevation (m)');
set(h,'Color','black')
ax = gca;
ax.YColor = 'black';

hold off
xlim([0 tout(end)/numLaps*3])
xlabel('Time (s)')
legend('Drive Cycle Velocity','Simulated Velocity','Elevation')
title('EV Simple Drive Cycle Adherance Over Time')
%calculate the drive cycle adherance %
total_error = sum(abs(referenceVelocityOut - actualVelocityOut));
total_adherance = sum(abs(referenceVelocityOut));
drive_cycle_adherance_time = (1-(total_error/total_adherance))*100

%% Plot Tractive Force Over Time w Elevation
figure(2)
grid on
hold on

yyaxis left
plot(tout,positiveTractiveForceOut,'-b')
plot(tout,frictionBrakingForceOut,'-r')
ylabel('Tractive Force (N)')

yyaxis right
plot(time,elevation,'-k')
h = ylabel('Elevation (m)');
set(h,'Color','black')
ax = gca;
ax.YColor = 'black';

hold off
xlim([0 tout(end)/numLaps*3]) %plot 3 laps
xlabel('Time (s)')
legend('Positive Tractive Force','Friction Braking Force','Elevation')
title('EV Simple Motor Tractive Force Over Time')

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

% % Torque Speed
% % Calculate the speed at which the torque starts to decrease
% thresholdSpeed = MotorMaxPower / MotorMaxTorque;
% envelopeSpeed = linspace(0, MotorMaxSpeed, 1000); % Speed from 0 to maxSpeed
% % Calculate torque
% envelopeTorque = zeros(size(envelopeSpeed));
% for i = 1:length(envelopeSpeed)
%     if envelopeSpeed(i) <= thresholdSpeed
%         envelopeTorque(i) = MotorMaxTorque;
%     else
%         envelopeTorque(i) = MotorMaxPower / envelopeSpeed(i);
%     end
% end
% 
% figure(4)
% grid on
% xlabel('Speed (radps)')
% ylabel('Torque (Nm)')
% xlim([0 MotorMaxSpeed])
% ylim([0 MotorMaxTorque])
% legend('Torque-Speed Envelope', 'Torque-Speed Operating Points')
% titleString = sprintf('Torque Speed Data for %d Nm, %d kW Motor',MotorMaxTorque, MotorMaxPower/1e3);
% title(titleString)
% hold on
% plot(envelopeSpeed, envelopeTorque, 'LineWidth', 2, 'DisplayName', 'Torque-Speed Envelope'); % The envelope line
% scatter(motorSpeedOut,motorTorqueOut)
% hold off


% figure(4)
% grid on
% hold on 
% yyaxis left
% ylabel('Power (W)')
% plot(tout, motorPowerOutput)
% 
% yyaxis right
% ylabel('Speed (rad/s)')
% plot(tout, motorSpeedOut)
% hold off
% xlabel('Time (s)')
% legend('Power', 'Speed')
% xlim([0 250])

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
