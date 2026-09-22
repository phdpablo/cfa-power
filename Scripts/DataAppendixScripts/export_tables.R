# ==============================================================================
# export_tables.R
# Exports all manuscript tables to Output/Results/Tables/*.csv (TIER Protocol 4.0)
# ==============================================================================

suppressPackageStartupMessages({
  library(here)
  library(simsem)
  library(semPower)
})

root_dir <- here::here()
tables_dir <- file.path(root_dir, "Output", "Results", "Tables")
dir.create(tables_dir, recursive = TRUE, showWarnings = FALSE)

source(file.path(root_dir, "Scripts", "DataAppendixScripts", "models.R"))
source(file.path(root_dir, "Scripts", "DataAppendixScripts", "helpers.R"))

cache_dir <- file.path(root_dir, "Data", "IntermediateData")

# Helper to write clean CSV without markdown escape characters
write_table_csv <- function(df, filename) {
  if (is.data.frame(df)) {
    for (col in names(df)) {
      if (is.character(df[[col]])) {
        df[[col]] <- gsub("\\\\~\\\\~", "~~", df[[col]])
        df[[col]] <- gsub("\\~\\~", "~~", df[[col]])
      }
    }
  }
  write.csv(df, file.path(tables_dir, filename), row.names = FALSE)
}

message("export_tables.R: Exporting tables to Output/Results/Tables/...")

# ------------------------------------------------------------------------------
# 1. Notebook 01: Population Models
# ------------------------------------------------------------------------------
csv_path <- file.path(root_dir, "Data", "InputData", "popmodels_parameters.csv")
if (file.exists(csv_path)) {
  csv <- read.csv(csv_path, quote = "", check.names = FALSE, stringsAsFactors = FALSE)
  names(csv) <- gsub('"', '', names(csv))
  param_transp <- as.data.frame(t(csv[-1]), stringsAsFactors = FALSE)
  names(param_transp) <- csv[[1]]
  param_transp <- cbind(parameters = names(csv)[-1], param_transp)
  row.names(param_transp) <- NULL
  
  write_table_csv(param_transp, "tbl-pop-summary.csv")
  
  Mode <- function(x) {
    ux <- unique(na.omit(x))
    ux[which.max(tabulate(match(na.omit(x), ux)))]
  }
  
  get_metrics <- function(model_name) {
    vals <- param_transp[[model_name]]
    params <- param_transp$parameters
    loadings <- as.numeric(vals[grepl("=~", params, fixed = TRUE)])
    is_cov <- grepl("~~", params, fixed = TRUE) & !grepl("^Q", params)
    lr <- strsplit(params[is_cov], "~~", fixed = TRUE)
    factor_cors <- as.numeric(vals[is_cov][vapply(lr, \(x) x[1] != x[2], logical(1))])
    is_res <- grepl("^Q.+~~Q.+$", params)
    lr_r <- strsplit(params[is_res], "~~", fixed = TRUE)
    residuals <- as.numeric(vals[is_res][vapply(lr_r, \(x) x[1] == x[2], logical(1))])
    q3q4 <- as.numeric(vals[params == "Q3~~Q4"])
    
    sprintf("%.2f", c(
      min(loadings, na.rm = TRUE), max(loadings, na.rm = TRUE),
      mean(loadings, na.rm = TRUE), Mode(factor_cors),
      min(residuals, na.rm = TRUE), max(residuals, na.rm = TRUE), q3q4
    ))
  }
  
  models <- c(popmodel = "Meta-analytic (popmodel)",
              naivemodel = "Naive (naivemodel)",
              optmodel = "Optimistic (optmodel)",
              h1model = "H1 (h1model)")
  metrics <- c("Loading Min", "Loading Max", "Mean Loading",
               "Factor Correlations", "Residual Min", "Residual Max",
               "Q3\u2013Q4 Correlation")
  
  pop_summary_t <- cbind(
    data.frame(Metric = metrics),
    setNames(data.frame(sapply(names(models), get_metrics)), models)
  )
  write_table_csv(pop_summary_t, "tbl-pop-comparison.csv")
}

# ------------------------------------------------------------------------------
# 2. Notebook 02: Analytical Power
# ------------------------------------------------------------------------------
df_model <- 245
ap_rmsea <- semPower::semPower.aPriori(
  effect = 0.05, effect.measure = "RMSEA",
  alpha = ALPHA, power = POWER, df = df_model, p = P
)
ap_popmodel <- semPower::semPower.powerLav(
  type = "a-priori", alpha = ALPHA, power = POWER,
  modelPop = h1model, modelH0 = analyzemodel, lavOptions = list(std.lv = TRUE)
)

safe_num <- function(x) if (length(x) == 0 || is.null(x)) NA else as.numeric(x)[1]

analytical_summary <- data.frame(
  Method = c("Model-free a priori (RMSEA = .05)", "Model-based global fit (h1model vs. saturated)"),
  `N Required` = c(safe_num(ap_rmsea$requiredN), safe_num(ap_popmodel$requiredN)),
  `Power` = c(round(safe_num(ap_rmsea$impliedPower), 4), round(safe_num(ap_popmodel$impliedPower), 4)),
  `Implied RMSEA` = c(round(safe_num(ap_rmsea$rmsea), 4), round(safe_num(ap_popmodel$rmsea), 4)),
  df = c(safe_num(ap_rmsea$df), safe_num(ap_popmodel$df)),
  check.names = FALSE
)
write_table_csv(analytical_summary, "tbl-analytical-summary.csv")

# ------------------------------------------------------------------------------
# 3. Notebook 03: Ideal Conditions
# ------------------------------------------------------------------------------
if (file.exists(file.path(cache_dir, "popmodel_ideal.rds")) &&
    file.exists(file.path(cache_dir, "h1model_ideal.rds"))) {
  popmodel_ideal <- readRDS(file.path(cache_dir, "popmodel_ideal.rds"))
  h1model_ideal  <- readRDS(file.path(cache_dir, "h1model_ideal.rds"))
  
  # tbl-power-cutoff-ideal
  power_ideal <- getPowerFit(h1model_ideal, nullObject = popmodel_ideal, alpha = ALPHA, nVal = 231, usedFit = FITS)
  cutoff_ideal <- getCutoff(popmodel_ideal, alpha = ALPHA, nVal = 231, usedFit = FITS)
  power_cutoff_ideal <- rbind(
    "Power" = as.numeric(power_ideal),
    "Cutoff" = as.numeric(cutoff_ideal[1, ])
  )
  colnames(power_cutoff_ideal) <- toupper(FITS)
  df_pci <- data.frame(Metric = rownames(power_cutoff_ideal), power_cutoff_ideal, check.names = FALSE)
  write_table_csv(df_pci, "tbl-power-cutoff-ideal.csv")
  
  # tbl-power-cutoff-traditional-ideal
  power_trad <- getPowerFit(h1model_ideal, RULE_OF_THUMB, alpha = ALPHA, nVal = 231, usedFit = FITS)
  power_df <- data.frame(
    "CFI" = round(as.numeric(power_trad["cfi"]), 3),
    "TLI" = round(as.numeric(power_trad["tli"]), 3),
    "RMSEA" = round(as.numeric(power_trad["rmsea"]), 3),
    "SRMR" = as.numeric(power_trad["srmr"]),
    check.names = FALSE
  )
  write_table_csv(power_df, "tbl-power-cutoff-traditional-ideal.csv")
  
  # tbl-param-estimate-ideal
  param_ideal <- summaryParam(h1model_ideal, alpha = ALPHA, digits = 3, detail = TRUE)
  param_subset <- param_ideal[, c("Rel Bias", "Rel SE Bias", "Coverage", "Power (Not equal 0)")]
  param_subset_df <- cbind(Parameter = rownames(param_subset), as.data.frame(param_subset), row.names = NULL)
  write_table_csv(param_subset_df, "tbl-param-estimate-ideal.csv")
  
  # tbl-power-n-ideal
  pow_h1 <- getPower(h1model_ideal, alpha = ALPHA)
  n_h1 <- findPower(pow_h1, "N", 0.80)
  n_df <- data.frame(Parameter = names(n_h1), N = as.integer(n_h1), stringsAsFactors = FALSE)
  n_df <- subset(n_df, is.finite(N))
  write_table_csv(n_df, "tbl-power-n-ideal.csv")
}

if (file.exists(file.path(cache_dir, "naivemodel_ideal.rds"))) {
  naivemodel_ideal <- readRDS(file.path(cache_dir, "naivemodel_ideal.rds"))
  param_naive <- summaryParam(naivemodel_ideal, alpha = ALPHA, digits = 3, detail = TRUE)
  param_subset_naive <- as.data.frame(param_naive[, c("Rel Bias", "Rel SE Bias", "Coverage", "Power (Not equal 0)")])
  pow_naive <- getPower(naivemodel_ideal, alpha = ALPHA)
  n_naive <- findPower(pow_naive, "N", 0.80)
  param_subset_naive$N <- as.integer(n_naive[rownames(param_subset_naive)])
  filt_naive <- subset(param_subset_naive, is.finite(N) & N > 60)
  filt_naive <- cbind(Parameter = rownames(filt_naive), filt_naive, row.names = NULL)
  names(filt_naive)[names(filt_naive) == "N"] <- "Required N"
  write_table_csv(filt_naive, "tbl-power-n-naive.csv")
}

if (file.exists(file.path(cache_dir, "optmodel_ideal.rds"))) {
  optmodel_ideal <- readRDS(file.path(cache_dir, "optmodel_ideal.rds"))
  param_opt <- summaryParam(optmodel_ideal, alpha = ALPHA, digits = 3, detail = TRUE)
  param_subset_opt <- as.data.frame(param_opt[, c("Rel Bias", "Rel SE Bias", "Coverage", "Power (Not equal 0)")])
  pow_opt <- getPower(optmodel_ideal, alpha = ALPHA)
  n_opt <- findPower(pow_opt, "N", 0.80)
  param_subset_opt$N <- as.integer(n_opt[rownames(param_subset_opt)])
  filt_opt <- subset(param_subset_opt, is.finite(N) & N > 60)
  filt_opt <- cbind(Parameter = rownames(filt_opt), filt_opt, row.names = NULL)
  names(filt_opt)[names(filt_opt) == "N"] <- "Required N"
  write_table_csv(filt_opt, "tbl-power-n-opt.csv")
}

# ------------------------------------------------------------------------------
# 4. Notebook 04: Robust Conditions (Missing & Non-normal)
# ------------------------------------------------------------------------------
if (file.exists(file.path(cache_dir, "popmodel_miss.rds")) &&
    file.exists(file.path(cache_dir, "h1model_miss.rds"))) {
  popmodel_miss <- readRDS(file.path(cache_dir, "popmodel_miss.rds"))
  h1model_miss  <- readRDS(file.path(cache_dir, "h1model_miss.rds"))
  power_miss <- getPowerFit(h1model_miss, nullObject = popmodel_miss, alpha = ALPHA, nVal = 359, usedFit = FITS)
  cutoff_miss <- getCutoff(popmodel_miss, alpha = ALPHA, nVal = 359, usedFit = FITS)
  p_cut_miss <- rbind("Power" = as.numeric(power_miss), "Cutoff" = as.numeric(cutoff_miss[1, ]))
  colnames(p_cut_miss) <- toupper(FITS)
  df_pcm <- data.frame(Metric = rownames(p_cut_miss), p_cut_miss, check.names = FALSE)
  write_table_csv(df_pcm, "tbl-power-cutoff-missing.csv")
}

if (file.exists(file.path(cache_dir, "popmodel_nnorm.rds")) &&
    file.exists(file.path(cache_dir, "h1model_nnorm.rds"))) {
  popmodel_nnorm <- readRDS(file.path(cache_dir, "popmodel_nnorm.rds"))
  h1model_nnorm  <- readRDS(file.path(cache_dir, "h1model_nnorm.rds"))
  power_nnorm <- getPowerFit(h1model_nnorm, nullObject = popmodel_nnorm, alpha = ALPHA, nVal = 228, usedFit = FITS)
  cutoff_nnorm <- getCutoff(popmodel_nnorm, alpha = ALPHA, nVal = 228, usedFit = FITS)
  p_cut_nnorm <- rbind("Power" = as.numeric(power_nnorm), "Cutoff" = as.numeric(cutoff_nnorm[1, ]))
  colnames(p_cut_nnorm) <- toupper(FITS)
  df_pcn <- data.frame(Metric = rownames(p_cut_nnorm), p_cut_nnorm, check.names = FALSE)
  write_table_csv(df_pcn, "tbl-power-cutoff-nnorm.csv")
}

# ------------------------------------------------------------------------------
# 5. Notebook 05: Model Comparison / Fixed N
# ------------------------------------------------------------------------------
if (file.exists(file.path(cache_dir, "popmodel_fixed.rds")) &&
    file.exists(file.path(cache_dir, "h1model_fixed.rds"))) {
  popmodel_fixed <- readRDS(file.path(cache_dir, "popmodel_fixed.rds"))
  h1model_fixed  <- readRDS(file.path(cache_dir, "h1model_fixed.rds"))
  power_fixed <- getPowerFit(h1model_fixed, nullObject = popmodel_fixed, alpha = ALPHA, usedFit = FITS)
  cutoff_fixed <- getCutoff(popmodel_fixed, alpha = ALPHA, usedFit = FITS)
  p_cut_fix <- rbind("Power" = as.numeric(power_fixed[FITS]), "Cutoff" = as.numeric(cutoff_fixed[1, FITS]))
  colnames(p_cut_fix) <- toupper(FITS)
  df_pcf <- data.frame(Metric = rownames(p_cut_fix), p_cut_fix, check.names = FALSE)
  write_table_csv(df_pcf, "tbl-power-cutoff-fixed.csv")
  
  power_traditional <- getPowerFit(h1model_fixed, RULE_OF_THUMB, alpha = ALPHA, usedFit = FITS)
  power_traditional_tbl <- t(as.data.frame(power_traditional))
  colnames(power_traditional_tbl) <- toupper(names(power_traditional))
  df_pctf <- data.frame(Metric = "Power", power_traditional_tbl, check.names = FALSE)
  write_table_csv(df_pctf, "tbl-power-cutoff-traditional-fixed.csv")
}

# ------------------------------------------------------------------------------
# 6. Notebook 06: Post Hoc
# ------------------------------------------------------------------------------
if (file.exists(file.path(cache_dir, "realmodel_null.rds")) &&
    file.exists(file.path(cache_dir, "h1model_alt.rds"))) {
  realmodel_null <- readRDS(file.path(cache_dir, "realmodel_null.rds"))
  h1model_alt    <- readRDS(file.path(cache_dir, "h1model_alt.rds"))
  posthoc_pow <- getPowerFit(h1model_alt, nullObject = realmodel_null, alpha = ALPHA, usedFit = FITS)
  df_php <- data.frame(Metric = "Power", as.data.frame(as.list(posthoc_pow[FITS])), check.names = FALSE)
  names(df_php)[-1] <- toupper(FITS)
  write_table_csv(df_php, "tbl-posthoc-power.csv")
}

message("export_tables.R: Successfully exported all tables to Output/Results/Tables/")
