import pandas as pd
import matplotlib.pyplot as plt

# Load the CSV file
file_path = 'R1_R2_R3_BF_results_2.csv'
data = pd.read_csv(file_path)

# Extract unique values for the number of nodes to create separate plots
unique_nodes = data['Number_of_Nodes'].unique()

# Create subplots
fig, axes = plt.subplots(len(unique_nodes), 1, figsize=(12, 5 * len(unique_nodes)))

# If there's only one subplot, axes won't be an array, so we convert it to an array
if len(unique_nodes) == 1:
    axes = [axes]

# Loop through each unique number of nodes and plot
for i, node in enumerate(unique_nodes):
    node_data = data[data['Number_of_Nodes'] == node]
    
    axes[i].plot(node_data['Number_of_Sats'], node_data['BF1_CPU_time'], marker='o', label='Bruteforce CPU Time Without Reduction')
    axes[i].plot(node_data['Number_of_Sats'], node_data['R_BF_total_time'], marker='o', label='Total CPU Time After Reduction')
    
    axes[i].set_title(f'{node} Relay Nodes')
    axes[i].set_xlabel('Number of Satellites')
    axes[i].set_ylabel('CPU Time (s)')
    axes[i].legend()
    axes[i].grid(True)

# Adjust layout and show the plot
plt.tight_layout()
plt.show()
