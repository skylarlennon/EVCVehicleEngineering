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
P_Driver = 7500;
I_Driver = 1;
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
motorMaxToruqe = 15;
motorMaxPower = 2e3;
motorMaxSpeed = 2000/60*2*pi; %radps

%Drivetrain
r_wheel = .254; %radius of wheel
Ndriving = 6; 
Ndriven = 72;
GR = Ndriven/Ndriving; %teeth driving / teeth driven
%To set saturation in PID controller output
maxTorque = motorMaxToruqe*GR; %torque at driven wheel
tractiveForceMax = maxTorque/r_wheel;

%% Simulate
sim('Driver_Glider.slx')

tractivePowerOut = results(:,1);
tractiveEnergyOut = results(:,2);
propellingEnergyOut = results(:,3);
brakingEnergyOut = results(:,4);
vehiclePosOut = results(:,5);
vehicleVeloOut = results(:,6);

%% Plot Drive Cycle Adherance Over Time
figure(1)
grid on
hold on

yyaxis left
plot(tout, referenceVelocityOut,'-b')
plot(tout, actualVelocityOut,'-r')
ylabel('Velocity (m/s)')

yyaxis right
plot(tout, elevation,'-k')
h = ylabel('Elevation (m)');
set(h,'Color','black')
ax = gca;
ax.YColor = 'black';

hold off
xlim([0 tout(end)/numLaps*3])
xlabel('Time (s)')
legend('Drive Cycle Velocity','Simulated Velocity', 'Elevation')
title('Driver Glider Drive Cycle Adherance')
%calculate the drive cycle adherance %
total_error = sum(abs(referenceVelocityOut - actualVelocityOut));
total_adherance = sum(abs(referenceVelocityOut));
DriverGlider_drive_cycle_adherance = (1-(total_error/total_adherance))*100

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
title('Driver Glider Motor Tractive Force & Friction Braking Force vs Elevation')

% % Torque Speed Operating Points
% % figure(2)
% % scatter(motorSpeedOut, motorTorqueOut);
% % xlabel('Speed (radps)')
% % ylabel('Torque (Nm)')
% % title('Motor Torque-Speed Operating Points')
% % grid on
% 
% % Elevation vs Distance & Speed vs Distance
% figure(3)
% hold on
% plot(distance, elevation)
% plot(distance, speed)
% hold off
% 
% %Tractive Force vs Time
% figure(4)
% plot(simTime,tractiveForceOut)
% xlabel('Time (s)')
% ylabel('Tractive Force (N)')
% grid on
% 
% %elevation vs time, tractive force vs time
% figure(5)
% 
% 
% 
% % figure(3)
% % %Total Tractive Power
% % subplot(3,2,1)
% % plot(simTime, results(:,1))
% % xlabel('Time (s)')
% % ylabel('Power (W)')
% % grid on
% % 
% % %Total Tractive Energy kWh
% % subplot(3,2,2)
% % plot(simTime, results(:,2))
% % xlabel('Time (s)')
% % ylabel('Energy (kWh)')
% % grid on
% % 
% % %Propelling Energy
% % subplot(3,2,3)
% % plot(simTime, results(:,3))
% % xlabel('Time (s)')
% % ylabel('Propelling Energy (J)')
% % grid on
% % 
% % %Braking Energy
% % subplot(3,2,4)
% % plot(simTime, results(:,4))
% % xlabel('Time (s)')
% % ylabel('Braking Energy (J)')
% % grid on
% % 
% % %Vehicle Position
% % subplot(3,2,5)
% % plot(simTime, results(:,5))
% % xlabel('Time (s)')
% % ylabel('Vehicle Position (m)')
% % grid on
% % 
% % %Vehicle Velocity
% % subplot(3,2,6)
% % plot(simTime, results(:,6))
% % xlabel('Time (s)')
% % ylabel('Velocity (m/s)')
% % grid on
% % 
% 
