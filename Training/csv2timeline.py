import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import numpy as np
import plotly.graph_objects as go
from datetime import datetime

# Charger le fichier CSV
file_path = 'access_intervals.csv'  # Remplacez par le chemin réel vers votre fichier CSV
data = pd.read_csv(file_path)

# Convertir les chaînes de date/heure en objets datetime
data['StartTime'] = pd.to_datetime(data['StartTime'], format='%d-%b-%Y %H:%M:%S')
data['EndTime'] = pd.to_datetime(data['EndTime'], format='%d-%b-%Y %H:%M:%S')

# --- Plotly pour une visualisation interactive ---
fig = go.Figure()

# Ajouter les lignes de connexion
for i, row in data.iterrows():
    fig.add_trace(go.Scatter(
        x=[row['StartTime'], row['EndTime']],
        y=[i, i],
        mode="lines+markers+text",
        name=f"{row['Source']} to {row['Target']}",
        text=[f"{row['Source']}", f"{row['Target']}"],
        textposition="bottom center",
        hoverinfo='text',
        hovertext=f"Source: {row['Source']}<br>Target: {row['Target']}<br>Start: {row['StartTime']}<br>End: {row['EndTime']}<br>Duration: {row['Duration'] // 60}m {row['Duration'] % 60}s",
    ))

# Mettre à jour la mise en page
fig.update_layout(
    title='Interactive timeline of connections between satellites and IoT devices',
    xaxis_title='Time',
    yaxis_title='Connection Index',
    showlegend=False
)

# Afficher la figure interactive
fig.show()
