import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# TODO: ADD CLEAR AND ZOOM FUNCTIONALITIES

df = pd.read_csv('sonomaLinearized.csv', header=None, names=['distance', 'elevation'])
distance = df['distance'].values
elevation = df['elevation'].values

# Store speed points
speed_points = []
dragging_point_idx = None  # To track which point is being dragged

# Set min and max speed for the speed y-axis
MIN_SPEED = 0   #m/s
MAX_SPEED = 15  #m/s

# Create figure and plot
fig, ax1 = plt.subplots()
ax1.grid(True, which='both', axis='both')
ax1.plot(distance, elevation, '-b', label='Elevation')
# ax1.set_title('Custom Drive Cycle Generator', fontsize=14)
ax1.set_xlabel('Distance (m)')
ax1.set_ylabel('Elevation (m)', color='b')
ax1.tick_params(axis='y', labelcolor='b')

# Create a twin axis for speed
ax2 = ax1.twinx()
ax2.set_ylabel('Speed (m/s)', color='r')
ax2.tick_params(axis='y', labelcolor='r')
ax2.set_ylim(MIN_SPEED, MAX_SPEED)  # Set fixed y-axis limits for speed

point_plot, = ax2.plot([], [], 'ro', markerfacecolor='r', markersize=4)
line_plot, = ax2.plot([], [], '-r')  # Line between points

# Display labels under the title
race_time_label = ax1.text(0.5, 1.05, '', ha='center', va='center', transform=ax1.transAxes, fontsize=10, color='black')
max_acceleration_label = ax1.text(0.5, 1.02, '', ha='center', va='center', transform=ax1.transAxes, fontsize=10, color='black')

# Add point with click
def on_click(event):
    global dragging_point_idx
    if event.inaxes != ax1 and event.inaxes != ax2:
        return
    
    if event.button == 1:  # Left-click to add or start dragging
        dragging_point_idx = get_closest_point_idx(event.xdata, event.ydata)
        if dragging_point_idx is None:  # No nearby point, add new point
            x, y = event.xdata, np.clip(event.ydata, MIN_SPEED, MAX_SPEED)
            speed_points.append([x, y])
            update_plot()
    elif event.button == 3:  # Right-click to remove nearest point
        remove_point(event)

# Handle mouse motion (dragging)
def on_motion(event):
    global dragging_point_idx
    if dragging_point_idx is not None and (event.inaxes == ax1 or event.inaxes == ax2):
        # Update the position of the dragged point, clamping y to the speed range
        speed_points[dragging_point_idx] = [event.xdata, np.clip(event.ydata, MIN_SPEED, MAX_SPEED)]
        update_plot()

# Handle mouse release (stop dragging)
def on_release(event):
    global dragging_point_idx
    dragging_point_idx = None  # Stop dragging

# Update plot with new points and lines between them
def update_plot():
    speed_points.sort(key=lambda p: p[0])  # Sort by distance (x-values)
    x_vals = [p[0] for p in speed_points]
    y_vals = [p[1] for p in speed_points]
    
    # Update the points on the plot
    point_plot.set_data(x_vals, y_vals)
    
    # Draw lines between the points
    if len(speed_points) > 1:
        line_plot.set_data(x_vals, y_vals)
        display_race_time_and_acceleration()
    else:
        line_plot.set_data([], [])
    
    plt.draw()

# Calculate and display the race time and max acceleration
def display_race_time_and_acceleration():
    total_time = 0
    max_acceleration = 0
    
    if len(speed_points) > 1:
        for i in range(1, len(speed_points)):
            initial_speed = speed_points[i-1][1]  # Previous point's speed
            final_speed = speed_points[i][1]      # Current point's speed
            distance_traveled = speed_points[i][0] - speed_points[i-1][0]  # Distance between points
            
            # Time = distance / average speed
            avg_speed = (initial_speed + final_speed) / 2
            if avg_speed != 0:  # Avoid division by zero
                time = distance_traveled / avg_speed
                total_time += time
            
            # Acceleration = (final speed - initial speed) / time
            if time != 0:  # Avoid division by zero
                acceleration = (final_speed - initial_speed) / time
                max_acceleration = max(max_acceleration, abs(acceleration))
    
    # Display total race time and max acceleration
    race_time_label.set_text(f'Total Race Time: {total_time:.2f} s')
    max_acceleration_label.set_text(f'Max Acceleration: {max_acceleration:.2f} m/s²')

# Remove the point closest to the click
def remove_point(event):
    closest_idx = get_closest_point_idx(event.xdata, event.ydata)
    if closest_idx is not None:
        del speed_points[closest_idx]
        update_plot()

# Get the index of the point closest to (x, y), or None if too far
def get_closest_point_idx(x_click, y_click, threshold=2.5):
    if not speed_points:
        return None
    distances = [(x_click - p[0]) ** 2 + (y_click - p[1]) ** 2 for p in speed_points]
    closest_idx = np.argmin(distances)
    if distances[closest_idx] < threshold ** 2:  # Increase threshold for detecting points
        return closest_idx
    return None

# Save speed vs distance points to a CSV file with initial speed, final speed, and distance between points
def save_data(event):
    if len(speed_points) > 1:
        # Create lists for initial speed, final speed, and distance between points
        initial_speeds = []
        final_speeds = []
        distances = []
        
        # Calculate the values
        for i in range(1, len(speed_points)):
            initial_speed = speed_points[i-1][1]  # Previous point's speed
            final_speed = speed_points[i][1]      # Current point's speed
            distance_traveled = speed_points[i][0] - speed_points[i-1][0]  # Distance between points
            
            initial_speeds.append(initial_speed)
            final_speeds.append(final_speed)
            distances.append(distance_traveled)
        
        # Create a DataFrame and save it to a CSV file
        df = pd.DataFrame({
            'Initial Speed (m/s)': initial_speeds,
            'Final Speed (m/s)': final_speeds,
            'Distance Traveled (m)': distances
        })
        df.to_csv('speed_vs_distance.csv', index=False)
        print('Speed vs Distance data saved to speed_vs_distance.csv')

# Clear all points
def clear_points(event):
    global speed_points
    speed_points = []
    update_plot()
    print('All points cleared')

# New function to load data from CSV
def load_data(event):
    global speed_points
    try:
        df = pd.read_csv('speed_vs_distance.csv')
        speed_points = []
        cumulative_distance = 0
        for _, row in df.iterrows():
            initial_speed = row['Initial Speed (m/s)']
            final_speed = row['Final Speed (m/s)']
            distance = row['Distance Traveled (m)']
            
            speed_points.append([cumulative_distance, initial_speed])
            cumulative_distance += distance
            speed_points.append([cumulative_distance, final_speed])
        
        update_plot()
        print('Data loaded from speed_vs_distance.csv')
    except FileNotFoundError:
        print('Error: speed_vs_distance.csv not found')
    except Exception as e:
        print(f'Error loading data: {e}')

# Connect the click, motion, and release events
fig.canvas.mpl_connect('button_press_event', on_click)
fig.canvas.mpl_connect('motion_notify_event', on_motion)
fig.canvas.mpl_connect('button_release_event', on_release)

# Adjust the figure size to accommodate the buttons
fig.set_size_inches(10, 6)  # Adjust as needed

# Add a clear button on the left side
ax_clear_button = plt.axes([0.05, 0.02, 0.1, 0.04])
button_clear = plt.Button(ax_clear_button, 'Clear Points')
button_clear.on_clicked(clear_points)

# Add a save button on the right side
ax_save_button = plt.axes([0.85, 0.02, 0.1, 0.04])
button_save = plt.Button(ax_save_button, 'Save Data')
button_save.on_clicked(save_data)

# Add a load button in the middle
ax_load_button = plt.axes([0.45, 0.02, 0.1, 0.04])
button_load = plt.Button(ax_load_button, 'Load Data')
button_load.on_clicked(load_data)

plt.show()
