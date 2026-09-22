# ==============================================================================
# post_render_figures.R
# Universal Figure Synchronizer for Quarto Manuscripts (TIER Protocol 4.0)
# Synchronizes preview images in docs/, mirrors all figures to Output/Results/Figures/,
# and cleans up temporary build artifacts (*_files) from Scripts/AnalysisScripts/.
# Runs in Base R with zero external dependencies (--vanilla).
# ==============================================================================

root_dir <- getwd()
src_scripts_dir <- file.path(root_dir, "Scripts", "AnalysisScripts")
docs_scripts_dir <- file.path(root_dir, "docs", "Scripts", "AnalysisScripts")
index_figs_dir <- file.path(root_dir, "docs", "index_files", "figure-html")
out_figs_dir <- file.path(root_dir, "Output", "Results", "Figures")

dir.create(out_figs_dir, recursive = TRUE, showWarnings = FALSE)

if (dir.exists(docs_scripts_dir)) {
  preview_files <- list.files(docs_scripts_dir, pattern = "-preview\\.html$", full.names = TRUE)
  index_files <- if (dir.exists(index_figs_dir)) list.files(index_figs_dir, full.names = TRUE) else character(0)

  for (pf in preview_files) {
    nb_name <- sub("-preview\\.html$", "", basename(pf))
    lines <- readLines(pf, warn = FALSE)
    
    # Match all <img src="<nb_name>_files/figure-html/<img_name>.png">
    pattern <- sprintf('%s_files/figure-html/([^"\' >]+)', nb_name)
    matches <- regmatches(lines, gregexpr(pattern, lines))
    found_refs <- unique(unlist(matches))
    
    if (length(found_refs) == 0) next
    
    target_docs_dir <- file.path(docs_scripts_dir, paste0(nb_name, "_files"), "figure-html")
    dir.create(target_docs_dir, recursive = TRUE, showWarnings = FALSE)
    
    for (ref in found_refs) {
      img_name <- basename(ref)
      target_docs_file <- file.path(target_docs_dir, img_name)
      
      # 1. If not already in docs preview folder, find it in index_files
      if (!file.exists(target_docs_file)) {
        fig_stem <- sub("-\\d+\\.[a-zA-Z]+$", "", img_name)
        matching_index <- index_files[grepl(nb_name, index_files, fixed = TRUE) & grepl(fig_stem, index_files, fixed = TRUE)]
        
        if (length(matching_index) > 0) {
          chosen <- tail(matching_index, 1)
          file.copy(chosen, target_docs_file, overwrite = TRUE)
        } else {
          exact_index <- index_files[basename(index_files) == img_name]
          if (length(exact_index) > 0) {
            file.copy(exact_index[1], target_docs_file, overwrite = TRUE)
          }
        }
      }
      
      # 2. Mirror to Output/Results/Figures (TIER Protocol 4.0)
      if (file.exists(target_docs_file)) {
        file.copy(target_docs_file, file.path(out_figs_dir, img_name), overwrite = TRUE)
      }
    }
  }
}

# ==============================================================================
# 3. Clean up intermediate build artifact directories left in Scripts/AnalysisScripts/
# Quarto's internal notebook renderer temporarily writes *_files/figure-ipynb
# to the source directory during rendering. We purge them here to ensure
# Scripts/AnalysisScripts/ remains strictly clean.
# ==============================================================================
leftovers <- list.files(src_scripts_dir, pattern = "_files$", full.names = TRUE)
if (length(leftovers) > 0) {
  unlink(leftovers, recursive = TRUE)
}

message("post_render_figures.R: Successfully synchronized figures and cleaned Scripts/AnalysisScripts/.")
