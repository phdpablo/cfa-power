# ==============================================================================
# post_render_figures.R
# Synchronize figures for Quarto manuscript notebook preview HTML pages
# ==============================================================================

root_dir <- getwd()
scripts_dir <- file.path(root_dir, "Scripts", "AnalysisScripts")
docs_scripts_dir <- file.path(root_dir, "docs", "Scripts", "AnalysisScripts")
index_figs_dir <- file.path(root_dir, "docs", "index_files", "figure-html")
out_figs_dir <- file.path(root_dir, "Output", "Results", "Figures")
dir.create(out_figs_dir, recursive = TRUE, showWarnings = FALSE)

if (!dir.exists(docs_scripts_dir)) {
  # docs directory not created yet, nothing to do
  quit(save = "no", status = 0)
}

preview_files <- list.files(docs_scripts_dir, pattern = "-preview\\.html$", full.names = TRUE)

if (length(preview_files) == 0) {
  quit(save = "no", status = 0)
}

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
  target_src_dir  <- file.path(scripts_dir, paste0(nb_name, "_files"), "figure-html")
  
  dir.create(target_docs_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(target_src_dir,  recursive = TRUE, showWarnings = FALSE)
  
  for (ref in found_refs) {
    img_name <- basename(ref)
    target_docs_file <- file.path(target_docs_dir, img_name)
    target_src_file  <- file.path(target_src_dir,  img_name)
    
    # 1. If it exists in src, copy to docs
    if (file.exists(target_src_file)) {
      if (!file.exists(target_docs_file)) {
        file.copy(target_src_file, target_docs_file, overwrite = TRUE)
      }
    } else if (file.exists(target_docs_file)) {
      # 2. If it exists in docs, ensure it is mirrored in src
      file.copy(target_docs_file, target_src_file, overwrite = TRUE)
    } else {
      # 3. Check if it exists in Scripts/AnalysisScripts/<nb_name>_files/figure-ipynb/
      ipynb_cand <- file.path(scripts_dir, paste0(nb_name, "_files"), "figure-ipynb", img_name)
      if (file.exists(ipynb_cand)) {
        file.copy(ipynb_cand, target_docs_file, overwrite = TRUE)
        file.copy(ipynb_cand, target_src_file,  overwrite = TRUE)
      } else {
        # 4. Check in docs/index_files/figure-html/
        fig_stem <- sub("-\\d+\\.[a-zA-Z]+$", "", img_name)
        matching_index <- index_files[grepl(nb_name, index_files, fixed = TRUE) & grepl(fig_stem, index_files, fixed = TRUE)]
        
        if (length(matching_index) > 0) {
          # Pick the last output file (output-2 if available, else output-1)
          chosen <- tail(matching_index, 1)
          file.copy(chosen, target_docs_file, overwrite = TRUE)
          file.copy(chosen, target_src_file,  overwrite = TRUE)
        }
      }
    }
    
    # 5. Mirror to Output/Results/Figures (TIER Protocol 4.0)
    if (file.exists(target_docs_file)) {
      file.copy(target_docs_file, file.path(out_figs_dir, img_name), overwrite = TRUE)
    }
  }
}

message("post_render_figures.R: Successfully synchronized all notebook preview figures and Output/Results/Figures/.")
