%% Phase Current Calcs
clc;clear all; close all;

% Sim Constants
EffPowerTrain = 0.95; % %
V_bat = 50; %V
R_ph = 0.113; %Ohms

P_nominal = 131.86; %W
P_nominal_draw = P_nominal*(1 + (1-EffPowerTrain));

P_max = 2145; %W
P_max_draw = P_max*(1 + (1-EffPowerTrain));

theta = linspace(0,2*pi,1000);

I_nominal = P_nominal_draw/V_bat;
I_max = P_max_draw/V_bat;

I_d_nominal = I_nominal*cos(theta); % underlying assumption...
I_q_nominal = I_nominal*sin(theta);

I_d_max = I_max*cos(theta);
I_q_max = I_max*sin(theta);

I_a_nominal = I_d_nominal;
I_b_nominal = -1/2*I_d_nominal + sqrt(3)/2*I_q_nominal;
I_c_nominal = -1/2*I_d_nominal - sqrt(3)/2*I_q_nominal;

I_a_max = I_d_max;
I_b_max = -1/2*I_d_max + sqrt(3)/2*I_q_max;
I_c_max = -1/2*I_d_max - sqrt(3)/2*I_q_max;


figure(1)
sgtitle("Nominal 2 & 3 Phase Currents")
subplot(1,2,1)
hold on 
plot(theta, I_a_nominal);
plot(theta, I_b_nominal);
plot(theta, I_c_nominal);
hold off
grid on
xlabel('Theta (rads)')
ylabel('Amps')

subplot(1,2,2)
hold on 
plot(theta, I_d_nominal);
plot(theta, I_q_nominal);
hold off
grid on
xlabel('Theta (rads)')
ylabel('Amps')


figure(2)
sgtitle("Max 2 & 3 Phase Currents")
subplot(1,2,1)
hold on 
plot(theta, I_a_max);
plot(theta, I_b_max);
plot(theta, I_c_max);
hold off
grid on
xlabel('Theta (rads)')
ylabel('Amps')

subplot(1,2,2)
hold on 
plot(theta, I_d_max);
plot(theta, I_q_max);
hold off
grid on
xlabel('Theta (rads)')
ylabel('Amps')


maxNominal2ph = max(I_q_nominal)
maxNominal3ph = max(I_c_nominal)
Nominal_RMS_Phase_Current = maxNominal3ph/sqrt(2)

maxMax2ph = max(I_q_max)
maxMax3ph = max(I_c_max)
Max_RMS_Phase_Current = maxMax3ph/sqrt(2)

Nominal_Resistive_Losses = 3*(Nominal_RMS_Phase_Current.^2.*R_ph)
Max_Resistive_Losses = 3*(Max_RMS_Phase_Current.^2.*R_ph)




