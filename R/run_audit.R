
source("R/setup.R")
source("R/functions.R")
source("reports/render_all_reports.R")


sites <- list.dirs("data/raw", recursive = FALSE, full.names = FALSE)

results <- lapply(sites, run_rds_audit)
names(results) <- sites

print("All sites processed successfully.")
