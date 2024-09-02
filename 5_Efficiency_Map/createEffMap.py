# Import necessary libraries
import os
import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Define function to load .dat files
def load_dat_files():
    data_list = []
    for file in os.listdir('.'):
        if file.endswith('.dat'):
            data = pd.read_csv(file, delim_whitespace=True, header=None).values
            data_list.append(data)
    return data_list

# Load and concatenate data
def concatenate_data(data_list):
    concatenated_data = np.vstack(data_list)
    return concatenated_data

def normalize_data(data, TorqueMax, RADPS_Max):
    RADPS = data[:, 0]
    TORQUE = data[:, 1]
    z = data[:, 2]

    # Normalizing RADPS and Torque
    RADPS_NORM = (RADPS - RADPS.min()) / (RADPS.max() - RADPS.min()) * RADPS_Max
    Torque_norm = (TORQUE - TORQUE.min()) / (TORQUE.max() - TORQUE.min()) * TorqueMax

    # Mirroring Torque about the middle of the Torque-axis
    Torque_mid = TorqueMax / 2
    Torque_mirrored = Torque_mid - (Torque_norm - Torque_mid)

    normalized_data = np.column_stack((RADPS_NORM, Torque_mirrored, z))
    return normalized_data


# Create custom polynomial features for IPM
def create_ipm_polynomial_features(X):
    RPM = X[:, 0]
    Torque = X[:, 1]
    
    features = np.column_stack([
        Torque,          # a*Torque
        Torque**2,       # b*Torque^2
        RPM,             # c*RPM
        RPM * Torque**2, # d*RPM*Torque^2
        RPM**2,          # e*RPM^2
        RPM**2 * Torque**2, # f*RPM^2*Torque^2
        RPM**3           # g*RPM^3
    ])
    
    return features

# Create custom polynomial features for SPM
def create_spm_polynomial_features(X):
    RPM = X[:, 0]
    Torque = X[:, 1]
    
    features = np.column_stack([
        Torque**2,       # a*Torque^2
        RPM,             # b*RPM
        RPM**2,          # c*RPM^2
        RPM**2 * Torque**2, # d*RPM^2*Torque^2
        RPM**3           # e*RPM^3
    ])
    
    return features

# Create custom polynomial features for IM
def create_im_polynomial_features(X):
    RPM = X[:, 0]
    Torque = X[:, 1]
    
    features = np.column_stack([
        np.ones(len(RPM)), # a
        Torque,            # b*Torque
        Torque**2,         # c*Torque^2
        RPM * Torque**2,   # d*RPM*Torque^2
        RPM**2,            # e*RPM^2
        RPM**2 * Torque,   # f*RPM^2*Torque
        RPM**2 * Torque**2, # g*RPM^2*Torque^2
        RPM**3             # h*RPM^3
    ])
    
    return features

# Perform polynomial regression
def perform_polynomial_regression(data, motor_type):
    X = data[:, :2]  # Using normalized RPM and Torque as predictors
    y = data[:, 2]   # z as the target

    # Create custom polynomial features based on motor type
    if motor_type == 'IPM':
        X_poly = create_ipm_polynomial_features(X)
    elif motor_type == 'SPM':
        X_poly = create_spm_polynomial_features(X)
    elif motor_type == 'IM':
        X_poly = create_im_polynomial_features(X)
    
    # Create the regression model
    linear_regression = LinearRegression()
    model = linear_regression.fit(X_poly, y)

    return model

# Save polynomial regression equation to file
def save_polynomial_regression_equation(model, motor_type, TorqueMax, RADPS_Max):
    coeffs = model.coef_
    intercept = model.intercept_

    terms = []
    if motor_type == 'IPM':
        terms = [
            ("Torque", coeffs[0]),
            ("Torque^2", coeffs[1]),
            ("RADPS", coeffs[2]),
            ("RADPS*Torque^2", coeffs[3]),
            ("RADPS^2", coeffs[4]),
            ("RADPS^2*Torque^2", coeffs[5]),
            ("RADPS^3", coeffs[6])
        ]
    elif motor_type == 'SPM':
        terms = [
            ("Torque^2", coeffs[0]),
            ("RADPS", coeffs[1]),
            ("RADPS^2", coeffs[2]),
            ("RADPS^2*Torque^2", coeffs[3]),
            ("RADPS^3", coeffs[4])
        ]
    elif motor_type == 'IM':
        terms = [
            ("1", coeffs[0]),
            ("Torque", coeffs[1]),
            ("Torque^2", coeffs[2]),
            ("RADPS*Torque^2", coeffs[3]),
            ("RADPS^2", coeffs[4]),
            ("RADPS^2*Torque", coeffs[5]),
            ("RADPS^2*Torque^2", coeffs[6]),
            ("RADPS^3", coeffs[7])
        ]
    
    filename = f"{motor_type}_Torque{TorqueMax}_RADPS{RADPS_Max}.txt"
    with open(filename, 'w') as f:
        f.write("Term\t\t\tCoefficient\n")
        for term, coeff in terms:
            f.write(f"{term}:\t\t\t{coeff:.16f}\n")
        f.write(f"Intercept:\t\t\t{intercept:.16f}\n")
    print(f"Polynomial regression equation saved to {filename}")

# Plot 3D data and regression plane
def plot_3d_data_and_regression(data, model, motor_type, max_torque=250, max_radps=500):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')

    # Scatter plot of the data points
    ax.scatter(data[:, 0], data[:, 1], data[:, 2], c='r', marker='o')

    # Create a meshgrid for plotting the regression surface
    RADPS = np.linspace(0, max_radps, 100)
    Torque = np.linspace(0, max_torque, 100)
    RADPS, Torque = np.meshgrid(RADPS, Torque)
    
    # Flatten the meshgrid and predict z values
    RADPS_Torque = np.column_stack([RADPS.ravel(), Torque.ravel()])
    if motor_type == 'IPM':
        RADPS_Torque_poly = create_ipm_polynomial_features(RADPS_Torque)
    elif motor_type == 'SPM':
        RADPS_Torque_poly = create_spm_polynomial_features(RADPS_Torque)
    elif motor_type == 'IM':
        RADPS_Torque_poly = create_im_polynomial_features(RADPS_Torque)
    
    efficiency = model.predict(RADPS_Torque_poly).reshape(RADPS.shape)

    # Plot the regression surface
    ax.plot_surface(RADPS, Torque, efficiency, alpha=0.5)

    ax.set_xlabel('RADPS')
    ax.set_ylabel('Torque')
    ax.set_zlabel('Efficiency')

    plt.show()

# Function to generate and save CSV data using the regression model
def generate_csv_from_model(model, motor_type, max_torque=250, max_radps=500, filename='model_generated_data.csv', num_samples=1000):
    # Generate a range of RPM (x) and Torque (y) values
    RADPS = np.linspace(0, max_radps, int(np.sqrt(num_samples)))  # x
    Torque = np.linspace(0, max_torque, int(np.sqrt(num_samples)))  # y
    RADPS, Torque = np.meshgrid(RADPS, Torque)

    # Flatten the RADPS and Torque arrays to create the input feature array
    RADPS_Torque = np.column_stack([RADPS.ravel(), Torque.ravel()])

    # Generate polynomial features based on motor type
    if motor_type == 'IPM':
        RADPS_Torque_poly = create_ipm_polynomial_features(RADPS_Torque)
    elif motor_type == 'SPM':
        RADPS_Torque_poly = create_spm_polynomial_features(RADPS_Torque)
    elif motor_type == 'IM':
        RADPS_Torque_poly = create_im_polynomial_features(RADPS_Torque)

    # Predict the z (efficiency) values using the model
    Efficiency = model.predict(RADPS_Torque_poly)

    # Combine RADPS, Torque, and Efficiency into a DataFrame
    data = pd.DataFrame({
        'RADPS': RADPS.ravel(),
        'Torque': Torque.ravel(),
        'Efficiency': Efficiency
    })

    # Save to CSV
    data.to_csv(filename, index=False)
    print(f"Generated data saved to {filename}")


# Main script
if __name__ == "__main__":

    # Input parameter values
    num_samples = 500
    max_torque = 250
    max_radps = 6500/60*2*3.14159265
    motor_type = 'IPM'
    outputFileName = 'TorqueSpeedEfficiency.csv'

    # Step 1: Load .dat files
    data_list = load_dat_files()

    # Step 2: Concatenate data
    concatenated_data = concatenate_data(data_list)

    # Step 3: Normalize data
    normalized_data = normalize_data(concatenated_data, max_torque, max_radps)

    # Step 4: Perform polynomial regression
    model = perform_polynomial_regression(normalized_data, motor_type)

    # Step 5: Save polynomial regression equation to file
    save_polynomial_regression_equation(model, motor_type, max_torque, max_radps)

    # Step 6: Plot 3D data and regression surface
    plot_3d_data_and_regression(normalized_data, model, motor_type, max_torque, max_radps)

    # Step 7: Save torque, speed, efficiency data to a csv file
    generate_csv_from_model(model,motor_type,max_torque,max_radps,outputFileName,num_samples)
