# Salary Prediction and Economic Forecasting

This project applies statistical and econometric techniques to analyze salary structures and forecast macroeconomic trends.

## Project Goals
- Predict current salaries based on factors like education, experience, and starting salary
- Forecast economic indicators (GDP, unemployment, financial index) using time series models

## Methods Used
- **OLS Regression**: For salary prediction
- **ARIMA & VAR**: For time series forecasting
- **Diagnostics**: ADF test, VIF, Breusch-Pagan, Durbin-Watson

## Model Evaluation
| Model | MAE       | RMSE     | R²     |
|-------|-----------|----------|--------|
| OLS   | 0.1509    | 0.1879   | 0.8306 |
| VAR   | 3.4818    | 4.3883   |   —    |
| ARIMA | 2.3894    |   —      |   —    |

## Key Insights
- Starting salary is a strong predictor of current salary
- OLS outperformed time series models in terms of predictive power
- ARIMA performed better than VAR in forecasting GDP
- Notable gender pay gap observed, worth further investigation

## Tools
- Python (pandas, statsmodels, seaborn, matplotlib)
- Statistical tests (ADF, VIF, BP, DW)
- Data visualization & residual diagnostics

---

> Full code is available in [`salary_analysis.py`](./salary_analysis.py)

