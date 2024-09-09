%% Generating Custom Drive Cycle Data

%%JUST MAKE IT SO PEOPLE HAVE TO DRAW ON A MAP BASED ON THEIR MAX SPEEDS

clc; clear; close all;

%% Load Track Data
% Assumes input data formatted with first column accumulated distance 
% along the track, and the second column is the relative elevation at 
% that distance. Also, assumed is only a single lap of data is present. 
% This data was generated from 'linearizeTrack.m'.
LinearizedTrack = readmatrix('sonomaLinearized.csv');
rawDistance = LinearizedTrack(:,1);
rawElevation = LinearizedTrack(:,2);
trackLength = rawDistance(end); 

%% Expand Track Data for Number of Laps in Race
numLaps = 10;
cumulativeDistance = [];
cumulativeElevation = [];
for i = 1:numLaps
    % Add the track length to the raw distances to get the cumulative distance for each lap
    lapDistance = rawDistance + (i-1) * trackLength;
    
    % Append to cumulative arrays
    cumulativeDistance = [cumulativeDistance; lapDistance];
    cumulativeElevation = [cumulativeElevation; rawElevation];
end
% Remove duplicate values
[cumulativeDistance,uniqueIdx] = unique(cumulativeDistance);
cumulativeElevation = cumulativeElevation(uniqueIdx);

%% Determine Track's Road Gradient
theta = zeros(length(cumulativeElevation),1);
for i=2:length(cumulativeElevation)
    elevation_change = cumulativeElevation(i) - cumulativeElevation(i-1);
    distance_traveled = cumulativeDistance(i) - cumulativeDistance(i-1);
    theta(i-1) = real(asin(elevation_change/distance_traveled));
end
theta(i) = theta(i-1);

%% Determining the race strategy
% Define track segments and how they will be driven using the following
% convention:
%       [start_speed, end_speed, distance;...]
% Constant acceleration is assumed. Total distance traveled is checked
% against the track size from the input .csv file.

DC_distance_speed_data = readmatrix('speed_vs_distance.txt');
DC_distance = DC_distance_speed_data(:,1);
DC_speed = DC_distance_speed_data(:,2);

%Check for matching track lengths
if DC_distance(end) ~= trackLength
    error('Defined track length does not match input file track length')
end

%LEFT OFFFFF HEREEEEEEEEE

% % Initialize variables for generating custom drive cycle data
% current_time = 0;
% distance_covered = 0;
% fixed_time_step = 0.1;
% time_distance_speed_data = [];
% 
% % Loop through each segment
% for i = 1:size(segments, 1)
%     initial_speed = segments(i, 1);
%     final_speed = segments(i, 2);
%     segment_distance = segments(i, 3);
%     
%     % Calculate the distance increments for this segment
%     if initial_speed == final_speed % Constant speed segment
%         % Number of points based on fixed step in distance
%         num_points = ceil(segment_distance / (initial_speed * fixed_time_step));
%         distances = linspace(distance_covered, distance_covered + segment_distance, num_points)';
%         speeds = ones(num_points,1)*initial_speed;
%         seg_time = fixed_time_step*num_points;
%         segment_times = linspace(current_time,current_time+seg_time,num_points)';
%     else % Accelerating or decelerating segment
%         % Acceleration a = (v_f^2 - v_i^2) / (2 * d)
%         a = (final_speed^2 - initial_speed^2) / (2 * segment_distance);
%         % Time to cover the segment
%         segment_time = (final_speed - initial_speed) / a;
%         % Number of points based on fixed time step
%         num_points = ceil(segment_time / fixed_time_step);
%         
%         % Calculate distances and speeds incrementally
%         times = linspace(0,segment_time, num_points);
%         speeds = (initial_speed + a * times)';
%         segment_times = linspace(current_time,current_time+segment_time,num_points)';
%         distances = (distance_covered + initial_speed * times + 0.5 * a * times.^2)';
%     end
%     
%     % Append to data
%     time_distance_speed_data = [time_distance_speed_data; [segment_times, distances, speeds]];
%     distance_covered = distances(end); % Update distance for the next segment
%     current_time = segment_times(end); % Update current time for next segment
% 
% end
% time = time_distance_speed_data(:,1);
% distance = time_distance_speed_data(:,2);
% speed = time_distance_speed_data(:,3);
% 
% disp(['Total Race Time = ', num2str(current_time/60), ' mins']);
% 
%% Interpolate custom drive cycle data to match dimensions of track data
interpolatedTime = linspace(0,time(end),length(cumulativeDistance))';
interpolatedSpeed = zeros(length(cumulativeDistance),1);

%Iterate through the cumulativeDistance finding closest corresponding
%speed from the time_distance_speed_data
for i = 1:length(cumulativeDistance)
    [~,closestIndex] = min(abs(time_distance_speed_data(:,2) - cumulativeDistance(i)));
    interpolatedSpeed(i) = time_distance_speed_data(closestIndex,3);
end

%% Concatinate & Export Data
DriveCycleData = [interpolatedTime,interpolatedSpeed,cumulativeElevation,cumulativeDistance,theta];

% Export to spreadsheet
filename = 'time_speed_elevation_distance_theta_data.xlsx';
writematrix(DriveCycleData, filename);

% Display message
disp(['Time-Speed-Elevation-Distance data exported to ', filename]);

%% Plot Results
% Elevation vs Distance and Speed vs Distance
figure(1)
hold on
yyaxis left
plot(cumulativeDistance,cumulativeElevation)
ylabel('Relative Elevation (m)')
yyaxis right
plot(distance,speed)
ylabel('Speed (m/s)')
xlabel('Distance Along Track (m)')
hold off
grid on

% Elevation vs Time and Speed vs Time
figure(2)
hold on
yyaxis left
plot(interpolatedTime,cumulativeElevation)
ylabel('Relative Elevation (m)')
yyaxis right
plot(interpolatedTime,interpolatedSpeed)
ylabel('Speed (m/s)')
xlabel('Time (s)')
hold off
grid on


