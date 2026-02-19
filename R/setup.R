if (!require(pacman)) install.packages("pacman")

pacman::p_load(
  dplyr, readxl, readr, haven,
  openxlsx, ggplot2, tidyr, stringr, here)

options(stringsAsFactors = FALSE)
