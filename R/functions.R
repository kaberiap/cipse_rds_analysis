run_rds_audit <- function(site_name, root_path = "data/raw") {
  message("Running RDS audit for: ", site_name)
  
  site_path <- file.path(root_path, site_name)
  coupon_file  <- file.path(site_path, "coupon.xlsx")
  survey_file  <- file.path(site_path, "survey.dta")
  orphan_file  <- file.path(site_path, "orphans.txt")
  
}