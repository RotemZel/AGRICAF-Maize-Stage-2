# AGRICAF - Step 2: Price Analysis for Maize

## Overview
This repository contains the code for the **2nd step of AGRICAF**, focusing on analyzing historical maize price trends. This step aims to identify key drivers of price fluctuations using multiple regression techniques and machine learning models. The insights from this analysis are used to enhance the accuracy and interpretability of the price forecasting models in subsequent steps.
For a full description of the methodology and findings, please refer to the preprint paper: https://doi.org/10.48550/arXiv.2410.20363.

## Methodology
The analysis is conducted using various statistical and machine learning models, each designed to capture different aspects of maize price variations. The following models are implemented:

### 1. **Random Forest Regression (`2_regression_analyse_rf.R`)**
   - Utilizes an ensemble-based decision tree approach.
   - Tunes the **number of trees (n.trees)** and **predictor subset size (mtry)**.
   - Outputs feature importance based on the mean decrease in accuracy.

### 2. **Gradient Boosting Machine (`3_regression_analyse_gbm.R`)**
   - Implements a boosting technique to iteratively improve weak models.
   - Key hyperparameters:
     - **n.trees** (number of iterations)
     - **interaction.depth** (tree depth)
     - **shrinkage** (learning rate).
   - Uses cross-validation to select optimal parameters.

### 3. **Classification and Regression Trees (`4_regression_analyse_cart.R`)**
   - Builds a decision tree model using recursive partitioning.
   - Tunes parameters such as **complexity (`cp`)** and **tree depth (`maxdepth`)**.
   - Outputs an interpretable tree structure showing key price determinants.

### 4. **Linear Regression with AIC (`5_regression_analyse_lm.R`)**
   - Uses **stepwise selection** to identify significant predictors.
   - Minimizes **Akaike Information Criterion (AIC)** to select the best subset of variables.
   - Removes highly correlated variables to prevent multicollinearity issues.

### 5. **Generalized Additive Model (`6_regression_analyse_gam.R`)**
   - Fits both **linear and nonlinear** relationships using smooth functions.
   - Determines whether a **normal** or **non-normal** distribution should be used.
   - Uses smoothing splines to model complex price dependencies.

## Data Requirements
- The scripts require pre-processed datasets stored in `analyse_data.RData`.
- The main input variable is **production data**, filtered for specific months and lag structures.
- The analysis outputs feature importance rankings and price prediction errors for model evaluation.

## Running the Scripts
1. Ensure all required R packages are installed:
   ```r
   install.packages(c("caret", "randomForest", "gbm", "rpart", "mgcv", "tidyverse", "broom"))
   ```
2. Set the working directory to the appropriate maize price dataset:
   ```r
   setwd("~/price_forecasting/maize_prices")
   ```
3. Run each script individually in R:
   ```r
   source("2_regression_analyse_rf.R")
   ```
4. The scripts will generate output files (`rank_*.RData` and `records_*.RData`) containing feature importance rankings and model performance metrics.

## Running the Analysis Using SLURM
### Setup and Execution
For large-scale execution, SLURM job scripts are included:
- **`setup_analyse_maize_country_production.sh`**: Generates parameter files and submits batch jobs for **country-level maize production analysis**.
- **`setup_analyse_maize_region_production.sh`**: Generates parameter files and submits batch jobs for **region-level maize production analysis**.

To run the analysis, execute the setup script:
```bash
bash setup_analyse_maize_country_production.sh
```
OR
```bash
bash setup_analyse_maize_region_production.sh
```
These scripts will generate and submit SLURM batch jobs for processing the analysis scripts across multiple parameter sets.

## Output Files
- **`rank_*.RData`**: Contains ranked feature importance for each model.
- **`records_*.RData`**: Stores model predictions, errors, and tuning parameters.
