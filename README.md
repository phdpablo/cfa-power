# Power Analysis for Confirmatory Factor Analysis: A Practical Tutorial

### Analytical and Simulation-Based Approaches

**Author**: Pablo Rogers  
*Universidade Federal de Uberlândia (UFU)*  
*ORCID*: [0000-0002-0093-3834](https://orcid.org/0000-0002-0093-3834)  

---

## Quick Access

- 🌐 **Interactive Web Manuscript**: [https://phdpablo.github.io/cfa-power/](https://phdpablo.github.io/cfa-power/)  
  *(Deployed continuously via GitHub Pages from the `main` branch and `/docs` folder)*
- 📄 **Manuscript in PDF**: [`docs/index.pdf`](https://phdpablo.github.io/cfa-power/index.pdf)
- 📝 **Manuscript in Word (DOCX)**: [`docs/index.docx`](https://phdpablo.github.io/cfa-power/index.docx)

---

## 1. Project Overview

This repository provides a comprehensive, hands-on tutorial on statistical power analysis in **Confirmatory Factor Analysis (CFA)**. It contrasts the two dominant methodological paradigms side by side:

1. **Analytical Approaches**: Based on the noncentral $\chi^2$ distribution, implemented via the [`semPower`](https://github.com/moshagen/semPower) package using `lavaan` syntax.
2. **Simulation-Based Approaches**: Based on empirical Monte Carlo data generation, implemented via the [`simsem`](https://simsem.org/) package.

### Unifying Case Study
All analyses are anchored in the World Health Organization Quality of Life-BREF (**WHOQOL-BREF**) four-factor model (Physical, Psychological, Social Relationships, and Environment). Parameter values are grounded in empirical meta-analytic evidence (Lin & Yao, 2022) and systematic review reliability ranges (Mosqueira-Taipe et al., 2026), rather than arbitrary rules of thumb.

### Methodological Topics Covered
- **Prospective Planning & Power Curves**: Calculating sample size requirements for global model misspecification and visualizing power functions across continuous sample size grids.
- **Parameter-Level Power & Finite-Sample Diagnostics**: Moving beyond global fit to assess parameter-specific power, relative parameter bias, relative standard error bias, and 95% confidence interval coverage.
- **Sensitivity Analysis**: Benchmarking sample size requirements across pessimistic (*naive*) and optimistic population variants.
- **Realistic Data Violations**: Evaluating the information cost of 10% MCAR missing data (handled via Full Information Maximum Likelihood — FIML) and mild continuous non-normality (handled via robust MLR estimation).
- **Cutoff Sensitivity**: Contrasting empirical, null-derived decision cutoffs with conventional rule-of-thumb thresholds at a fixed sample size ($N = 250$).
- **Post Hoc Evaluation**: Conducting post hoc power analysis on real empirical survey data ($N = 1,047$) while addressing the methodological limitations of retrospective power.

---

## 2. Repository Structure

The project is structured according to the **Project TIER Protocol 4.0** guidelines and built as an executable **Quarto Manuscript** (`type: manuscript`):

```text
cfa-power/
├── _quarto.yml                     # Central Quarto manuscript configuration
├── index.qmd                       # Primary manuscript article
├── references.bib                  # BibTeX bibliography database
├── apa7ed.csl                      # APA 7th edition citation style
├── renv.lock                       # Reproducible package environment lockfile
│
├── Data/                           # Data directory
│   ├── README.md                   # Data documentation overview
│   ├── InputData/                  # Meta-analytic parameter matrices & metadata
│   │   ├── README.md
│   │   ├── popmodels_parameters.csv
│   │   └── Metadata/               # Sources guide, codebooks, derivations
│   ├── IntermediateData/           # 12 precomputed Monte Carlo simulation caches (.rds)
│   │   └── README.md
│   └── AnalysisData/               # Standard TIER folder (intentionally empty)
│       └── README.md
│
├── Scripts/                        # Code directory
│   ├── README.md                   # Scripts workflow overview
│   ├── AnalysisScripts/            # 6 Quarto computational companion notebooks
│   │   ├── README.md
│   │   ├── 01_population_models.qmd
│   │   ├── 02_analytical_power.qmd
│   │   ├── 03_simulation_ideal.qmd
│   │   ├── 04_simulation_robust.qmd
│   │   ├── 05_model_comparison.qmd
│   │   └── 06_posthoc.qmd
│   ├── DataAppendixScripts/        # Model syntax, helpers, cache tools, and build hooks
│   │   ├── README.md
│   │   ├── models.R
│   │   ├── helpers.R
│   │   ├── cache_utils.R
│   │   ├── cache_loader.R
│   │   ├── pre_render_cache.R
│   │   ├── post_render_figures.R
│   │   └── post_render_tables.R
│   └── ProcessingScripts/          # Standard TIER folder (intentionally empty)
│       └── README.md
│
├── Output/                         # Replication results directory
│   ├── README.md                   # Output directory overview
│   ├── Results/                    # Standalone empirical replication products
│   │   ├── README.md               # Complete mapping of figures and tables
│   │   ├── Figures/                # 21 high-resolution plots (.png)
│   │   └── Tables/                 # 14 publication-ready tables (.csv)
│   └── DataAppendixOutput/         # Supplementary data documentation
│       └── README.md
│
└── docs/                           # Compiled web manuscript deployed to GitHub Pages
```

---

## 3. Computational Environment

To guarantee full computational reproducibility across platforms, package versions are tracked using `renv`:

- **R Version**: `4.5.2`
- **Quarto CLI**: `1.9.37`
- **Key R Packages** (exact versions recorded in [`renv.lock`](renv.lock)):
  - `lavaan`: `0.6-21` (Structural equation modeling and CFA estimation)
  - `semPower`: `2.1.3` (Analytical power analysis and noncentral $\chi^2$ calculations)
  - `simsem`: `0.5-17` (Monte Carlo simulation for structural equation models)
  - `semPlot`: `1.1.8` (Path diagram visualizations)
  - `knitr`: `1.51` (Dynamic report generation and table rendering)
  - `here`: `1.0.2` (Project-relative path management)

---

## 4. Instructions for Replication

Replicating this project locally requires only cloning the repository, restoring the R library, and rendering the project.

### Step 1: Obtain the Repository
You can download the code using either Git or a direct ZIP download:

- **Option A (Git Clone)**:
  ```bash
  git clone https://github.com/phdpablo/cfa-power.git
  cd cfa-power
  ```
- **Option B (ZIP Download)**:
  Download the repository as a ZIP archive: [cfa-power-main.zip](https://github.com/phdpablo/cfa-power/archive/refs/heads/main.zip), and extract it locally.

### Step 2: Restore R Dependencies
Open the project folder in R or RStudio/Positron and run:

```r
# Restore the exact package environment recorded in renv.lock
renv::restore()
```

### Step 3: Render the Manuscript
Compile the entire project from the project root using the Quarto CLI:

```bash
quarto render
```

### What Happens During Rendering:
1. **Pre-render**: The script `Scripts/DataAppendixScripts/pre_render_cache.R` verifies that all simulation caches exist in `Data/IntermediateData/`.
2. **Execution**: Quarto renders the companion notebooks in `Scripts/AnalysisScripts/` and compiles the main manuscript `index.qmd` into `docs/`.
3. **Post-render**: 
   - `post_render_figures.R` mirrors all 21 generated plots into [`Output/Results/Figures/`](Output/Results/Figures/).
   - `post_render_tables.R` parses all rendered HTML tables and writes 14 clean datasets into [`Output/Results/Tables/`](Output/Results/Tables/).

> [!TIP]
> **Fast Rendering with Precomputed Caches**:  
> Running all Monte Carlo simulations from scratch (1,500 replications each across multiple sample size sequences) requires considerable computing time. The repository includes precomputed simulation models in `Data/IntermediateData/` (`.rds` files). Because of this caching architecture, `quarto render` finishes in **seconds** on a standard machine.
>
> If you wish to recompute all Monte Carlo simulations from scratch, simply delete the `.rds` files in `Data/IntermediateData/` prior to running `quarto render`.

---

## 5. Direct Access to Results (No Software Installation Needed)

If you only wish to inspect the empirical results without installing R or Quarto:
- Read the complete interactive publication online: [https://phdpablo.github.io/cfa-power/](https://phdpablo.github.io/cfa-power/)
- Browse the 14 standalone tables in CSV format: [`Output/Results/Tables/`](Output/Results/Tables/)
- View the 21 figures in high-resolution PNG format: [`Output/Results/Figures/`](Output/Results/Figures/)

---

## 6. Citation

If you use this tutorial, code, or simulation framework in your research, please cite:

```bibtex
@article{rogers2026cfapower,
  author    = {Rogers, Pablo},
  title     = {Power Analysis for Confirmatory Factor Analysis: A Practical Tutorial},
  subtitle  = {Analytical and Simulation-Based Approaches},
  year      = {2026},
  url       = {https://phdpablo.github.io/cfa-power/},
}
```

---

## 7. Declaration of AI and AI-Assisted Technologies

During the preparation and development of this replication repository and its accompanying documentation, the author utilized generative artificial intelligence (AI) and AI-assisted coding technologies (specifically Google Antigravity). These tools were employed for:
- Drafting, structuring, and standardizing repository documentation (including directory overviews, metadata catalogs, and replication instructions) in alignment with Project TIER Protocol 4.0 guidelines.
- Providing assistance in code refactoring, script optimization, and the programmatic automation of post-render hooks for figure synchronization and tabular data extraction.

In accordance with standard academic integrity and publication practices, all AI-generated contributions, script architectures, and documentation were thoroughly reviewed, edited, and verified by the author, who assumes full intellectual, empirical, and scientific responsibility for the final contents of this work.
