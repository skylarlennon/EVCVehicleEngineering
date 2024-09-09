function interactive_speed_plot()
    % Data for track elevation vs distance
    distance = linspace(0, 1000, 100); % Example distance (meters)
    elevation = sin(distance / 100) * 10; % Example elevation (meters)

    % Create figure and plot elevation
    figure('Name', 'Track Elevation vs Distance');
    plot(distance, elevation, '-b', 'DisplayName', 'Elevation');
    hold on;
    xlabel('Distance (m)');
    ylabel('Elevation (m)');
    
    % Initialize speed points
    speed_points = [];
    h_points = plot([], [], 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);

    % Set up UI for adding points with mouse clicks
    set(gca, 'ButtonDownFcn', @addPoint);

    % Create a Save button
    uicontrol('Style', 'pushbutton', 'String', 'Save Data', ...
              'Position', [20 20 100 30], 'Callback', @saveData);
    
    % Callbacks

    function addPoint(~, ~)
        % Get current point in the plot
        cp = get(gca, 'CurrentPoint');
        x = cp(1,1);  % X (distance)
        y = cp(1,2);  % Y (speed)

        % Add point if it's within the x-axis limits
        if x >= min(distance) && x <= max(distance)
            % Append the point to the speed_points array
            speed_points = [speed_points; x, y]; 
            updatePlot();
        end
    end

    function updatePlot()
        % Update the plot with new speed points
        set(h_points, 'XData', speed_points(:, 1), 'YData', speed_points(:, 2));
        drawnow;  % Ensure the plot refreshes
    end

    function saveData(~, ~)
        % Save the speed_points data to a .mat file
        if ~isempty(speed_points)
            uisave('speed_points', 'speed_vs_distance');
            disp('Speed vs Distance data saved');
        else
            disp('No data to save.');
        end
    end
end
