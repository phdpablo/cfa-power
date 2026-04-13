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
library(simsem)
library(MASS)
library(ggplot2)
library(dplyr)
library(here)
library(knitr)
library(quantreg)
library(snow)

# --- Configuration -----------------------------------------------------------

#' Monte Carlo Simulation.
REP <- 1000 # Number of replications for final analysis.
SEQ <- 51:350 # Sample size sequence for varying-N simulations [or seq(51, 350, 1)]

#' Random seed for reproducibility across all simulations: simsem default is 123321.
SEED <- 123321

#' Significance level for hypothesis tests.
ALPHA <- 0.05

#' Target power level for a priori analyses.
POWER <- 0.80

#' Number of observed indicators in the CFA model (p).
P <- 24

#' Fit indices to be used in the analysis.
FITS <- c("rmsea", "srmr", "cfi", "tli")
FITS_ROB <- c("rmsea.robust", "srmr", "cfi.robust", "tli.robust")

#' Rule-of-thumb cutoffs for global fit indices.
RULE_OF_THUMB <- c(
  rmsea = 0.06,
  cfi = 0.95,
  tli = 0.95,
  srmr = 0.06
)

# --- Global Session Configuration --------------------------------------------
options(max.print = 1e6)
