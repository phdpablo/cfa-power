#' Cache or Execute an Expression
#'
#' Manages a two-level cache (memory and disk) for potentially expensive computations.
#' If the object already exists in the target environment, it returns it directly.
#' Otherwise, if a cached `.rds` file exists on disk, it loads it. If neither exists,
#' it evaluates the provided expression, saves the result to disk as an `.rds` file,
#' assigns it to the target environment, and returns the computed value.
#'
#' @param name Character string giving the name of the cached object and base filename.
#' @param expr An unquoted expression to be evaluated if the cached object/file is missing.
#' @param dir Character string indicating the directory where the cache `.rds` file is stored.
#'   Defaults to `here::here("Data", "IntermediateData")` if the `{here}` package is available,
#'   otherwise falls back to `"Data/IntermediateData"`.
#' @param envir An environment where the cached object will be looked up and assigned.
#'   Defaults to `parent.frame()`.
#'
#' @return The evaluated or loaded object value.
cache_or_run <- function(
  name,
  expr,
  dir = if (requireNamespace("here", quietly = TRUE)) here::here("Data", "IntermediateData") else "Data/IntermediateData",
  envir = parent.frame()
) {
  # Ensure the target directory exists without failing if it already does
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)

  # Full path to the cached .rds file on disk
  path <- file.path(dir, paste0(name, ".rds"))

  # 1. In-memory check: if the object already exists in the target environment, return it
  if (exists(name, envir = envir, inherits = FALSE)) {
    return(get(name, envir = envir, inherits = FALSE))
  }

  # 2. Disk cache check: if .rds file exists, load it; otherwise evaluate expr and save
  if (file.exists(path)) {
    value <- readRDS(path)
  } else {
    # Evaluate expression in the caller's environment
    value <- eval.parent(substitute(expr))
    # Persist the result to disk
    saveRDS(value, path)
  }

  # Assign the resulting value to the specified environment
  assign(name, value, envir = envir)
  value
}

