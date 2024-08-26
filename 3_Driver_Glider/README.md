# Driver Glider Model

- This Simulink model includes a driver and a glider. The driver is a PID feedback controller that compares the vehicle's speed to the commanded speed from the drive cycle and outputs a tractive force command. This command is sent to the glider model, which subtracts all resistive forces (gradient force, aerodynamic drag, and rolling resistance) from the tractive force. The resulting net force accelerates or decelerates the vehicle.

- The glider represents the vehicle as a point mass and models vehicle motion by applying the net force. It also includes a section for analysis and results.

- To view or edit parameters, go to the 'Modeling' tab, click 'Model Explorer,' then navigate to Driver_Glider > 'Model Workspace' under the model hierarchy.
