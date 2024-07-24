import pandas as pd
from datetime import datetime, timedelta

# Load the CSV file
file_path = 'access_intervals.csv'
data = pd.read_csv(file_path)

# Define constants
connectivity_duration = 420  # duration of each connection in seconds
orbital_period = 5724  # time until the next connectivity in seconds

# Define nodes
nodes = pd.unique(data[['Source', 'Target']].values.ravel('K'))
N1 = 'N1'
N20 = 'N20'

# Function to calculate delay between nodes
def calculate_delay(x, y, connectivity_duration, orbital_period):
    if x > y:
        if x < y + timedelta(seconds=connectivity_duration):
            return x
        else:
            return y + timedelta(seconds=orbital_period)
    else:
        return y

# Function to get possible next steps
def get_next_steps(current_node, path):
    steps = []
    for i in range(len(data)):
        if data['Source'][i] == current_node and data['Target'][i] not in path:
            steps.append((data['Target'][i], datetime.strptime(data['StartTime'][i], '%d-%b-%Y %H:%M:%S')))
    return steps

# Initialize variables to store paths and delays
all_paths = []
all_delays = []

# Helper function to explore all paths
def explore_paths(current_node, current_path, current_delay):
    global all_delays,all_paths
    if current_node == N20:
        all_paths.append(current_path[:])
        all_delays.append(current_delay)
        return
    
    next_steps = get_next_steps(current_node, current_path)
    for next_node, start_time in next_steps:
        new_delay = calculate_delay(current_delay, start_time, connectivity_duration, orbital_period)
        explore_paths(next_node, current_path + [next_node], new_delay)

# Start exploring paths from N1
explore_paths(N1, [N1], datetime.min)

# Find the path with the minimum delay
min_delay_index = all_delays.index(min(all_delays))
best_path = all_paths[min_delay_index]
min_delay = all_delays[min_delay_index]

# Display the best path and its delay
print('Best Path:')
print(best_path)
print('Minimum Delay:')
print(min_delay)
