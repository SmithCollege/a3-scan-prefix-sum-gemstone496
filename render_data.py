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

# Pivots
cpuTime = pd.wide_to_long(cpuTime, id_vars=0)
