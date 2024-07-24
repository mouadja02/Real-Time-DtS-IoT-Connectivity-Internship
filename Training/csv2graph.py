import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# Load your data
data = pd.read_csv('access_intervals.csv')

# Convert 'StartTime' to datetime for easier comparison
data['StartTime'] = pd.to_datetime(data['StartTime'], format='%d-%b-%Y %H:%M:%S')
data['EndTime'] = pd.to_datetime(data['EndTime'], format='%d-%b-%Y %H:%M:%S')

# Function to add connections to the graph by alternating between source and target
def add_connections(current_level_nodes, source_to_target):
    next_level_nodes = []
    for node in current_level_nodes:
        if source_to_target:
            # Current node is source, find targets
            connections = data[data['Source'] == node]
            next_level_nodes.extend(connections['Target'].unique())
        else:
            # Current node is target, find sources
            connections = data[data['Target'] == node]
            next_level_nodes.extend(connections['Source'].unique())
        
        # Add edges to the graph
        for _, row in connections.iterrows():
            if source_to_target:
                G_dynamic.add_edge(row['Source'], row['Target'], time=row['StartTime'])
            else:
                G_dynamic.add_edge(row['Target'], row['Source'], time=row['StartTime'])
    return list(set(next_level_nodes))

# Filter the dataset to find all satellites connected to 'IoT Device Main'
level_0 = data[data['Target'] == 'MainIoT']


# Function to find subsequent connections from a given list of satellites, starting after their respective end times
def find_subsequent_connections(level_df, source_col, target_col):
    next_level = pd.DataFrame()
    for index, row in level_df.iterrows():
        subsequent_connections = data[(data['Source'] == row[source_col]) & (data['StartTime'] > row['EndTime'])]
        next_level = pd.concat([next_level, subsequent_connections], ignore_index=True)
    return next_level

# Find Level 1 connections: IoT devices connected to Level 0 satellites
level_1 = find_subsequent_connections(level_0, 'Source', 'Target')


# Filter out 'Ground Station 1' as it's a terminal node and doesn't connect further in our analysis
level_1_iots = level_1[level_1['Target'].str.contains('Node')]

print(level_1)

# Find Level 2 connections: Satellites connected to Level 1 IoT devices
level_2 = find_subsequent_connections(level_1_iots, 'Target', 'Source')


def format_datetime(row):
    return mdates.date2num(pd.to_datetime(row, format='%d-%b-%Y %H:%M:%S'))

level_0['StartTimeNum'] = level_0['StartTime'].apply(format_datetime)
level_0['EndTimeNum'] = level_0['EndTime'].apply(format_datetime)
level_1['StartTimeNum'] = level_1['StartTime'].apply(format_datetime)

# Redefine graph with these corrected datetime values
G_simple = nx.DiGraph()

# Level 0 nodes
for index, row in level_0.iterrows():
    G_simple.add_node(row['Source'], level=1, pos=(row['EndTimeNum'], 1))
    G_simple.add_node(row['Target'], level=0, pos=(row['StartTimeNum'], 2))
    G_simple.add_edge(row['Target'], row['Source'])

# Level 1 nodes
for index, row in level_1.iterrows():
    level = 2 if 'IoT Device' in row['Target'] else 0
    G_simple.add_node(row['Target'], level=level, pos=(row['StartTimeNum'], level))
    G_simple.add_edge(row['Source'], row['Target'])

# Plotting the graph
fig, ax = plt.subplots(figsize=(12, 6))
pos = {node: (x, -y) for node, (x, y) in nx.get_node_attributes(G_simple, 'pos').items()}
nx.draw(G_simple, pos, with_labels=True, node_size=3000, node_color='lightblue', font_size=9, ax=ax)

# Format the x-axis to show time
ax.xaxis.set_major_locator(mdates.MinuteLocator(interval=1))
ax.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
plt.gcf().autofmt_xdate()  # Rotate date labels to fit
plt.title('IoT-Satellite Network Connections')
plt.grid(True)
plt.show()



"""
# Load your data
data = pd.read_csv('access_intervals.csv')

# Convert 'StartTime' to datetime for easier comparison
data['StartTime'] = pd.to_datetime(data['StartTime'], format='%d-%b-%Y %H:%M:%S')

# Function to add connections to the graph by alternating between source and target
def add_connections(current_level_nodes, source_to_target):
    next_level_nodes = []
    for node in current_level_nodes:
        if source_to_target:
            # Current node is source, find targets
            connections = data[data['Source'] == node]
            next_level_nodes.extend(connections['Target'].unique())
        else:
            # Current node is target, find sources
            connections = data[data['Target'] == node]
            next_level_nodes.extend(connections['Source'].unique())
        
        # Add edges to the graph
        for _, row in connections.iterrows():
            if source_to_target:
                G_dynamic.add_edge(row['Source'], row['Target'], time=row['StartTime'])
            else:
                G_dynamic.add_edge(row['Target'], row['Source'], time=row['StartTime'])
    return list(set(next_level_nodes))

# Initialize an empty graph
G_dynamic = nx.DiGraph()

# Start with IoT Device Main at Level 0
level_nodes = ['IoT Device Main']
source_to_target = True  # Direction of connection: True if source to target, False if target to source

# Iteratively add levels until no new nodes are found
for level in range(6):  # Assuming a max depth of 6 levels for visualization
    new_nodes = add_connections(level_nodes, source_to_target)
    if not new_nodes:
        break  # Stop if no more connections can be made
    level_nodes = new_nodes
    source_to_target = not source_to_target  # Alternate direction

# Setting node positions based on their levels
pos = {node: (level, -idx) for idx, node in enumerate(G_dynamic.nodes())}
fig, ax = plt.subplots(figsize=(12, 8))
nx.draw(G_dynamic, pos, with_labels=True, node_size=3000, node_color='lightblue', font_size=9, ax=ax)
plt.title('Dynamic Level IoT-Satellite Network Connections')
plt.grid(True)
plt.show()
"""