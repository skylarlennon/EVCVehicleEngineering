%% EV Simple
%TODO: ADD DESCRIPTION HERE
clc;clear;close all
%% Load Drive Cycle Data
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

%% Set Model Parameters

% PID Controller
P_Driver = 150;
I_Driver = 0.40;
D_Driver = 0;

% Environment
airDensity = 1.293;
gravity = 9.81;

% Vehicle
maxBrakeForce = -400; %N
rollingResistCoeff = 0.01;
massVeh = 130; %kg
aeroDragCoeff = 0.17;
frontArea = 0.951; %m^2
cdaf = airDensity*aeroDragCoeff;

% Motor (KDE Direct 7208XF)
motorMaxTorque = 15;
motorMaxPower = 2e3;
MotorMaxSpeed = 2000/60*2*pi; %radps

% Drivetrain
r_wheel = 0.3048;
Ndriving = 1; 
Ndriven = 4;
GR = Ndriven/Ndriving;
Spinloss = 6;

% Motor Efficiency Parameters
% TODO: Make this in agreement w the KDE Direct Motor
MotorKc = 0.0452;
MotorKw = 5.0664e-5;
MotorKi = 0.0167;
MotorC = 628.2974;

% Battery
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
motorSpeedOut1 = results(:,20); 
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
plot(tout, speedCommand,'-b')
plot(tout, speedVehicle,'-r')
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
% calculate the drive cycle adherance %
total_error = sum(abs(speedCommand - speedVehicle));
total_adherance = sum(abs(speedCommand));
EVSimple_drive_cycle_adherance = (1-(total_error/total_adherance))*100

%% Plot Motor's Torque Speed Operating Points for Drive Cycle
% Calculate the speed at which the torque starts to decrease
thresholdSpeed = motorMaxPower / motorMaxTorque;
envelopeSpeed = linspace(0, MotorMaxSpeed, 1000); % Speed from 0 to maxSpeed
% Calculate torque
envelopeTorque = zeros(size(envelopeSpeed));
for i = 1:length(envelopeSpeed)
    if envelopeSpeed(i) <= thresholdSpeed
        envelopeTorque(i) = motorMaxTorque;
    else
        envelopeTorque(i) = motorMaxPower / envelopeSpeed(i);
    end
end

figure(2)
grid on
xlabel('Speed (radps)')
ylabel('Torque (Nm)')
xlim([0 MotorMaxSpeed])
ylim([0 motorMaxTorque])
legend('Torque-Speed Envelope', 'Torque-Speed Operating Points')
titleString = sprintf('Torque Speed Data for %d Nm, %d kW Motor',motorMaxTorque, motorMaxPower/1e3);
title(titleString)
hold on
plot(envelopeSpeed, envelopeTorque, 'LineWidth', 2, 'DisplayName', 'Torque-Speed Envelope'); % The envelope line
scatter(motorSpeedOut,motorTorqueOut)
hold off

% Uncomment the following lines and comment the above lines from 'figure(3)
% to 'hold off' in order to see an animation of the torque speed operating points of the
% motor over the drive cycle.

% TODO: Figure out why it slows down near the end of the simulation
% figure(3)
% hold on
% plt = plot(envelopeSpeed, envelopeTorque, 'LineWidth', 2, 'DisplayName', 'Torque-Speed Envelope'); % The envelope line
% grid on
% xlabel('Speed (radps)')
% ylabel('Torque (Nm)')
% xlim([0 MotorMaxSpeed])
% ylim([0 motorMaxTorque])
% legend('show') % Ensure the legend only includes the envelope line
% titleString = sprintf('Torque Speed Data for %d Nm, %d kW Motor', motorMaxTorque, motorMaxPower/1e3);
% title(titleString)
% 
% % Loop to plot the data points sequentially
% for i = 1:length(motorTorqueOut)
%     % Plot the current data point without adding to the legend
%     scatter(motorSpeedOut(i), motorTorqueOut(i), 'filled', 'MarkerFaceColor', 'b', 'HandleVisibility', 'off');
% 
%     pause(0.01); % Pause to create the animation effect
% end
% hold off


%% Plot Tractive & Braking Forces Over Time
figure(3)
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


%% Plot Output Power & Energy Over Time
figure(4)
%Tractive Power Out kW
subplot(2,2,1)
plot(simTime, tractivePowerOut)
xlabel('Time (s)')
ylabel('Tractive Power (kW)')
grid on

%Cumulative Tractive Energy kWh
subplot(2,2,2)
plot(simTime, totalTractiveEnergyOutkWh)
xlabel('Time (s)')
ylabel('Tractive Energy (kWh)')
grid on

%Cumulative Propelling Energy J
subplot(2,2,3)
plot(simTime, propellingEnergyOut)
xlabel('Time (s)')
ylabel('Propelling Energy (kWh)')
grid on

%Cumulative Braking Energy
subplot(2,2,4)
plot(simTime, brakingEnergyOut)
xlabel('Time (s)')
ylabel('Braking Energy (kWh)')
grid on

total_dist_mi = distance(end)*0.000621371 %0.000621371 mi/m
total_efficiency_miles_per_kWh = total_dist_mi/propellingEnergyOut(end)
total_efficiency_mpge = total_efficiency_miles_per_kWh*33.705
