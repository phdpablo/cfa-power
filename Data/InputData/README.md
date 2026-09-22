# InputData Folder

## Overview

This folder stores the original, unaltered input files and parameter matrices that serve as the empirical and theoretical foundations for the study's power analyses.

## Contents

- **[`popmodels_parameters.csv`](file:///e:/Github/cfa-power/Data/InputData/popmodels_parameters.csv)**:
  A structured CSV file containing the exact parameter values (factor loadings, residual variances, latent correlations, and cross-loadings) for the four population model variants:
  1. `popmodel`: Meta-analytic parameter estimates from Lin & Yao (2022).
  2. `naivemodel`: Pessimistic baseline based on lowest reported domain reliabilities (Mosqueira-Taipe et al., 2026).
  3. `optmodel`: Optimistic baseline based on highest reported domain reliabilities.
  4. `h1model`: Misspecified model incorporating three empirically supported cross-loadings ($Q8$, $Q9$, $Q15$).
- **[`Metadata/`](file:///e:/Github/cfa-power/Data/InputData/Metadata/)**:
  Subfolder containing the Data Sources Guide, item mappings, and parameter derivation documentation.

## External Data Source

For the empirical post hoc power demonstration in `06_posthoc.qmd` and `index.qmd`, raw data is downloaded programmatically from the Mendeley Data public repository:
- **Repository**: Rogers, Pablo (2022). *WHOQOL-BREF Data*. Mendeley Data, V2.
- **Data File**: `WHOQOL_Data.dat` (`https://data.mendeley.com/datasets/rdky78bk8r/2/files/b58a7054-4978-4239-81db-00f9efd86e44/WHOQOL_Data.dat`)
- **Labels File**: `WHOQOL_Labels.txt` (`https://data.mendeley.com/datasets/rdky78bk8r/2/files/ae2a5c01-2fc2-43e5-b31c-8db8cc5bff8a/WHOQOL_Labels.txt`)

## Provenance and Usage

- **Origin**: Compiled from peer-reviewed literature (Lin & Yao, 2022; Mosqueira-Taipe et al., 2026).
- **Destination**:
  - `popmodels_parameters.csv` is read by [`Scripts/AnalysisScripts/01_population_models.qmd`](file:///e:/Github/cfa-power/Scripts/AnalysisScripts/01_population_models.qmd) to create tables `@tbl-pop-summary` and `@tbl-pop-comparison`.
  - Model syntax in [`Scripts/DataAppendixScripts/models.R`](file:///e:/Github/cfa-power/Scripts/DataAppendixScripts/models.R) directly operationalizes these parameter sets.
