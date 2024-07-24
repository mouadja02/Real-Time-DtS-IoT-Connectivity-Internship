import pandas as pd
import matplotlib.pyplot as plt
import networkx as nx
import matplotlib.colors as mcolors

# Charger les données
file_path = 'Preparation/access_intervals.csv'
df = pd.read_csv(file_path, parse_dates=['StartTime', 'EndTime'])

# Création du graphe
G = nx.DiGraph()
for _, row in df.iterrows():
    G.add_edge(row['Source'], row['Target'], start=row['StartTime'], end=row['EndTime'], duration=row['Duration'])

# Initialisation du positionnement et des couleurs
pos = nx.spring_layout(G, seed=42)  # Layout pour bien visualiser les noeuds et connexions
durations = [data['duration'] for u, v, data in G.edges(data=True)]
norm = mcolors.Normalize(vmin=min(durations), vmax=max(durations))
cmap = plt.cm.Blues

# Créer un mappable pour la colorbar
mappable = plt.cm.ScalarMappable(norm=norm, cmap=cmap)
mappable.set_array(durations)

# Créer les étiquettes des arêtes
labels = {(u, v): f"{data['start'].time()} - {data['end'].time()}" for u, v, data in G.edges(data=True)}

# Tracé du graphe
fig, ax = plt.subplots(figsize=(14, 10))
edges = nx.draw(G, pos, ax=ax, edge_color=durations, edge_cmap=cmap, edge_vmin=min(durations), edge_vmax=max(durations),
                width=2, node_color='lightgreen', with_labels=True)
nx.draw_networkx_edge_labels(G, pos, edge_labels=labels, font_color='red', ax=ax)

# Ajouter la colorbar
fig.colorbar(mappable, ax=ax, orientation='vertical', label='Duration (seconds)')
ax.set_title('Graph of IoT-Satellite Connectivity with Temporal Edges')
plt.show()


# Filtrer les nœuds d'intérêt
main_nodes = ['Main_IoT', 'GS', 'Node 1', 'Node 2']

# Création du graphe simplifié
G_simplified = nx.DiGraph()

# Fonction pour trouver les connexions minimales
def find_minimum_connection(source, target, df):
    sub_df = df[((df['Source'] == source) & (df['Target'] == target)) |
                ((df['Source'] == target) & (df['Target'] == source))]
    if not sub_df.empty:
        min_row = sub_df.loc[sub_df['Duration'].idxmin()]
        return min_row['Source'], min_row['Target'], min_row['Duration'], min_row['Source'] if min_row['Source'].startswith('Satellite') else min_row['Target']
    return None, None, None, None

# Trouver les connexions minimales entre les nœuds principaux
for source in main_nodes:
    for target in main_nodes:
        if source != target:
            src, tgt, duration, satellite = find_minimum_connection(source, target, df)
            if src and tgt:
                G_simplified.add_edge(source, target, duration=duration, satellite=satellite)

# Initialisation du positionnement et des couleurs
pos = nx.spring_layout(G_simplified, seed=42)
edge_labels = {(u, v): f"{data['satellite']} ({data['duration']} s)" for u, v, data in G_simplified.edges(data=True)}

# Tracé du graphe simplifié
fig, ax = plt.subplots(figsize=(14, 10))
nx.draw(G_simplified, pos, ax=ax, node_color='lightgreen', with_labels=True, node_size=1000, font_size=12, font_weight='bold')
nx.draw_networkx_edge_labels(G_simplified, pos, edge_labels=edge_labels, font_color='red', ax=ax)
nx.draw_networkx_edges(G_simplified, pos, ax=ax, arrowstyle='-|>', arrowsize=15, edge_color='blue', width=2)

ax.set_title('Simplified Graph of IoT-Satellite Connectivity with Minimal Duration Links')
plt.show()
