sites <- list.dirs("../data/raw", recursive = FALSE, full.names = FALSE)

for (s in sites) {
  quarto::quarto_render(
    "rds_audit.qmd",
    execute_params = list(site = s),
    output_file = paste0("RDS_Audit_", s, ".html")
  )
}
