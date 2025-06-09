# main.py — Final DiD Replication Script for Submission

import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import statsmodels.api as sm

# Setting up 
sns.set(style="whitegrid")
plt.rcParams["figure.figsize"] = (10, 5)

# Setting working directory to project folder 
os.chdir(r"C:\Users\ASUS\OneDrive\Desktop\Module2 Platform Economics\TwitterDiD_project\pytrends_version")

# Paths 
DATA_FILE = "data/prepared_data.csv"
PLOTS_DIR = "output/plots"
TABLES_DIR = "output/tables"
os.makedirs(PLOTS_DIR, exist_ok=True)
os.makedirs(TABLES_DIR, exist_ok=True)

# Parameters 
event_date = pd.to_datetime("2022-04-14")
treatment_platform = "Twitter"

# Loading data 
df = pd.read_csv(DATA_FILE, parse_dates=["Week"])
df['Treatment'] = (df['Platform'] == treatment_platform).astype(int)
df['Post'] = (df['Week'] >= event_date).astype(int)
df['Did'] = df['Treatment'] * df['Post']
df['time_trend'] = (df['Week'] - df['Week'].min()).dt.days / 7
df['trend_x_treat'] = df['time_trend'] * df['Treatment']
df['month'] = df['Week'].dt.month

# Regression: Difference-in-Differences
platform_dummies = pd.get_dummies(df['Platform'], drop_first=True, prefix='platform')
month_dummies = pd.get_dummies(df['month'], drop_first=True, prefix='month')
df_reg = pd.concat([df, platform_dummies, month_dummies], axis=1)

X_cols = ['Treatment', 'Post', 'Did', 'time_trend', 'trend_x_treat'] + list(platform_dummies.columns) + list(month_dummies.columns)
X = sm.add_constant(df_reg[X_cols])
y = df_reg['SearchVolumeNorm']

model = sm.OLS(y.astype(float), X.astype(float)).fit(cov_type='cluster', cov_kwds={'groups': df_reg['Platform']})

with open(os.path.join(TABLES_DIR, "did_results.txt"), "w") as f:
    f.write(model.summary().as_text())

# Plot: Event Study 
df['event_week'] = ((df['Week'] - event_date).dt.days // 7).astype(int)
df['is_treatment'] = (df['Platform'] == treatment_platform).astype(int)

for w in range(-12, 13):
    df[f'week_{w}'] = (df['event_week'] == w).astype(int)
    df[f'week_{w}_x_treat'] = df[f'week_{w}'] * df['is_treatment']

event_vars = [f'week_{w}_x_treat' for w in range(-12, 13) if w != -1]
X_event = sm.add_constant(df[event_vars])
y_event = df['SearchVolumeNorm']
event_model = sm.OLS(y_event.astype(float), X_event.astype(float)).fit()
coefs = event_model.params[1:]
conf_int = event_model.conf_int().loc[coefs.index]

weeks = [int(var.split('_')[1]) for var in coefs.index]
plt.figure(figsize=(10, 6))
plt.plot(weeks, coefs, marker='o', label='Estimate')
plt.fill_between(weeks, conf_int[0], conf_int[1], alpha=0.3, label='95% CI')
plt.axhline(0, color='gray', linestyle='--')
plt.axvline(0, color='red', linestyle='--')
plt.title("Event Study: Weekly Treatment Effect")
plt.xlabel("Weeks from Event")
plt.ylabel("Effect (Standardized)")
plt.legend()
plt.tight_layout()
plt.savefig(os.path.join(PLOTS_DIR, "event_study.png"), dpi=300)
plt.close()

# Plot: Barplot (Colorblind-friendly)
plt.figure(figsize=(10, 6))
sns.barplot(data=df, x='Platform', y='SearchVolume', hue='Post', palette='colorblind')
plt.title("Average Search Volume: Before vs After April 14, 2022")
plt.xlabel("Platform")
plt.ylabel("Search Volume (0–100)")
plt.legend(title="Period", labels=["Before", "After"])
plt.tight_layout()
plt.savefig(os.path.join(PLOTS_DIR, "barplot_before_after.png"), dpi=300)
plt.close()

print("Analysis complete. Results saved in output folders.")
