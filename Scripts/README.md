# Scripts Folder

## Overview

This folder contains all computational code for the project, including the analysis notebooks, model specifications, simulation helpers, cache utilities, and post-render export hooks.

## Contents

- **[`AnalysisScripts/`](file:///e:/Github/cfa-power/Scripts/AnalysisScripts/)**: Contains the 6 computational Quarto companion notebooks (`01` to `06`) that conduct analytical power calculations and Monte Carlo simulations.
- **[`DataAppendixScripts/`](file:///e:/Github/cfa-power/Scripts/DataAppendixScripts/)**: Contains 7 shared R scripts supporting the analysis pipeline (model definitions, global simulation parameters, caching functions, and build hooks).
- **[`ProcessingScripts/`](file:///e:/Github/cfa-power/Scripts/ProcessingScripts/)**: Standard TIER folder for data cleaning and preprocessing routines; intentionally empty in this simulation study.

## Execution and Replication Workflow

The analytical workflow is orchestrated centrally via [`_quarto.yml`](file:///e:/Github/cfa-power/_quarto.yml) and executed using a single command:

```bash
quarto render
```

### Execution Lifecycle:
1. **Pre-Render**:
   - Runs `Scripts/DataAppendixScripts/pre_render_cache.R` to verify that precomputed simulation models exist in `Data/IntermediateData/`.
2. **Analysis Execution**:
   - Executes the companion notebooks (`Scripts/AnalysisScripts/01_*.qmd` through `06_*.qmd`) and the main manuscript (`index.qmd`), drawing shared functions from `Scripts/DataAppendixScripts/models.R` and `helpers.R`.
3. **Post-Render**:
   - Runs `Scripts/DataAppendixScripts/post_render_figures.R` to mirror all 21 PNG figures to [`Output/Results/Figures/`](file:///e:/Github/cfa-power/Output/Results/Figures/).
   - Runs `Scripts/DataAppendixScripts/post_render_tables.R` to extract all 18 tabular outputs to [`Output/Results/Tables/`](file:///e:/Github/cfa-power/Output/Results/Tables/) in clean CSV format.
