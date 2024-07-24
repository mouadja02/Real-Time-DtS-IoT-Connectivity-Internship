import dash
from dash import dcc, html
from dash.dependencies import Input, Output
import plotly
from plotly.graph_objs import Scatter3d


import pandas as pd


def process_data(filename):
  # Read CSV data
  data = pd.read_csv(filename)

  # Convert StartTime to datetime
  data['StartTime'] = pd.to_datetime(data['StartTime'], format='%d-%b-%Y %H:%M:%S')

  # Define orbital period and connectivity duration
  orbital_period = pd.Timedelta(seconds=5724)  # 1.59 hours
  connectivity_duration = pd.Timedelta(seconds=420)  # 7 minutes

  # Extract relevant nodes (IoTs and Satellites)
  iot_nodes = list(set(data['Target'][data['Target'].str.contains('IoT')]))

  # Initialize empty lists for edges and labels
  edges = []
  edge_labels = []

  # Loop through the data and identify connections
  for index, row in data.iterrows():
    source = row['Source']
    target = row['Target']
    start_time = row['StartTime']

    # Calculate edge labels (time difference)
    time_diff = start_time - data['StartTime'].min()
    edge_labels.append(str(time_diff))

    # Create edges
    edges.append((source, target))

  # Remove satellites (assuming you don't want them in the 3D graph)
  iot_nodes = [node for node in iot_nodes if not node.startswith('Satellite')]

  # Find minimum delays for each connection
  delays = {}
  for i in range(len(iot_nodes)):
    for j in range(i + 1, len(iot_nodes)):
      iot1, iot2 = iot_nodes[i], iot_nodes[j]
      min_delay = None
      for edge_idx in range(len(edges)):
        if (edges[edge_idx][0] == iot1 and edges[edge_idx][1] == iot2) or \
           (edges[edge_idx][0] == iot2 and edges[edge_idx][1] == iot1):
          current_delay = pd.to_timedelta(edge_labels[edge_idx])
          if min_delay is None or current_delay < min_delay:
            min_delay = current_delay
      delays[(iot1, iot2)] = min_delay

  # Update edges and labels with minimum delays
  updated_edges = []
  updated_labels = []
  for edge in edges:
    source, target = edge
    if (source, target) in delays:
      delay = delays[(source, target)]
      updated_edges.append((source, target))
      updated_labels.append(str(delay))

  return iot_nodes, updated_edges, updated_labels


# Example usage
nodes, edges, labels = process_data("./Final works/access_intervals7.csv")

# Define initial node positions (adjust as needed)
node_positions = {
    "MainIoT": [0, 1, 0],
    "Node 1": [1, 1, 0],
    "Node 2": [0.5, 0.5, 1],
    "GS": [0.5, 0.5, 0],
}

# Create initial 3D plot data for nodes
node_data = [Scatter3d(
    x=[node_positions[node][0] for node in nodes],
    y=[node_positions[node][1] for node in nodes],
    z=[node_positions[node][2] for node in nodes],
    text=nodes,
    mode='markers',
    marker=dict(size=10, color='blue')
)]

# Create empty initial data for edges (will be updated later)
edge_data = []

# Define layout for the 3D scene
layout = Scatter3d(
    scene=dict(
        xaxis=dict(title='X'),
        yaxis=dict(title='Y'),
        zaxis=dict(title='Z'),
        showbackground=True,
        backgroundcolor='white'
    )
)

# Define the Dash app
app = dash.Dash(__name__)

# Define app layout with dropdown menus for source and target selection, and the 3D plot
app.layout = html.Div([
    dcc.Dropdown(
        id='source-dropdown',
        options=[{'label': node, 'value': node} for node in nodes],
        value='MainIoT'  # Set initial selected source
    ),
    dcc.Dropdown(
        id='target-dropdown',
        options=[{'label': node, 'value': node} for node in nodes],
        value='GS'  # Set initial selected target
    ),
    dcc.Graph(id='3d-graph', figure=dict(data=node_data + edge_data, layout=layout))
])


@app.callback(
    Output(component_id='3d-graph', component_property='figure'),
    [Input(component_id='source-dropdown', component_property='value'),
     Input(component_id='target-dropdown', component_property='value')]
)
def update_graph(selected_source, selected_target):
    # Update edge data based on selected source and target
    updated_edge_data = []
    for edge, label in zip(edges, labels):
        source, target = edge
            # ... (Code for color assignment remains the same)
            # Create Scatter3d object (instead of Line3d) for the edge with a line mode
        updated_edge_data.append(Scatter3d(
        x=[node_positions[source][0], node_positions[target][0]],
        y=[node_positions[source][1], node_positions[target][1]],
        z=[node_positions[source][2], node_positions[target][2]],
        mode='lines',  # Set mode to 'lines'
        line=dict(color=color, width=2)
    ))
    
    # Return updated figure with both node and edge data
    return dict(data=node_data + updated_edge_data, layout=layout)


if __name__ == '__main__':
    app.run_server(debug=True)
