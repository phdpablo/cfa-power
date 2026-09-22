# =============================================================================
# helpers.R — Shared functions and constants for CFA Power Analysis Tutorial
# =============================================================================
# Source this file from analysis modules (e.g., in Scripts/AnalysisScripts/):
#   source(here("Scripts", "DataAppendixScripts", "helpers.R"))
# =============================================================================

# --- Packages ----------------------------------------------------------------

library(lavaan)
library(semTools)
library(semPower)
library(semPlot)
library(simsem)
library(MASS)
library(ggplot2)
library(dplyr)
library(here)
library(knitr)
library(quantreg)
library(parallel)

# --- Configuration -----------------------------------------------------------

#' Monte Carlo Simulation.
REP <- 1000 # Number of replications for final analysis.
SEQ1 <- rep(51:350, each = 5) # Sample size sequence for varying-N simulations (5 per N).
SEQ2 <- rep(201:500, each = 5) # Sample size sequence for varying-N simulations (5 per N).

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
