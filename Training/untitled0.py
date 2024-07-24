import pandas as pd
import networkx as nx
 
df = pd.read_csv(csv_filename)
G = nx.from_pandas_edgelist(df, source='source', target='target', edge_attr='weight', create_using=nx.DiGraph())