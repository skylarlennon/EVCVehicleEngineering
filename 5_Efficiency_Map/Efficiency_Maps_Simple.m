%% Efficiency Maps Simple
% Author:   Skylar Lennon
% Date:     7/16/24
clc;clear;close all;

%% MOTOR PARAMETERS
% Motor:                                EMRAX 228: https://emrax.com/wp-content/uploads/2024/02/EMRAX_228_datasheet_v1.5.pdf
Kt = 0.94;                              %Torque constant (Nm/RMS_Phase_Current) (Nm/A)
r_ph = 15.48e-3;                        %Phase resistance (Ohms)
pp = 10;                                %Pole pairs
M_motor = 13.2;                         %Motor mass (kg)
M_stator = M_motor*(1/3);               %Estimated stator mass (kg)
Bmax = 1.5;                             %Estimated Max flux density (T)                      
RPM_Max = 6500;                         %Max Motor RPM
Torque_Max = 230;                       %Max Motor Torque

%% CALCULATING THE STEINMETZ COEFFICIENTS
steinmetz = fittype('k * f^alpha * B^beta', 'independent', {'f', 'B'},...
                    'coefficients', {'k', 'alpha', 'beta'});

% Data from JFE Steel (pg 14) https://www.jfe-steel.co.jp/en/products/electrical/catalog/f1e-001.pdf
f = [50, 50, 60, 60];                   % frequency 
B = [1.0, 1.5, 1.0, 1.5];               % flux density
P = [1.45, 3.25, 1.85, 4.05];           % core loss

% Fit the data
fitresult = fit([f', B'], P', steinmetz, 'StartPoint', [1e-3, 1.5, 2.5]);

coefficients = coeffvalues(fitresult);
k = coefficients(1);
alpha = coefficients(2);
beta = coefficients(3);
%% DOMAIN
rpm = [0:5:RPM_Max];
torque = [0:1:Torque_Max];
[RPM, TORQUE] = meshgrid(rpm, torque);
FREQUENCY = RPM./60;
RADS = FREQUENCY.*2.*pi;

%% RESISTIVE LOSSES (I^2R LOSSES)
RMS_PHASE_CURRENT = TORQUE./Kt;
RESISTIVE_LOSSES = 3.*RMS_PHASE_CURRENT.^2 .* r_ph;

%% CORE LOSSES
CORE_LOSSES = (k.*(FREQUENCY.*pp).^alpha.*Bmax.^beta)*M_stator;

%% MECHANICAL LOSSES
MECHANICAL_LOSSES = 0; %Simplifying assumption

%% TOTAL LOSSES
TOTAL_LOSSES = MECHANICAL_LOSSES + CORE_LOSSES + RESISTIVE_LOSSES;

%% OUTPUT POWER
OUTPUT_POWER = TORQUE.*RADS;

%% INPUT POWER 
INPUT_POWER = OUTPUT_POWER + TOTAL_LOSSES;

%% EFFICIENCY
EFFICIENCY = OUTPUT_POWER./INPUT_POWER;

%% PLOT LOSSES
figure(1)
% sgtitle("Theoretical Motor Losses for EMRAX 228")

% subplot(3,1,1)
contourf(RPM, TORQUE, RESISTIVE_LOSSES,10,'ShowText','on','LabelFormat','%.1f');
xlabel("RPM")
ylabel("Torque (N-m)")
title("I^2R Losses")
colorbar('eastoutside');
c2 = colorbar;
c2.Label.String = 'Power Loss (W)'; % Label the colorbar
c2.FontSize = 12; % Set the font size for the colorbar label

figure(2)
% subplot(3,1,2)
contourf(RPM, TORQUE, CORE_LOSSES,10,'ShowText', 'on','LabelFormat','%1f');
xlabel("RPM")
ylabel("Torque (N-m)")
title("Total Core Losses")
colorbar('eastoutside');
c4 = colorbar;
c4.Label.String = 'Power Loss (W)'; % Label the colorbar
c4.FontSize = 12; % Set the font size for the colorbar label

% subplot(3,1,3)
figure(3)
contourf(RPM, TORQUE, TOTAL_LOSSES,10,'ShowText', 'on','LabelFormat','%1f');
xlabel("RPM")
ylabel("Torque (N-m)")
title("Total Losses")
colorbar('eastoutside');
c4 = colorbar;
c4.Label.String = 'Power Loss (W)'; % Label the colorbar
c4.FontSize = 12; % Set the font size for the colorbar label

%% PLOT INPUT & OUTPUT POWER
% figure(4)
subplot(1,2,1)
contourf(RPM, TORQUE, OUTPUT_POWER,10,'ShowText', 'on','LabelFormat','%1f');
xlabel("RPM")
ylabel("Torque (N-m)")
title("Output Power (Torque x Angular Velocity)")
colorbar('eastoutside');
c4 = colorbar;
c4.Label.String = 'Power (W)'; % Label the colorbar
c4.FontSize = 12; % Set the font size for the colorbar label

subplot(1,2,2)
% figure(5)
contourf(RPM, TORQUE, INPUT_POWER,10,'ShowText', 'on','LabelFormat','%1f');
xlabel("RPM")
ylabel("Torque (N-m)")
title("Input Power (Output Power + Total Losses)")
colorbar('eastoutside');
c4 = colorbar;
c4.Label.String = 'Power (W)'; % Label the colorbar
c4.FontSize = 12; % Set the font size for the colorbar label

%% PLOT EFFICIENCY
maxPower = 124e3;
speedMaxTorqueLim = (maxPower/Torque_Max)/(2*pi)*60; %rpm
maxRads = RPM_Max/60*2*pi;
outside_range = (TORQUE > Torque_Max | TORQUE > maxPower./RADS| RADS > maxRads);
EFFICIENCY(outside_range) = 0;

figure(6)
levels = [0.7:0.025:0.95];
contourf(RPM, TORQUE, EFFICIENCY,levels);
xlabel("RPM")
ylabel("Torque (N-m)")
xlim([0 1.1*RPM_Max])
ylim([0 1.1*Torque_Max])
title("EMRAX 228 Efficiency Map (Output Power/Input Power)")
colorbar('eastoutside');
c4 = colorbar;
c4.Label.String = 'Efficiency (%)'; % Label the colorbar
c4.FontSize = 12; % Set the font size for the colorbar label



