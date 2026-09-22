# ==============================================================================
# post_render_tables.R
# Universal Table Exporter for Quarto Manuscripts (TIER Protocol 4.0)
# Automatically extracts all 'tbl-*' tables from Quarto HTML outputs to CSV.
# Completely agnostic of project, models, and chunk implementation details.
# Runs in Base R with zero external dependencies.
# ==============================================================================

root_dir <- getwd()
docs_dir <- file.path(root_dir, "docs")
tables_dir <- file.path(root_dir, "Output", "Results", "Tables")

if (!dir.exists(docs_dir)) {
  quit(save = "no", status = 0)
}

dir.create(tables_dir, recursive = TRUE, showWarnings = FALSE)

# Scan index.html and all notebook preview HTML files
html_files <- c(
  file.path(docs_dir, "index.html"),
  list.files(file.path(docs_dir, "Scripts", "AnalysisScripts"), pattern = "-preview\\.html$", full.names = TRUE)
)
html_files <- html_files[file.exists(html_files)]

if (length(html_files) == 0) {
  quit(save = "no", status = 0)
}

exported_tables <- character(0)

# Clean HTML text helper
clean_html_text <- function(x) {
  x <- gsub("<[^>]+>", "", x)
  x <- trimws(x)
  x <- gsub("&nbsp;", " ", x, fixed = TRUE)
  x <- gsub("&amp;", "&", x, fixed = TRUE)
  x <- gsub("&lt;", "<", x, fixed = TRUE)
  x <- gsub("&gt;", ">", x, fixed = TRUE)
  x <- gsub("&quot;", '"', x, fixed = TRUE)
  x <- gsub("&#39;", "'", x, fixed = TRUE)
  x <- gsub("&minus;", "-", x, fixed = TRUE)
  x <- gsub("\u2212", "-", x, fixed = TRUE)
  x <- gsub("\\~\\~", "~~", x, fixed = TRUE)
  x <- gsub("\u00a0", " ", x, fixed = TRUE)
  x
}

for (hf in html_files) {
  content <- paste(readLines(hf, warn = FALSE), collapse = "\n")
  
  # Find all Quarto table IDs: id="tbl-..."
  matches <- gregexpr('id="(tbl-[a-zA-Z0-9_-]+)"', content)
  m_starts <- as.vector(matches[[1]])
  m_lens <- attr(matches[[1]], "match.length")
  
  if (m_starts[1] == -1) next
  
  for (i in seq_along(m_starts)) {
    id_sub <- substr(content, m_starts[i], m_starts[i] + m_lens[i] - 1)
    raw_id <- sub('^id="', '', sub('"$', '', id_sub))
    
    # Ignore caption IDs or sub-element IDs
    if (grepl("-caption-", raw_id, fixed = TRUE)) next
    
    tbl_id <- raw_id
    if (tbl_id %in% exported_tables) next
    
    # Search for the <table> element directly following this id
    rest <- substr(content, m_starts[i], m_starts[i] + 60000)
    table_match <- regexpr('<table[^>]*>(.*?)</table>', rest)
    if (table_match[1] == -1) next
    
    table_html <- substr(rest, table_match[1], table_match[1] + attr(table_match, "match.length") - 1)
    
    # 1. Extract headers (<th>)
    th_matches <- regmatches(table_html, gregexpr('<th[^>]*>(.*?)</th>', table_html))[[1]]
    headers <- clean_html_text(th_matches)
    
    # 2. Extract rows (<tr> inside <tbody>, or all <tr> excluding header)
    tbody_match <- regexpr('<tbody>(.*?)</tbody>', table_html)
    if (tbody_match[1] != -1) {
      tbody_html <- substr(table_html, tbody_match[1], tbody_match[1] + attr(tbody_match, "match.length") - 1)
    } else {
      tbody_html <- table_html
    }
    
    tr_matches <- regmatches(tbody_html, gregexpr('<tr[^>]*>(.*?)</tr>', tbody_html))[[1]]
    
    rows_list <- list()
    for (tr in tr_matches) {
      td_matches <- regmatches(tr, gregexpr('<td[^>]*>(.*?)</td>', tr))[[1]]
      if (length(td_matches) == 0) next
      cells <- clean_html_text(td_matches)
      rows_list[[length(rows_list) + 1]] <- cells
    }
    
    if (length(rows_list) == 0) next
    
    # Determine column count from the first row
    ncol_expected <- length(rows_list[[1]])
    
    # Pad headers if needed (e.g. if the first column was a row-name without header)
    if (length(headers) < ncol_expected) {
      headers <- c("Metric", headers)
    } else if (length(headers) > ncol_expected) {
      headers <- headers[seq_len(ncol_expected)]
    }
    
    # If the first header is blank, name it "Metric"
    if (length(headers) > 0 && headers[1] == "") {
      headers[1] <- "Metric"
    }
    
    # Normalize row lengths to match headers
    rows_clean <- lapply(rows_list, function(r) {
      if (length(r) < ncol_expected) {
        c(r, rep("", ncol_expected - length(r)))
      } else {
        r[seq_len(ncol_expected)]
      }
    })
    
    # Assemble data frame
    df <- as.data.frame(do.call(rbind, rows_clean), stringsAsFactors = FALSE)
    colnames(df) <- headers
    
    out_file <- file.path(tables_dir, paste0(tbl_id, ".csv"))
    write.csv(df, out_file, row.names = FALSE)
    exported_tables <- c(exported_tables, tbl_id)
  }
}

message(sprintf("post_render_tables.R: Successfully exported %d tables to Output/Results/Tables/", length(exported_tables)))
