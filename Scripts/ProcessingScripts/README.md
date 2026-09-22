# ProcessingScripts Folder

## Overview

According to the **Project TIER Protocol 4.0**, the `ProcessingScripts` folder is designed to store scripts that perform data cleaning, transformation, and merging operations on raw data from `InputData` to create analysis-ready files.

## Status in this Project

This folder is intentionally empty:
- This project evaluates statistical power through theoretical covariance matrices and Monte Carlo simulations.
- Model specifications and population parameters are directly parameterized in [`Data/InputData/popmodels_parameters.csv`](file:///e:/Github/cfa-power/Data/InputData/popmodels_parameters.csv) and [`Scripts/DataAppendixScripts/models.R`](file:///e:/Github/cfa-power/Scripts/DataAppendixScripts/models.R).
- The empirical demonstration in `06_posthoc.qmd` ingests the public WHOQOL-BREF benchmark dataset programmatically into memory.
- Because no empirical data-cleaning pipeline was necessary to construct persistent analysis datasets, no preliminary processing scripts are required for replication.
