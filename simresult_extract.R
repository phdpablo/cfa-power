dir.create("cache", showWarnings = FALSE, recursive = TRUE)

objs <- ls(envir = .GlobalEnv)

sim_objs <- objs[
  vapply(
    objs,
    function(nm) inherits(get(nm, envir = .GlobalEnv), "SimResult"),
    logical(1)
  )
]

invisible(
  lapply(sim_objs, function(nm) {
    saveRDS(
      get(nm, envir = .GlobalEnv),
      file = file.path("cache", paste0(nm, ".rds"))
    )
  })
)
