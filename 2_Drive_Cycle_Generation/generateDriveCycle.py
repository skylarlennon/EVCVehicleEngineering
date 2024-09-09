import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

df = pd.read_csv('sonomaLinearized.csv', header=None, names=['distance', 'elevation'])
distance = df['distance'].values
elevation = df['elevation'].values

# Store speed points
speed_points = []
dragging_point_idx = None  # To track which point is being dragged

# Create figure and plot
fig, ax = plt.subplots()
ax.plot(distance, elevation, '-b', label='Elevation')
ax.set_xlabel('Distance (m)')
ax.set_ylabel('Elevation (m)')
point_plot, = ax.plot([], [], 'ro', markerfacecolor='r', markersize=8)
line_plot, = ax.plot([], [], '-r')  # Line between points

# Add point with click
def on_click(event):
    global dragging_point_idx
    if event.inaxes != ax:
        return
    
    if event.button == 1:  # Left-click to add or start dragging
        dragging_point_idx = get_closest_point_idx(event.xdata, event.ydata)
        if dragging_point_idx is None:  # No nearby point, add new point
            x, y = event.xdata, event.ydata
            speed_points.append([x, y])
            update_plot()
    elif event.button == 3:  # Right-click to remove nearest point
        remove_point(event)

# Handle mouse motion (dragging)
def on_motion(event):
    global dragging_point_idx
    if dragging_point_idx is not None and event.inaxes == ax:
        # Update the position of the dragged point
        speed_points[dragging_point_idx] = [event.xdata, event.ydata]
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
    else:
        line_plot.set_data([], [])
    
    plt.draw()

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

# Save speed vs distance points
def save_data(event):
    if speed_points:
        np.savetxt('speed_vs_distance.txt', np.array(speed_points), fmt='%0.2f', delimiter=',')
        print('Speed vs Distance data saved')

# Connect the click, motion, and release events
fig.canvas.mpl_connect('button_press_event', on_click)
fig.canvas.mpl_connect('motion_notify_event', on_motion)
fig.canvas.mpl_connect('button_release_event', on_release)

# Add a save button
ax_save_button = plt.axes([0.7, 0.02, 0.1, 0.05])
button = plt.Button(ax_save_button, 'Save Data')
button.on_clicked(save_data)

plt.show()
