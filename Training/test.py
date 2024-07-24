import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import networkx as nx
import datetime as dt

# Load CSV data
file_path = './Final works/access_intervals3.csv'
df = pd.read_csv(file_path, parse_dates=['StartTime', 'EndTime'])

# Create a sorted list of all nodes (IoT devices and satellites)
nodes = sorted(set(df['Source']).union(df['Target']))

# Map each node to a unique vertical position
node_positions = {node: index for index, node in enumerate(nodes)}

# Plot configuration
fig, ax = plt.subplots(figsize=(12, 8))

# Create a dictionary to store end times of current connections for each satellite
end_times = {}

# Plot each connec        tivity interval as a line
for _, row in df.iterrows():
    start, end = row['StartTime'], row['EndTime']
    source, target = row['Source'], row['Target']
    
    # Check if the satellite is already connected to another node
    if source in end_times and start < end_times[source]:
        # Flip the line if there is an overlapping connection
        source_pos, target_pos = node_positions[target], node_positions[source]
    else:
        source_pos, target_pos = node_positions[source], node_positions[target]
    
    # Update the end time of the current connection for the satellite
    end_times[source] = end
    
    ax.plot([start, end], [source_pos, target_pos], marker='o', linestyle='-', linewidth=2)

# Set y-ticks to node names
ax.set_yticks(range(len(nodes)))
ax.set_yticklabels(nodes)

# Configure x-axis to show time labels
ax.xaxis_date()
ax.xaxis.set_major_locator(mdates.MinuteLocator(interval=5))
ax.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M"))

# Title and labels
ax.set_title('IoT-Satellite Connectivity Intervals')
ax.set_xlabel('Time')
ax.set_ylabel('Nodes (Satellites/IoT Devices)')

# Rotate x-axis labels for better readability
plt.xticks(rotation=45)

plt.grid(True)
plt.tight_layout()
plt.show()
