%% Efficiency Maps Intermediate
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
r_ds = 0.05;                            %Drive sprocket radius
BearingForceMax = Torque_Max/r_ds;      %Approximate max radial force on motor bearing, input value to SKF calculator
BearingLossMax = 144;                   %Watts - input from SKF calculator
BearingLossSafetyFactor = 2.0;          %Bearing loss safety factor, accounts for additional losses
Max_Wdg_Loss = 100;                     %Maximum expected windage loss
WdgLossSafetyFactor = 5;                %Accounts for additional losses
WdgCoeff = Max_Wdg_Loss/(RPM_Max^3);    %Coefficient for simplified windage loss equation

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
BEARING_LOSSES = ((RPM./RPM_Max) + (TORQUE./Torque_Max))./2.* BearingLossMax .* BearingLossSafetyFactor;
WINDAGE_LOSSES = WdgCoeff.*RPM.^3.*WdgLossSafetyFactor;
MECHANICAL_LOSSES = BEARING_LOSSES + WINDAGE_LOSSES; 

%% TOTAL LOSSES
TOTAL_LOSSES = MECHANICAL_LOSSES + CORE_LOSSES + RESISTIVE_LOSSES;

%% OUTPUT POWER
OUTPUT_POWER = TORQUE.*RADS;

%% INPUT POWER 
INPUT_POWER = OUTPUT_POWER + TOTAL_LOSSES;

%% EFFICIENCY
EFFICIENCY = OUTPUT_POWER./INPUT_POWER;

%% PLOT LOSSES
%Resistive Losses
figure(1)
contourf(RPM, TORQUE, RESISTIVE_LOSSES,10,'ShowText','on','LabelFormat','%.1f');
xlabel("RPM")
ylabel("Torque (N-m)")
title("I^2R Losses")
colorbar('eastoutside');
c2 = colorbar;
c2.Label.String = 'Power Loss (W)'; % Label the colorbar
c2.FontSize = 12; % Set the font size for the colorbar label

%Core Losses
figure(2)
contourf(RPM, TORQUE, CORE_LOSSES,10,'ShowText', 'on','LabelFormat','%1f');
xlabel("RPM")
ylabel("Torque (N-m)")
title("Total Core Losses")
colorbar('eastoutside');
c4 = colorbar;
c4.Label.String = 'Power Loss (W)'; % Label the colorbar
c4.FontSize = 12; % Set the font size for the colorbar label

%Mechanical Losses
figure(3)
contourf(RPM, TORQUE, BEARING_LOSSES,10,'ShowText', 'on','LabelFormat','%1f');
xlabel("RPM")
ylabel("Torque (N-m)")
title("Bearing Losses")
colorbar('eastoutside');
c4 = colorbar;
c4.Label.String = 'Power Loss (W)'; % Label the colorbar
c4.FontSize = 12; % Set the font size for the colorbar label

figure(4)
contourf(RPM, TORQUE, WINDAGE_LOSSES,10,'ShowText', 'on','LabelFormat','%1f');
xlabel("RPM")
ylabel("Torque (N-m)")
title("Windage Losses")
colorbar('eastoutside');
c4 = colorbar;
c4.Label.String = 'Power Loss (W)'; % Label the colorbar
c4.FontSize = 12; % Set the font size for the colorbar label

figure(5)
contourf(RPM, TORQUE, MECHANICAL_LOSSES,10,'ShowText', 'on','LabelFormat','%1f');
xlabel("RPM")
ylabel("Torque (N-m)")
title("Total Mechanical Losses")
colorbar('eastoutside');
c4 = colorbar;
c4.Label.String = 'Power Loss (W)'; % Label the colorbar
c4.FontSize = 12; % Set the font size for the colorbar label

% Total Losses
figure(6)
contourf(RPM, TORQUE, TOTAL_LOSSES,10,'ShowText', 'on','LabelFormat','%1f');
xlabel("RPM")
ylabel("Torque (N-m)")
title("Total Losses")
colorbar('eastoutside');
c4 = colorbar;
c4.Label.String = 'Power Loss (W)'; % Label the colorbar
c4.FontSize = 12; % Set the font size for the colorbar label

%% PLOT INPUT & OUTPUT POWER
figure(7)
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

figure(8)
% levels = [0.7:0.025:0.95];
levels = [0.86 0.9 0.94 0.95 0.96];
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
