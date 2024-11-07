# Import seaborn
import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt

# Apply default theme
sns.set_theme()

# Load data
PATH = "timers/"
cpuTime = pd.read_csv(PATH + "cpu.csv", header=0, index_col=0)
naiveTime = pd.read_csv(PATH + "naive.csv", header=0, index_col=0)
mkTime = pd.read_csv(PATH + "mkernel.csv", header=0, index_col=0)

# Transpose
cpuTime = cpuTime.transpose().rename(columns={2048: 'cpu2048', 4096: 'cpu4096', 16384: 'cpu16384'})
naiveTime = naiveTime.transpose().rename(columns={2048: 'naive2048', 4096: 'naive4096', 16384: 'naive16384'})
mkTime = mkTime.transpose().rename(columns={2048: 'mk2048', 4096: 'mk4096', 16384: 'mk16384'})

# Join
times = cpuTime.join(naiveTime, lsuffix='cpu', rsuffix='naive').join(mkTime, rsuffix='mk')
times['run'] = times.index # turn this back into a proper row

# Pull out size through a wide-long pivot
times = pd.wide_to_long(times, ['cpu', 'naive', 'mk'], i='run', j='size')
times = times.reset_index() # turn back to a proper row

# Pull out method through a melting pivot
times  = pd.melt(times, id_vars=['run', 'size'], var_name='method', value_name='time').reset_index()


# Create graph
plot = sns.lmplot(data=times, x='size', y='time', hue='method')

# Export graph
plt.savefig("timers.png")
