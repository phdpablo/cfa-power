# =============================================================================
# helpers.R — Shared functions and constants for CFA Power Analysis Tutorial
# =============================================================================
# Source this file from analysis modules (e.g., in Scripts/AnalysisScripts/):
#   source(here("Scripts", "DataAppendixScripts", "helpers.R"))
# =============================================================================

# --- Packages ----------------------------------------------------------------
suppressPackageStartupMessages({
  library(lavaan)   # For structural equation modeling (SEM)
  library(semTools) # For SEM tools (semPower-compatible functions)
  library(semPower) # For power analysis for SEM
  library(semPlot)  # For plotting SEM diagrams
  library(simsem)   # For simulation and power analysis for SEM
  library(MASS)     # For miscellaneous statistical functions
  library(ggplot2)  # For data visualization
  library(dplyr)    # For data manipulation
  library(here)     # For creating reproducible file paths
  library(knitr)    # For creating reproducible reports
  library(quantreg) # For quantile regression
  library(parallel) # For parallel computing
})
# --- Configuration -----------------------------------------------------------

#' Monte Carlo Simulation.
REP <- 1000 # Number of replications for final analysis.
SEQ1 <- rep(51:350, each = 5) # Sample size sequence for varying-N simulations (5 per N).
SEQ2 <- rep(201:500, each = 5) # Sample size sequence for varying-N simulations (5 per N).
P_MCAR <- 0.10 # Proportion of missing completely at random data.
N_TARGET <- 250 # Target sample size for fixed N simulations.

#' Random seed for reproducibility across all simulations: simsem default is 123321.
SEED <- 123321

#' Significance level for hypothesis tests.
ALPHA <- 0.05

#' Target power level for a priori analyses.
POWER <- 0.80

#' Number of observed indicators in the CFA model (p).
P <- 24

#' Fit indices to be used in the analysis.
FITS <- c("rmsea", "srmr", "cfi", "tli") # Standard versions of fit indices for comparability with existing literature
FITS_ROB <- c("rmsea.robust", "srmr", "cfi.robust", "tli.robust") # Robust versions of cfi/tli is not sensitive for discrimination simsem power analysis in this context, but you can use them if you want to be consistent with the robust versions of estimator.

#' Rule-of-thumb cutoffs for global fit indices.
RULE_OF_THUMB <- c(
  rmsea = 0.06,
  cfi = 0.95,
  tli = 0.95,
  srmr = 0.06
)

#' Simulation distribution for non-normal data (skewness and kurtosis values).
dist <- bindDist(
  skewness = seq(-1, 1, length.out = 24),
  kurtosis = seq(1, 2, length.out = 24)
)


# --- Global Session Configuration --------------------------------------------
options(max.print = 1e6)

# --- DRY Functions ----------------------------------------------------------------

# Helper functions for plotting SEM diagrams with semPlot, using consistent styling across all models.

# plot_bw: Black-and-white version of the path diagram, with standardized estimates as edge labels.
plot_bw <- function(model) {
  plot_model <- semPlot::semPlotModel(model)

  semPlot::semPaths(
    plot_model,
    #whatLabels = "est",
    style = "lisrel",
    layout = "circle",
    intercepts = FALSE,
    thresholds = FALSE,
    residuals = FALSE,
    edge.label.cex = 1.5,
    label.cex = 2,
    weighted = FALSE,
    edge.color = "black",
    mar = c(2, 1.5, 2, 1.5)
  )
}

# Colors for latent variable groups: psychological (psy), physical (phy), social (scl), and environmental (env). The colors are chosen to be visually distinct and consistent across all diagrams, with a neutral ink color for edges and labels.
cols <- c(
  psy = "#F18C22",
  phy = "#87CBCC",
  scl = "#a0b7d2",
  env = "#d8da54"
)

ink <- "#0D232C"

# plot_color: Circle layout version of the path diagram, with standardized estimates as edge labels and color coding for latent variable groups.
plot_color <- function(model) {
  plot_model <- semPlot::semPlotModel(model)

  semPlot::semPaths(
    plot_model,
    whatLabels = "est",
    style = "lisrel",
    layout = "circle",
    intercepts = FALSE,
    thresholds = FALSE,
    residuals = FALSE,
    groups = "latents",
    color = cols,
    edge.color = ink,
    border.color = ink,
    label.color = ink,
    sizeLat = 9,
    sizeMan = 5,
    sizeMan2 = 5,
    label.cex = 1.5,
    edge.label.cex = 1.2,
    edge.label.bg = TRUE,
    weighted = FALSE,
    mar = c(2, 1.5, 2, 1.5)
  )
}

# plot_free: Color layout version of the path diagram, with standardized estimates as edge labels and color coding for latent variable groups, but without edge labels to focus on the structure rather than the specific parameter values.
plot_free <- function(model) {
  plot_model <- semPlot::semPlotModel(model)

  semPlot::semPaths(
    plot_model,
    #whatLabels = "est",
    style = "lisrel",
    layout = "circle",
    intercepts = FALSE,
    thresholds = FALSE,
    residuals = FALSE,
    groups = "latents",
    color = cols,
    edge.color = ink,
    border.color = ink,
    label.color = ink,
    sizeLat = 9,
    sizeMan = 5,
    sizeMan2 = 5,
    label.cex = 1.5,
    edge.label.cex = 1.2,
    edge.label.bg = TRUE,
    weighted = FALSE,
    mar = c(2, 1.5, 2, 1.5)
  )
}

# --- semPower Output Decoupling Helpers ----------------------------------------

# Helper to format numeric values with appropriate precision or scientific notation
format_metric_val <- function(x, digits = 3) {
  if (is.null(x) || length(x) == 0 || is.na(x)) return(NA_character_)
  if (abs(x) < 1e-4 && x > 0) return(formatC(x, format = "e", digits = 2))
  formatC(x, format = "f", digits = digits)
}

#' Extract and tidy analytical power parameters from semPower objects.
#' Compatible with both model-free (semPower.aPriori, semPower.postHoc) and
#' model-based (semPower.powerLav) result objects.
tidy_sempower <- function(object) {
  is_apriori <- inherits(object, "semPower.aPriori") || identical(object[["type"]], "a-priori")
  n_label <- if (is_apriori) "Required sample size" else "Observed sample size"
  n_val   <- if (is_apriori) object[["requiredN"]] else object[["N"]]
  ncp_val <- if (is_apriori) object[["impliedNCP"]] else object[["ncp"]]
  beta_val  <- if (is_apriori) object[["impliedBeta"]] else object[["beta"]]
  power_val <- if (is_apriori) object[["impliedPower"]] else object[["power"]]

  res <- list(
    c("Population discrepancy", "$F_0$", format_metric_val(object[["fmin"]])),
    c("Root mean square error of approximation", "$\\text{RMSEA}$", format_metric_val(object[["rmsea"]])),
    c("McDonald centrality index", "$Mc$", format_metric_val(object[["mc"]])),
    if (!is.null(object[["gfi"]])) c("Goodness-of-fit index", "$\\text{GFI}$", format_metric_val(object[["gfi"]])),
    if (!is.null(object[["agfi"]])) c("Adjusted goodness-of-fit index", "$\\text{AGFI}$", format_metric_val(object[["agfi"]])),
    if (!is.null(object[["srmr"]])) c("Standardized root mean square residual", "$\\text{SRMR}$", format_metric_val(object[["srmr"]])),
    if (!is.null(object[["cfi"]])) c("Comparative fit index", "$\\text{CFI}$", format_metric_val(object[["cfi"]])),
    c("Degrees of freedom", "$df$", as.character(object[["df"]])),
    c(n_label, "$N$", as.character(n_val)),
    c("Critical chi-square", "$\\chi^2_{\\text{crit}}$", format_metric_val(object[["chiCrit"]])),
    c("Noncentrality parameter", "$\\lambda$", format_metric_val(ncp_val)),
    c("Significance level (alpha)", "$\\alpha$", format_metric_val(object[["alpha"]])),
    c("Type II error rate (beta)", "$\\beta$", format_metric_val(beta_val, digits = 4)),
    c("Statistical power", "$1 - \\beta$", if (power_val > 0.9999) "> 0.9999" else format_metric_val(power_val, digits = 4))
  )
  res <- do.call(rbind, res[!sapply(res, is.null)])
  colnames(res) <- c("Metric", "Symbol", "Value")
  as.data.frame(res, stringsAsFactors = FALSE)
}

#' Render an academic knitr::kable table for semPower analytical power results.
table_sempower <- function(object, align = c("l", "c", "r")) {
  df_tidy <- tidy_sempower(object)
  knitr::kable(df_tidy, align = align)
}

#' Plot central vs. non-central chi-square distribution from semPower object without console text.
plot_sempower <- function(object, linewidth = 1.2, show_labels = TRUE) {
  ncp <- if (!is.null(object[["impliedNCP"]])) object[["impliedNCP"]] else object[["ncp"]]
  semPower::semPower.showPlot(
    chiCrit    = object[["chiCrit"]],
    ncp        = ncp,
    df         = object[["df"]],
    linewidth  = linewidth,
    showLabels = show_labels
  )
}

