# AnalysisData Folder

## Overview

According to the **Project TIER Protocol 4.0**, the `AnalysisData` folder is designed to store the final, cleaned, and processed dataset(s) resulting from data processing scripts, ready to be directly ingested by statistical models.

## Status in this Project

This folder is intentionally empty:
- This project evaluates statistical power through theoretical covariance matrices (using `semPower`) and Monte Carlo simulations (using `simsem`).
- The analytical workflow draws directly from population parameter matrices in [`Data/InputData/`](file:///e:/Github/cfa-power/Data/InputData/) and intermediate simulation caches in [`Data/IntermediateData/`](file:///e:/Github/cfa-power/Data/IntermediateData/), generating sample realizations dynamically in memory.
- Because no empirical data-cleaning pipeline is executed to construct a persistent final dataset, no static `AnalysisData` files are generated or required for replication.
