# Import seaborn
import seaborn as sns
import pandas as pd

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

# Join and pivot
data = cpuTime.join(naiveTime, lsuffix='cpu', rsuffix='naive').join(mkTime, rsuffix='mk')
data['run'] = data.index

data = pd.wide_to_long(data, ['cpu', 'naive', 'mk'], i='run', j='size')
data = data.reset_index()

print(data)

data = pd.melt(data, id_vars=['run', 'size'], var_name='method', value_name='time')

print(data)
