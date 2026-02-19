run_rds_audit <- function(site_name, root_path = here::here("data","raw")) {
  message("Running RDS audit for: ", site_name)
  
  site_path <- file.path(root_path, site_name)
  coupon_file <- list.files(site_path, pattern = "coupon.*\\.xlsx$", full.names = TRUE)
  survey_file <- list.files(site_path, pattern = "\\.dta$", full.names = TRUE)
  orphan_file <- list.files(site_path, pattern = "orphan.*\\.txt$", full.names = TRUE)
  
  if (length(coupon_file) != 1) stop("Coupon file not found or multiple found in ", site_name)
  if (length(survey_file) != 1) stop("Survey file not found or multiple found in ", site_name)
  if (length(orphan_file) != 1) stop("Orphan file not found or multiple found in ", site_name)
  
  
  # Loading data ####
  ctf      <- read_excel(coupon_file)
  survey   <- read_dta(survey_file) %>% as_tibble()
  orphans  <- readLines(orphan_file)
  #Cleaning ctf
  clean_ctf <- ctf %>%
    filter(!LABEL %in% orphans) %>%
    distinct(COUPON, .keep_all = TRUE)
  
  #Standardizing survey coupon formats
  survey <- survey %>%
    mutate(
      coupon = str_replace_all(coupon, "\\.", ""),
      coupon = str_replace_all(coupon, "1-0 ---SEED", "1"),
      coupon = str_replace_all(coupon, "1-1", "11"),
      coupon = str_replace_all(coupon, "2_0", "2"),
      coupon = str_replace_all(coupon, "^30$", "3"),
      coupon = str_replace_all(coupon, "^40$", "4")
    )
  #Checking for duplicates
  duplicate_coupons <- survey %>%
    group_by(coupon) %>%
    summarise(n = n(), .groups = "drop") %>%
    filter(n > 1)
  
  #Reconciliation metrics
  total_ctf        <- nrow(ctf)
  total_survey     <- nrow(survey)
  total_orphans    <- length(orphans)
  clean_ctf_total  <- nrow(clean_ctf)
  
  invalid_survey   <- setdiff(survey$coupon, clean_ctf$COUPON)
  valid_coupons    <- intersect(survey$coupon, clean_ctf$COUPON)
  unused_coupons   <- setdiff(clean_ctf$COUPON, survey$coupon)
  
  orphan_codes <- ctf %>%
    filter(LABEL %in% orphans) %>%
    pull(COUPON)
  
  orphan_survey_records <- survey %>%
    filter(coupon %in% orphan_codes)
  
  #Summary table
  audit_summary <- tibble(
    metric = c(
      "Total CTF coupons",
      "Total Survey Records",
      "Orphan Coupons (CTF)",
      "Clean CTF Coupons",
      "Valid Coupon Matches",
      "Invalid Survey Coupons",
      "Unused Issued Coupons",
      "Orphan-linked Survey Records"
    ),
    value = c(
      total_ctf,
      total_survey,
      total_orphans,
      clean_ctf_total,
      length(valid_coupons),
      length(invalid_survey),
      length(unused_coupons),
      nrow(orphan_survey_records)
    )
  )
  
  # Generate RDS Flow Diagram
  flow_data <- tibble(
    stage = c(
      "Coupons Issued",
      "CTF Cleaned",
      "Survey Interviews",
      "Valid Matches"
    ),
    count = c(
      total_ctf,
      clean_ctf_total,
      total_survey,
      length(valid_coupons)
    )
  )
  
  flow_plot <- ggplot(flow_data, aes(x = stage, y = count)) +
    geom_col() +
    geom_text(aes(label = count), vjust = -0.5) +
    theme_minimal() +
    labs(
      title = paste("RDS Reconciliation Flow -", site_name),
      y = "Count",
      x = ""
    )
  

  #Export Outputs
  out_dir <- "data/audit_outputs"
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
  
  write.xlsx(
    list(
      summary = audit_summary,
      duplicate_coupons = duplicate_coupons
    ),
    file.path(out_dir, paste0(site_name, "_RDS_audit.xlsx"))
  )
  
  ggsave(
    filename = file.path("output/diagrams", paste0(site_name, "_flow.png")),
    plot = flow_plot,
    width = 8,
    height = 5
  )
  
  message("Audit complete for: ", site_name)
  
  return(list(
    summary = audit_summary,
    duplicates = duplicate_coupons
  ))
  
}




