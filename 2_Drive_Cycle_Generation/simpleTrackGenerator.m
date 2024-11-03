%% Simple Track Generator
% Use this script to create simple tracks to simulate your vehicle.
% Uncomment the section for the track type you want to generate.

% Parameters for all tracks
totalDist = 3925; % Total track distance in meters (e.g., Indy 500 Road Course)
distBetweenPoints = 5; % Distance between points in meters
distance = linspace(0, totalDist, floor(totalDist / distBetweenPoints));

%% Flat Track
% Uncomment this section to generate a flat track
elevationFlat = zeros(length(distance), 1); % Flat elevation
distElevationFlatOutput = [distance', elevationFlat];
csvwrite('simpleFlatTrack.csv', distElevationFlatOutput);

%% Steep Incline Track
% % Uncomment this section to generate a steep incline track
% inclineRate = 0.01; % Elevation gain per meter
% elevationIncline = inclineRate * distance;
% distElevationInclineOutput = [distance', elevationIncline'];
% csvwrite('steepInclineTrack.csv', distElevationInclineOutput);

%% Up & Down Hill Track
% % Uncomment this section to generate an up & down hill track
% hillFrequency = 2; % Number of hill cycles over the total distance
% hillAmplitude = 20; % Maximum height (m) of the hill
% elevationHill = hillAmplitude * sin(2 * pi * hillFrequency * (distance / totalDist))';
% distElevationHillOutput = [distance', elevationHill];
% csvwrite('upDownHillTrack.csv', distElevationHillOutput);

%% Rolling Hills Track
% % Uncomment this section to generate a rolling hills track
% hillAmplitudeVarying = hillAmplitude * (0.5 + 0.5 * cos(2 * pi * (distance / totalDist)));
% elevationRollingHills = hillAmplitudeVarying .* sin(2 * pi * hillFrequency * (distance / totalDist))';
% distElevationRollingHillsOutput = [distance', elevationRollingHills];
% csvwrite('rollingHillsTrack.csv', distElevationRollingHillsOutput);

%% Stair-Step Track
% % Uncomment this section to generate a stair-step track
% stepSize = 100; % Distance between steps in meters
% stepHeight = 5; % Elevation gain per step
% elevationStairStep = stepHeight * floor(distance / stepSize);
% distElevationStairStepOutput = [distance', elevationStairStep'];
% csvwrite('stairStepTrack.csv', distElevationStairStepOutput);

%% Valley Track
% % Uncomment this section to generate a valley track
% valleyDepth = -50; % Maximum descent (negative elevation)
% elevationValley = valleyDepth * sin(pi * (distance / totalDist))';
% distElevationValleyOutput = [distance', elevationValley];
% csvwrite('valleyTrack.csv', distElevationValleyOutput);

%% Random Bumps Track
% % Uncomment this section to generate a random bumps track
% bumpAmplitude = 2; % Maximum bump height
% elevationRandomBumps = bumpAmplitude * (2 * rand(size(distance)) - 1);
% distElevationRandomBumpsOutput = [distance', elevationRandomBumps'];
% csvwrite('randomBumpsTrack.csv', distElevationRandomBumpsOutput);

%% Sawtooth Track
% % Uncomment this section to generate a sawtooth track
% sawtoothFrequency = 10; % Number of sawtooth cycles over the total distance
% elevationSawtooth = (hillAmplitude * sawtooth(2 * pi * sawtoothFrequency * (distance / totalDist)))';
% distElevationSawtoothOutput = [distance', elevationSawtooth];
% csvwrite('sawtoothTrack.csv', distElevationSawtoothOutput);
