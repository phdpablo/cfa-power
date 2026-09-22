cache_or_run <- function(
  name,
  expr,
  dir = if (requireNamespace("here", quietly = TRUE)) here::here("Data", "IntermediateData") else "Data/IntermediateData",
  envir = parent.frame()
) {
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)

  path <- file.path(dir, paste0(name, ".rds"))

  if (exists(name, envir = envir, inherits = FALSE)) {
    return(get(name, envir = envir, inherits = FALSE))
  }

  if (file.exists(path)) {
    value <- readRDS(path)
  } else {
    value <- eval.parent(substitute(expr))
    saveRDS(value, path)
  }

  assign(name, value, envir = envir)
  value
}
