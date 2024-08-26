%% Plot Torque Speed Efficiency Data
clc;clear;close all

motorMaxTorque = 230;
motorMaxPower = 124e3;
motorMaxSpeed = 6500/60*2*pi; %radps

% Step 1: Load the CSV file
data = readmatrix('TorqueSpeedEfficiency.csv');

% Step 2: Extract the relevant columns
torque = data(:, 1);          
speed = data(:, 2);            
efficiency = data(:, 3); 

% Step 3: Create a grid for contour plot
[torqueGrid, speedGrid] = meshgrid(linspace(min(torque), max(torque), 100), ...
                                   linspace(min(speed), max(speed), 100));

% Step 4: Interpolate efficiency values on the grid
efficiencyGrid = griddata(torque, speed, efficiency, torqueGrid, speedGrid, 'linear');


% Step 5: Generate the Torque-Speed Envelope
thresholdSpeed = (motorMaxPower / motorMaxTorque)/(2*pi)*60; %rpm
envelopeSpeed = linspace(0, motorMaxSpeed, 1000); % In RPM
% Calculate torque
envelopeTorque = zeros(size(envelopeSpeed));
for i = 1:length(envelopeSpeed)
    if envelopeSpeed(i) <= thresholdSpeed
        envelopeTorque(i) = motorMaxTorque;
    else
        envelopeTorque(i) = motorMaxPower / ((envelopeSpeed(i)/(2*pi)*60));
    end
end

% Step 6: Plot the contour map
hold on
contourf(torqueGrid, speedGrid, efficiencyGrid, 20); % 20 contour levels
plot(envelopeSpeed,envelopeTorque,'LineWidth',2,'Color','r');
colorbarHandle = colorbar; % Show color bar and get the handle
ylabel(colorbarHandle, 'Efficiency (%)'); % Add title to the colorbar
xlabel('Speed');
ylabel('Torque');