import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import argparse
from matplotlib.colors import LinearSegmentedColormap

# args
parser = argparse.ArgumentParser(description="Density Distribution plot.")
parser.add_argument('input_file', type=str, help="Input directory.")
parser.add_argument('--output', type=str, default='output.eps', help="Output plot.")
args = parser.parse_args()

# read data
df = pd.read_csv(args.input_file, sep='\s+', header=None, names=['x', 'y', 'count'])

# Create graph and subgraph layouts
fig = plt.figure(figsize=(10, 10))
grid = plt.GridSpec(4, 4, hspace=0.5, wspace=0.5)

ticks= [-0.005, 0.00, 0.01, 0.02, 0.03, 0.04, 0.05, 0.058]
y_ticks = [0, 1000, 2000, 3000]

# Main: density distribution
ax_main = fig.add_subplot(grid[1:4, 0:3])
sns.kdeplot(
    x=df['x'], y=df['y'], weights=df['count'],
    cmap="Blues", fill=True, thresh=0.0001, ax=ax_main
)
ax_main.set(xlabel='bac120', ylabel='f88') 
ax_main.set_xticks(ticks)

# X axis: density curve
ax_kdex = fig.add_subplot(grid[0, 0:3], sharex=ax_main)
sns.kdeplot(
    x=df['x'], weights=df['count'],
    fill=True, color='blue', ax=ax_kdex
)
ax_kdex.set(ylabel='Density')
ax_kdex.set(xlabel='bac120')
ax_kdex.set_xticks(ticks)
ax_kdex.set_yticks(y_ticks)

# save plot
plt.savefig(args.output, format='eps', dpi=300, bbox_inches='tight')
