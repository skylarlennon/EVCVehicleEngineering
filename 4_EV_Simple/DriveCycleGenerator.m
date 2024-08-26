%% Generating Drive Cycle Data
clc; clear; close all;

%Define segments: [initial_speed (mph), final_speed(mph), distance]
segments = [
    0, 50, 500;   % Accelerate from 0 to 50 m/s over 500m
    50, 50, 400;  % Maintain 50 m/s for 400m
    50, 40, 100;  % Decelerate from 50 to 40 m/s over 100m
    40, 40, 400;  % Maintain 40 m/s for 400m (1st turn)
    40, 40, 200;  % Maintain 40 m/s for 200m
    40, 40, 400;  % Maintain 40 m/s for 400m (2nd turn)
    40, 50, 100;  % Accelerate from 40 to 50 m/s over 100m
    50, 50, 800;  % Maintain 50 m/s for 800m
    50, 40, 100;  % Decelerate from 50 to 40 m/s over 100m
    40, 40, 400;  % Maintain 40 m/s for 400m (3rd turn)
    40, 40, 200;  % Maintain 40 m/s for 200m
    40, 40, 400   % Maintain 40 m/s for 400m (4th turn)
];

% segments = [
%     0, 20, 500;   % Accelerate from 0 to 50 m/s over 500m
%     20, 20, 400;  % Maintain 50 m/s for 400m
%     20, 10, 100;  % Decelerate from 50 to 40 m/s over 100m
%     10, 10, 400;  % Maintain 40 m/s for 400m (1st turn)
%     10, 10, 200;  % Maintain 40 m/s for 200m
%     10, 10, 400;  % Maintain 40 m/s for 400m (2nd turn)
%     10, 20, 100;  % Accelerate from 40 to 50 m/s over 100m
%     20, 20, 800;  % Maintain 50 m/s for 800m
%     20, 10, 100;  % Decelerate from 50 to 40 m/s over 100m
%     10, 10, 400;  % Maintain 40 m/s for 400m (3rd turn)
%     10, 10, 200;  % Maintain 40 m/s for 200m
%     10, 10, 400   % Maintain 40 m/s for 400m (4th turn)
% ];

% Set a fixed time step
fixed_time_step = 0.01; % Adjust this value based on your needs

% Initialize variables
current_time = 0;
time_speed_data = [];

% Loop through each segment
for i = 1:size(segments, 1)
    initial_speed = segments(i, 1);
    final_speed = segments(i, 2);
    distance = segments(i, 3);
    
    if initial_speed == final_speed
        % Constant speed segment
        segment_time = distance / initial_speed;
        num_points = ceil(segment_time / fixed_time_step);
        time_points = current_time + (0:num_points-1) * fixed_time_step;
        speed_points = repmat(initial_speed, size(time_points));
    else
        % Accelerating or decelerating segment
        % Calculate acceleration
        a = (final_speed^2 - initial_speed^2) / (2 * distance);
        segment_time = (final_speed - initial_speed) / a;
        num_points = ceil(segment_time / fixed_time_step);
        time_points = current_time + (0:num_points-1) * fixed_time_step;
        speed_points = initial_speed + a * (time_points - current_time);
    end
    
    % Append to data
    time_speed_data = [time_speed_data; [time_points', speed_points']];
    current_time = time_points(end) + fixed_time_step; % Update time for next segment
end

% Check for monotonicity by printing the time differences
timePoints = time_speed_data(:,1);

for i = 2:length(timePoints)
    timeDiff = timePoints(i) - timePoints(i-1);
    fprintf('Time difference between point %d and %d: %.6f seconds\n', i-1, i, timeDiff);
    if timeDiff <= 0
        fprintf('Warning: Time is not monotonically increasing at point %d!\n', i);
    end
end

% Export to spreadsheet
filename = 'time_speed_data.xlsx';
writematrix(time_speed_data, filename);

% Display message
disp(['Time-speed data exported to ', filename]);

% Plot the time-speed data
plot(time_speed_data(:,1), time_speed_data(:,2));
xlabel('Time (s)');
ylabel('Speed (m/s)');
title('Time-Speed Profile');
