function plotEffMap(filename,maxTorque,maxPower)
    % Step 1: Load the CSV file
    data = readmatrix(filename);
    
    % Step 2: Extract the relevant columns
    torque = data(:, 1);          
    speed = data(:, 2);            
    efficiency = data(:, 3); 
    
    % Step 3: Create a grid for contour plot
    [torqueGrid, speedGrid] = meshgrid(linspace(min(torque), max(torque), 100), ...
                                       linspace(min(speed), max(speed), 100));
    
    % Step 4: Interpolate efficiency values on the grid
    efficiencyGrid = griddata(torque, speed, efficiency, torqueGrid, speedGrid, 'linear');
    
    % Step 5: Plot the contour map
    contourf(torqueGrid, speedGrid, efficiencyGrid, 20); % 20 contour levels
    colorbarHandle = colorbar; % Show color bar and get the handle
    ylabel(colorbarHandle, 'Efficiency (%)'); % Add title to the colorbar
    xlabel('Torque');
    ylabel('Speed');

end