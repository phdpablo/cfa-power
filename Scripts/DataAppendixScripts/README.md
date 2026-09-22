# DataAppendixScripts Folder

## Overview

This folder contains shared R scripts that support the analysis notebooks and automate project build hooks. These scripts centralize model specifications, simulation parameters, caching utilities, and post-render export routines.

## Inventory of Scripts

The table below describes each R script and its role in the replication pipeline:

| Script | Purpose & Contents | Consumers / Lifecycle |
| :--- | :--- | :--- |
| [`models.R`](file:///e:/Github/cfa-power/Scripts/DataAppendixScripts/models.R) | Defines the `lavaan` model syntax for all 5 CFA models (`popmodel`, `naivemodel`, `optmodel`, `h1model`, `analyzemodel`), as well as visual diagramming functions (`plot_color()`, `plot_free()`). | Sourced by all analysis notebooks (`01`–`06`) and `index.qmd`. |
| [`helpers.R`](file:///e:/Github/cfa-power/Scripts/DataAppendixScripts/helpers.R) | Defines global constants: significance level ($\alpha = 0.05$), target power ($0.80$), 1,500 replications, random seeds, sample size sequences (`SEQ1`, `SEQ2`), and fit index sets (`FITS`, `RULE_OF_THUMB`). | Sourced by all analysis notebooks (`01`–`06`) and `index.qmd`. |
| [`cache_utils.R`](file:///e:/Github/cfa-power/Scripts/DataAppendixScripts/cache_utils.R) | Defines `cache_or_run()`, ensuring simulations are loaded from `Data/IntermediateData/` if already computed, or executed and saved if missing. | Sourced by simulation notebooks (`03`, `04`, `05`, `06`). |
| [`cache_loader.R`](file:///e:/Github/cfa-power/Scripts/DataAppendixScripts/cache_loader.R) | Defines `cache_load_existing()`, an environment helper to bulk-load all existing `.rds` simulation objects into the calling workspace. | Sourced by notebooks `03`–`06` and `pre_render_cache.R`. |
| [`pre_render_cache.R`](file:///e:/Github/cfa-power/Scripts/DataAppendixScripts/pre_render_cache.R) | Pre-render routine that checks for the existence of intermediate simulation caches before document compilation begins. | Configured as a `pre-render` hook in `_quarto.yml`. |
| [`post_render_figures.R`](file:///e:/Github/cfa-power/Scripts/DataAppendixScripts/post_render_figures.R) | Standalone Base R script that synchronizes all rendered figures from Quarto preview HTMLs and mirrors them to [`Output/Results/Figures/`](file:///e:/Github/cfa-power/Output/Results/Figures/). | Configured as a `post-render` hook in `_quarto.yml`. |
| [`post_render_tables.R`](file:///e:/Github/cfa-power/Scripts/DataAppendixScripts/post_render_tables.R) | Standalone Base R script that parses all HTML table containers (`id="tbl-*"`) across rendered documents and extracts clean CSV files to [`Output/Results/Tables/`](file:///e:/Github/cfa-power/Output/Results/Tables/). | Configured as a `post-render` hook in `_quarto.yml`. |
