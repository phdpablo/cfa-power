csv <- read.csv(
  "Data/InputData/popmodels_parameters.csv",
  quote = "",
  check.names = FALSE,
  stringsAsFactors = FALSE
)

names(csv) <- gsub('"', '', names(csv))

param_transp <- as.data.frame(t(csv[-1]), stringsAsFactors = FALSE)
names(param_transp) <- csv[[1]]
param_transp <- cbind(parameters = names(csv)[-1], param_transp)
row.names(param_transp) <- NULL

Mode <- function(x) {
  ux <- unique(na.omit(x))
  ux[which.max(tabulate(match(na.omit(x), ux)))]
}

get_metrics <- function(model_name) {
  vals <- param_transp[[model_name]]
  params <- param_transp$parameters
  
  # Loadings
  loadings <- as.numeric(vals[grepl("=~", params)])
  loading_min <- min(loadings, na.rm = TRUE)
  loading_max <- max(loadings, na.rm = TRUE)
  loading_mean <- mean(loadings, na.rm = TRUE)
  
  # Factor correlations: "~~" but not starting with "Q", and left != right
  is_cov <- grepl("~~", params) & !grepl("Q", params)
  # Filter left != right
  left_right <- strsplit(params[is_cov], "~~")
  is_diff <- sapply(left_right, function(x) x[1] != x[2])
  factor_cors <- as.numeric(vals[is_cov][is_diff])
  factor_cor_mode <- Mode(factor_cors)
  
  # Residuals: "Q.*~~Q.*" where left == right
  is_res <- grepl("Q.*~~Q.*", params)
  left_right_res <- strsplit(params[is_res], "~~")
  is_same_res <- sapply(left_right_res, function(x) x[1] == x[2])
  residuals <- as.numeric(vals[is_res][is_same_res])
  residual_min <- min(residuals, na.rm = TRUE)
  residual_max <- max(residuals, na.rm = TRUE)
  
  # Q3-Q4 Correlation
  q3q4 <- as.numeric(vals[params == "Q3~~Q4"])
  
  c(
    sprintf("%.2f", loading_min),
    sprintf("%.2f", loading_max),
    sprintf("%.2f", loading_mean),
    sprintf("%.2f", factor_cor_mode),
    sprintf("%.2f", residual_min),
    sprintf("%.2f", residual_max),
    sprintf("%.2f", q3q4)
  )
}

models <- c("popmodel", "naivemodel", "optmodel", "h1model")
model_names <- c("Meta-analytic (popmodel)", "Naive (naivemodel)", "Optimistic (optmodel)", "H1 (h1model)")

res <- sapply(models, get_metrics)
pop_summary <- data.frame(
  Model = model_names,
  `Loading Min` = res[1, ],
  `Loading Max` = res[2, ],
  `Mean Loading` = res[3, ],
  `Factor Correlations` = res[4, ],
  `Residual Min` = res[5, ],
  `Residual Max` = res[6, ],
  `Q3-Q4 Correlation` = res[7, ],
  check.names = FALSE
)

print(pop_summary)
