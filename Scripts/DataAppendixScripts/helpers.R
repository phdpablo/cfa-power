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

# --- Configuration -----------------------------------------------------------

#' Number of Monte Carlo replications.
#' Use 50 for local development; increase to >= 1000 for production results.
N_REP <- 50

#' Random seed for reproducibility across all simulations.
SEED <- 123456

#' Significance level for hypothesis tests.
ALPHA <- 0.05

#' Target power level for a priori analyses.
POWER <- 0.80

#' Number of observed indicators in the CFA model (p).
P <- 24

#' Sample size in the WHOQOL-BREF empirical dataset (Rogers, 2022).
N_EMPIRICAL <- 1047

#' Rule-of-thumb cutoffs for global fit indices.
RULE_OF_THUMB <- c(
  rmsea = 0.06,
  cfi = 0.95,
  tli = 0.95,
  srmr = 0.06
)

#' Sample size sequence for varying-N simulations.
N_SEQ <- seq(100, 1000, 50)

# --- Global Session Configuration --------------------------------------------

options(max.print = 1e6)
set.seed(SEED)

# --- Formatting helpers ------------------------------------------------------

#' Format fit indices from a lavaan fitted object into a single-row data.frame
#'
#' @param fit A lavaan fitted object.
#' @param indices Character vector of fit measure names
#'   (defaults to common global fit indices).
#' @return A single-row data.frame with formatted values.
format_fit <- function(
  fit,
  indices = c(
    "chisq",
    "df",
    "pvalue",
    "cfi",
    "tli",
    "rmsea",
    "rmsea.ci.lower",
    "rmsea.ci.upper",
    "srmr"
  )
) {
  fi <- lavaan::fitmeasures(fit, indices)
  data.frame(
    `χ²` = round(fi["chisq"], 2),
    df = fi["df"],
    p = round(fi["pvalue"], 3),
    CFI = round(fi["cfi"], 3),
    TLI = round(fi["tli"], 3),
    RMSEA = round(fi["rmsea"], 3),
    `RMSEA 90% CI` = paste0(
      "[",
      round(fi["rmsea.ci.lower"], 3),
      ", ",
      round(fi["rmsea.ci.upper"], 3),
      "]"
    ),
    SRMR = round(fi["srmr"], 3),
    check.names = FALSE
  )
}

#' Format simsem summaryParam output, filtering out threshold parameters
#'
#' @param sim_obj A simsem result object.
#' @return A data.frame with columns: Parameter, Power, Coverage,
#'   Rel Bias, Rel SE Bias.
format_sim_params <- function(sim_obj) {
  sp <- simsem::summaryParam(sim_obj, detail = TRUE, digits = 3)
  sp_df <- as.data.frame(sp)
  sp_df$Parameter <- rownames(sp)
  # Filter out threshold parameters (contain "|t")
  sp_df <- sp_df[!grepl("\\|t", sp_df$Parameter), ]
  # Select relevant columns (names may vary by simsem version)
  cols_of_interest <- c("Parameter")
  power_col <- grep("Power", names(sp_df), value = TRUE)
  cover_col <- grep("Coverage", names(sp_df), value = TRUE)
  bias_col <- grep("Rel Bias", names(sp_df), value = TRUE)
  se_col <- grep("Rel SE Bias", names(sp_df), value = TRUE)
  sp_df[, c("Parameter", power_col, cover_col, bias_col, se_col)]
}

#' Run a simsem simulation with standard arguments and suppressed output
#'
#' @param nRep Number of replications (NULL for varying N).
#' @param n Sample size(s). A scalar or a vector (for varying-N designs).
#' @param model Analysis model (lavaan syntax string).
#' @param generate Population/generating model (lavaan syntax string or
#'   fitted lavaan object).
#' @param ... Additional arguments passed to \code{simsem::sim()}
#'   (e.g., \code{pmMCAR = .10}).
#' @return A simsem result object.
run_sim <- function(nRep, n, model, generate, ...) {
  invisible(capture.output(
    result <- simsem::sim(
      nRep = nRep,
      n = n,
      model = model,
      generate = generate,
      lavaanfun = "cfa",
      std.lv = TRUE,
      seed = SEED,
      ...
    )
  ))
  result
}

#' Build a tidy power-by-N table for fit indices from a varying-N simulation
#'
#' @param sim_obj A simsem result object from a varying-N simulation.
#' @param n_values Numeric vector of N values to evaluate.
#' @param cutoff Named numeric vector of fit index cutoffs.
#' @return A data.frame with columns N and one column per fit index.
extract_fit_power_curve <- function(
  sim_obj,
  n_values = N_SEQ,
  cutoff = RULE_OF_THUMB
) {
  results <- lapply(n_values, function(nv) {
    pf <- tryCatch(
      simsem::getPowerFit(sim_obj, cutoff = cutoff, nVal = nv),
      error = function(e) setNames(rep(NA, length(cutoff)), names(cutoff))
    )
    c(N = nv, pf)
  })
  do.call(rbind, lapply(results, function(x) as.data.frame(t(x))))
}
