# AnalysisScripts Folder

## Overview

This folder stores the 6 computational Quarto companion notebooks (`.qmd`) that execute all analytical calculations and Monte Carlo simulations presented in the study.

## Inventory of Analysis Notebooks

The table below describes each notebook, its analytical objective, and the outputs it produces:

| Notebook | Focus & Methodology | Primary Outputs Generated |
| :--- | :--- | :--- |
| [`01_population_models.qmd`](file:///e:/Github/cfa-power/Scripts/AnalysisScripts/01_population_models.qmd) | Specifies the 4 population models (`popmodel`, `naivemodel`, `optmodel`, `h1model`) and the baseline analysis model (`analyzemodel`). | - 5 path diagrams (`fig-diagram-*`)<br>- 2 comparison tables (`tbl-pop-summary`, `tbl-pop-comparison`) |
| [`02_analytical_power.qmd`](file:///e:/Github/cfa-power/Scripts/AnalysisScripts/02_analytical_power.qmd) | Evaluates a priori analytical statistical power and power curves using `semPower` (model-free RMSEA vs. model-based lavaan syntax). | - 4 density/power figures (`fig-apriori-*`, `fig-power-*`)<br>- 1 analytical summary table (`tbl-analytical-summary`) |
| [`03_simulation_ideal.qmd`](file:///e:/Github/cfa-power/Scripts/AnalysisScripts/03_simulation_ideal.qmd) | Monte Carlo simulations (1,500 reps) under ideal multivariate normal conditions across sample sizes ($N \in [51, 350]$). Evaluates empirical cutoffs, traditional thresholds, and parameter recovery. | - 3 power/fit figures (`fig-power-curve-ideal`, `fig-fit-curve-*`)<br>- 6 tables (`tbl-power-cutoff-*`, `tbl-param-estimate-*`, `tbl-power-n-*`) |
| [`04_simulation_robust.qmd`](file:///e:/Github/cfa-power/Scripts/AnalysisScripts/04_simulation_robust.qmd) | Monte Carlo simulations probing sensitivity to realistic violations: (a) 10% MCAR missing data using FIML, and (b) mild non-normality using robust MLR estimation. | - 4 power/fit figures (`fig-power-curve-missing`, `fig-fit-curve-*`, `fig-power-curve-nnorm`)<br>- 2 tables (`tbl-power-cutoff-missing`, `tbl-power-cutoff-nnorm`) |
| [`05_model_comparison.qmd`](file:///e:/Github/cfa-power/Scripts/AnalysisScripts/05_model_comparison.qmd) | Fixed-sample simulation at $N = 350$ under combined realistic conditions (10% MCAR + non-normality). Directly contrasts empirical cutoffs with conventional rule-of-thumb thresholds. | - 2 fit distribution figures (`fig-power-curve-fixed`, `fig-curve-fixed-traditional`)<br>- 2 tables (`tbl-power-cutoff-fixed`, `tbl-power-cutoff-traditional-fixed`) |
| [`06_posthoc.qmd`](file:///e:/Github/cfa-power/Scripts/AnalysisScripts/06_posthoc.qmd) | Post hoc power analysis applied to real empirical WHOQOL-BREF data ($N = 1,047$). Contrasts simulation-based discrimination against analytical solutions. | - 3 post hoc figures (`fig-posthoc-*`)<br>- 1 post hoc power table (`tbl-posthoc-power`) |

## Provenance and Usage

- **Inputs**:
  - Model definitions and shared constants are sourced from [`Scripts/DataAppendixScripts/models.R`](file:///e:/Github/cfa-power/Scripts/DataAppendixScripts/models.R) and [`helpers.R`](file:///e:/Github/cfa-power/Scripts/DataAppendixScripts/helpers.R).
  - Parameter values are loaded from [`Data/InputData/popmodels_parameters.csv`](file:///e:/Github/cfa-power/Data/InputData/popmodels_parameters.csv).
  - Precomputed simulation caches are retrieved from [`Data/IntermediateData/`](file:///e:/Github/cfa-power/Data/IntermediateData/) via `cache_utils.R`.
- **Destinations**:
  - Chunks and visual outputs are embedded directly into the primary manuscript ([`index.qmd`](file:///e:/Github/cfa-power/index.qmd)).
  - Standalone figures and tables are exported to [`Output/Results/`](file:///e:/Github/cfa-power/Output/Results/) upon rendering.
