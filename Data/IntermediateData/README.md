# IntermediateData Folder

## Overview

This folder stores 12 precomputed Monte Carlo simulation objects saved as serialized R binary files (`.rds`).

Each simulation runs 1,500 replications across varying sample size sequences or fixed conditions using the `simsem` package. Because running all simulations simultaneously requires considerable computational time, these objects are persisted here. This enables `quarto render` and interactive notebook evaluation to complete in seconds.

## Cached Simulation Objects Inventory (12 RDS Files)

The table below lists each cached object, its originating script, simulation design, and where it is consumed:

| File Name | Origin (Script) | Simulation Condition & Model | Destination / Consumers |
| :--- | :--- | :--- | :--- |
| [`popmodel_ideal.rds`](file:///e:/Github/cfa-power/Data/IntermediateData/popmodel_ideal.rds) | `03_simulation_ideal.qmd` | Null population model (`popmodel`) under ideal multivariate normal conditions ($N \in [51, 350]$). | `index.qmd` (setup chunk)<br>`03_simulation_ideal.qmd` |
| [`h1model_ideal.rds`](file:///e:/Github/cfa-power/Data/IntermediateData/h1model_ideal.rds) | `03_simulation_ideal.qmd` | Alternative cross-loading model (`h1model`) under ideal conditions ($N \in [51, 350]$). | `index.qmd` (setup chunk)<br>`03_simulation_ideal.qmd` |
| [`naivemodel_ideal.rds`](file:///e:/Github/cfa-power/Data/IntermediateData/naivemodel_ideal.rds) | `03_simulation_ideal.qmd` | Pessimistic naive model (`naivemodel`) under ideal conditions ($N \in [51, 350]$). | `index.qmd` (setup chunk)<br>`03_simulation_ideal.qmd` |
| [`optmodel_ideal.rds`](file:///e:/Github/cfa-power/Data/IntermediateData/optmodel_ideal.rds) | `03_simulation_ideal.qmd` | Optimistic model (`optmodel`) under ideal conditions ($N \in [51, 350]$). | `index.qmd` (setup chunk)<br>`03_simulation_ideal.qmd` |
| [`popmodel_miss.rds`](file:///e:/Github/cfa-power/Data/IntermediateData/popmodel_miss.rds) | `04_simulation_robust.qmd` | Null model (`popmodel`) under 10% MCAR missing data using FIML ($N \in [51, 350]$). | `index.qmd` (setup chunk)<br>`04_simulation_robust.qmd` |
| [`h1model_miss.rds`](file:///e:/Github/cfa-power/Data/IntermediateData/h1model_miss.rds) | `04_simulation_robust.qmd` | Alternative model (`h1model`) under 10% MCAR missing data using FIML ($N \in [51, 350]$). | `index.qmd` (setup chunk)<br>`04_simulation_robust.qmd` |
| [`popmodel_nnorm.rds`](file:///e:/Github/cfa-power/Data/IntermediateData/popmodel_nnorm.rds) | `04_simulation_robust.qmd` | Null model (`popmodel`) under non-normal continuous indicators with robust MLR ($N \in [51, 350]$). | `index.qmd` (setup chunk)<br>`04_simulation_robust.qmd` |
| [`h1model_nnorm.rds`](file:///e:/Github/cfa-power/Data/IntermediateData/h1model_nnorm.rds) | `04_simulation_robust.qmd` | Alternative model (`h1model`) under non-normal indicators with robust MLR ($N \in [51, 350]$). | `index.qmd` (setup chunk)<br>`04_simulation_robust.qmd` |
| [`popmodel_fixed.rds`](file:///e:/Github/cfa-power/Data/IntermediateData/popmodel_fixed.rds) | `05_model_comparison.qmd` | Null model (`popmodel`) with fixed $N = 350$ under realistic conditions (10% MCAR + non-normality). | `05_model_comparison.qmd` |
| [`h1model_fixed.rds`](file:///e:/Github/cfa-power/Data/IntermediateData/h1model_fixed.rds) | `05_model_comparison.qmd` | Alternative model (`h1model`) with fixed $N = 350$ under realistic conditions (10% MCAR + non-normality). | `05_model_comparison.qmd` |
| [`realmodel_null.rds`](file:///e:/Github/cfa-power/Data/IntermediateData/realmodel_null.rds) | `06_posthoc.qmd` | Null model derived from empirical parameters at observed sample size $N = 1,047$. | `06_posthoc.qmd` |
| [`h1model_alt.rds`](file:///e:/Github/cfa-power/Data/IntermediateData/h1model_alt.rds) | `06_posthoc.qmd` | Alternative cross-loading model evaluated at observed sample size $N = 1,047$. | `06_posthoc.qmd` |

## Cache Management

- **Loading Logic**: Notebooks access these caches using the `cache_or_run()` function defined in [`Scripts/DataAppendixScripts/cache_utils.R`](file:///e:/Github/cfa-power/Scripts/DataAppendixScripts/cache_utils.R). If a file exists in `Data/IntermediateData/`, it is loaded immediately; if absent, the simulation is executed and saved.
- **Regeneration**: To regenerate all caches from scratch, delete the `.rds` files or run:
  ```bash
  Rscript Scripts/DataAppendixScripts/pre_render_cache.R
  ```
