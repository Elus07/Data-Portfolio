# Internal Migration and Regional Inequality in Sweden

This project investigates how job availability, housing prices, and travel time influence internal migration patterns across Swedish municipalities. Using a gravity model and count regression methods, it evaluates the economic and geographic determinants of migration flows.

# Objectives
- Understand how jobs, housing, and geography jointly affect migration
- Apply Poisson and Negative Binomial models to migration count data
- Quantify the role of travel time and affordability in shaping mobility

# Methods & Tools
- Python (pandas, statsmodels, matplotlib)
- Count regression: PPML and Negative Binomial
- Gravity model framework with elasticities
- Correlation diagnostics and model comparison

# Key Findings
| Variable               | Effect               | Interpretation |
|------------------------|----------------------|----------------|
| `ln_Jobs_To`           | +1.10                | Job opportunities attract migrants |
| `ln_HousePrices_To`    | –0.35                | High housing costs reduce appeal |
| `ln_TravelTime`        | –1.68                | Long travel time strongly deters migration |
| `ln_Pop_From`          | +1.14                | Larger origin populations have higher outbound migration |

- PPML performed well but was affected by overdispersion
- Negative Binomial model provided more reliable estimates

# Policy Implications
- **Create jobs** in lagging regions to balance migration
- **Improve infrastructure** to reduce travel time
- **Tackle housing costs** in high-pressure urban areas

# Files
- `main_gravity_model.py` – full estimation and plotting script
- `migration_data.csv` – dataset for Swedish municipal flows
- `output/` – includes plots and regression results
- `report.pdf` – full write-up including theory, model, diagnostics

# Status
Coursework project in Advanced Econometrics and Regional Development, Jönköping International Business School (MSc).

# Contact
Elya Madambekova Uysal · elusmad@gmail.com

