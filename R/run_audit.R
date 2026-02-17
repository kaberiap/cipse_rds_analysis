
source("../R/functions.R")

site_name <- params$site

results <- run_rds_audit(site_name)
summary_tbl <- results$summary
dup_tbl <- results$duplicates
