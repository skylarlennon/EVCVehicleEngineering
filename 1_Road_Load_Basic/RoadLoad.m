%% Vehicle Road Load
% Provided By The University of Michigan Supermileage Team

% This Matlab script is a series of parameters and equations modeling the
% basic motion and power consumption of a road vehicle represented as a
% point mass including both steady state and acceleration scenarios. The
% provided parameters model the Supermileage vehicle named Cedar currently being 
% developed as of Fall 2024.

clc;clear;close all;

%% Parameters
t = [0:0.1:40];                             %Seconds
mMech = 78.821;                             %kg
mElec = 23.869;                             %kg
mCar = mMech + mElec;                       %kg 
mdriver = 70.0;                             %kg
% mtot = mCar + mdriver;                      %kg         
mtot = 170;
g = 9.8;                                    %m/s^2 (Gravity)
rho = 1.23;                                 %kg/m^3 (Density of Air)
C_d = 0.15;                                 %(Coefficient of drag)                   
C_r = 0.00378;                              %(Rolling resistance coefficient)
A = 0.70;                                   %m^2 (Cross sectional area)
theta = (2*pi)/36;                          %Radians (Road Gradient) 
Voltage = 50;                               %V (Bus/Battery Voltage)
accel = 0.5;                                %m/s^2
v = accel.*t;                               %m/s
velo = 7.6;                                 %17mph
transmission_eff = 0.92;                    %percent 
motor_eff = 0.9;                            %percent, (Includes copper, core, & mechanical losses)
busbar_resistance = 1e-4;                   %Ohms
est_accessory_elec_power_draw = 50;         %Watts          

%% Acceleration
F_drag_a = 0.5.*rho.*(v.^2).*C_d.*A;        %N (Foce of drag)
F_n_a = mtot*g*cos(0);                      %N (Normal force)
F_grad_a = mtot*g*sin(0);                   %N (Force of gradient)
F_rr_a = F_n_a * C_r;                       %N (Force of rolling resistance)
F_res_a = F_rr_a + F_drag_a + F_grad_a;     %N (Total resistive forces)
F_tractive_accel = F_res_a + mtot*accel;    %N (Tractive force)

accel_power_road = F_tractive_accel.*v;
accel_motor_input_power = accel_power_road.*(1 + (1 - transmission_eff*motor_eff));
accel_current = accel_motor_input_power/Voltage;
accel_I2R_losses = accel_current.^2.*busbar_resistance;
total_accel_power_draw = accel_I2R_losses + accel_motor_input_power + est_accessory_elec_power_draw;

%% Constant Speed on Hill
F_drag_h = 0.5.*rho.*velo.^2.*C_d.*A;       %N (Foce of drag)
F_n_h = mtot*g*cos(theta);                  %N (Normal force)
F_grad_h = mtot*g*sin(theta);               %N (Force of gradient)                                
F_rr_h = F_n_h * C_r;                       %N (Force of rolling resistance)
F_res_h = F_rr_h + F_grad_h + F_drag_h;     %N (Total resistive forces)
F_tractive_hill = ones(1,length(t))*F_res_h;%N (Tractive force)

hill_power_road = F_tractive_hill.*velo;
hill_motor_input_power = hill_power_road.*(1 + (1 - transmission_eff*motor_eff));
hill_current = hill_motor_input_power/Voltage;
hill_I2R_losses = hill_current.^2*busbar_resistance;
total_hill_power_draw = hill_I2R_losses + hill_motor_input_power + est_accessory_elec_power_draw;

%% Constant Speed Flat Ground
F_drag_f = 0.5.*rho.*velo.^2.*C_d.*A;       %N (Foce of drag)
F_n_f = mtot*g*cos(0);                      %N (Normal force)
F_grad_f = mtot*g*sin(0);                   %N (Force of gradient)  
F_rr_f = F_n_f * C_r;                       %N (Force of rolling resistance)
F_res_f = F_rr_f + F_grad_f + F_drag_f;     %N (Total resistive forces)
F_tractive_flat = ones(1,length(t))*F_res_f;%N (Tractive force)       

flat_power_road = F_tractive_flat.*velo;
flat_motor_input_power = flat_power_road.*(1 + (1 - transmission_eff*motor_eff));
flat_current = flat_motor_input_power/Voltage;
flat_I2R_losses = flat_current.^2.*busbar_resistance;
total_flat_power_draw = flat_I2R_losses + flat_motor_input_power + est_accessory_elec_power_draw;

%% Plots
figure(10)
hold on
plot(t,accel_power_road,LineWidth=2);
plot(t,hill_power_road,LineWidth=2);
plot(t,flat_power_road,LineWidth=2);
title("Ceddar Tractive Power","FontSize",12)
xlabel('Time (s)')
ylabel('Power (W)')
ylim([0 max(hill_power_road)*1.1])
legend("0.5m/s^2 Acceleration", "17mph, 10 Degree Hill","17mph, Flat Ground","FontSize",10);
grid on
hold off

figure(1)
hold on
plot(t,F_tractive_accel,LineWidth=2);
plot(t,F_tractive_hill,LineWidth=2);
plot(t,F_tractive_flat,LineWidth=2);
title("Ceddar Tractive Forces","FontSize",12)
xlabel('Time (s)')
ylabel('Force (N)')
ylim([0 max(F_tractive_hill)*1.1])
legend("0.5m/s^2 Acceleration", "17mph, 10 Degree Hill","17mph, Flat Ground","FontSize",10);
grid on
hold off

figure(2)
subplot(2,1,1)
hold on
plot(t,total_accel_power_draw,LineWidth=2);
plot(t,total_hill_power_draw,LineWidth=2);
plot(t,total_flat_power_draw,LineWidth=2);
title("Cedar Power Draw","FontSize",12);
xlabel("Time (s)");
ylabel("Power (W)");
xlim([0 30])
legend("0.5m/s^2 Acceleration", "17mph, 10 Degree Hill","17mph, Flat Ground","FontSize",10);
grid on
hold off

subplot(2,1,2)
hold on
plot(t,accel_current,LineWidth=2);
plot(t,hill_current,LineWidth=2);
plot(t,flat_current,LineWidth=2);
title("Cedar Current Draw","FontSize",12);
xlabel("Time (s)");
ylabel("Current (A)");
xlim([0 30])
legend("0.5m/s^2 Acceleration", "17mph, 10 Degree Hill","17mph, Flat Ground","FontSize",10);
grid on
hold off
