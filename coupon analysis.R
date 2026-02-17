#Eldoret data
rm(list=ls())

if(!require(pacman))
  library(pacman)
pacman:: p_load( openxlsx, readxl, dplyr, readr, haven, plyr,car,ggplot2,Hmisc, broom, psych, tidyr 
        ) #Installing and loading the listed/required packages
#pacman:: p_update() #Updates all installed packages to their latest versions

# Eldoret site ####
#Loading coupon data
eld_ctf <- read_excel("data/Eldoret_coupon.xlsx")
#Removing orphan coupons
eld_orphans <- readLines("data/orphans.txt") 
#orphans is a manually prepared .txt file from extracting the identified orphan coupons in the data - 27 entries
eld_clean_ctf <- eld_ctf [!eld_ctf$LABEL %in% eld_orphans,] #Removing orphans we have 410 valid coupons, including 4 seeds.
eld_clean_ctf <- eld_clean_ctf %>% distinct(COUPON, .keep_all = TRUE)

write.xlsx(eld_clean_ctf, "data/Eldoret_coupon_clean.xlsx")

#Loading main data
eld_data <-  read_dta("data/eldoret_data.dta")
eld_data$coupon <- gsub("\\.", "", eld_data$coupon) #Formatting for consistency in values of the coupons column
eld_data$coupon <-   gsub("1-0 ---SEED", "1", eld_data$coupon)
eld_data$coupon <- gsub ("1-1", "11", eld_data$coupon)
eld_data$coupon <- gsub ("2_0", "2", eld_data$coupon)
eld_data$coupon <- gsub ("^30$", "3", eld_data$coupon)
eld_data$coupon <- gsub ("^40$", "4", eld_data$coupon)

eld_data_survey <- as_tibble(eld_data)
#eld_data_survey_coupon <- eld_data_survey %>%  select(coupon)
#write.xlsx(eld_data_survey_coupon, "data/Eldoret_maindata_coupon_clean.xlsx")

#Checking for duplicates:
# dups_summary <- eld_data %>%
#   group_by(coupon) %>%
#   summarize(count = n(), .groups= "drop") %>%
#   filter(count > 1)

#Invalid coupons in main data
coupon_inv_survey_data <- setdiff(eld_data_survey$coupon,eld_clean_ctf$COUPON) 
print(coupon_inv_survey_data) #Coupons in main data but not in coupon data = 31

#Valid coupons
eld_valid_coupon_survey_data <- intersect(eld_data_survey$coupon, eld_clean_ctf$COUPON)
print(eld_valid_coupon_survey_data) #Coupons that are in both datasets (coupon data & main data) = 390

eld_invalid_coupon_survey_data <- setdiff(eld_clean_ctf$COUPON, eld_data_survey$coupon) 
print(eld_invalid_coupon_survey_data, 22) #Coupons in ctf data but not in main data = 18


eld_orphan_data <- eld_data_survey %>%
  filter(coupon %in% eld_orphans)


colnames(eld_data_survey)
coupon_del <- intersect(eld_data_survey$coupon, eld_orphan_data$COUPON)
print(coupon_del)


orphan_coupon_codes <- eld_ctf %>%
  filter(LABEL %in% eld_orphans) %>%
  pull(COUPON)
eld_orphan_data <- eld_data_survey %>%
  filter(coupon %in% orphan_coupon_codes)
length(intersect(eld_data_survey$coupon, orphan_coupon_codes))





# Nairobi site ####
#Loading coupon data
nrb_ctf <- read_excel("data/Nairobi_coupon.xlsx")
#Removing orphan coupons
nrb_orphans <- readLines("data/orphans_nrb.txt") 
#orphans is a manually prepared .txt file from extracting the identified orphan coupons in the data - 27 entries
nrb_clean_ctf <- nrb_ctf [!nrb_ctf$LABEL %in% nrb_orphans,] #Removing orphans we have 410 valid coupons, including 4 seeds.
nrb_clean_ctf <- nrb_clean_ctf %>% distinct(COUPON, .keep_all = TRUE)

write.xlsx(nrb_clean_ctf, "data/archives/nrb_coupon_clean.xlsx")

#Loading main data
nrb_data <-  read_dta("data/nairobi_data.dta")
nrb_data$coupon <- gsub("\\.", "", nrb_data$coupon) #Formatting for consistency in values of the coupons column
nrb_data$coupon <-   gsub("1-0 ---SEED", "1", nrb_data$coupon)
nrb_data$coupon <- gsub ("1-1", "11", nrb_data$coupon)
nrb_data$coupon <- gsub ("2_0", "2", nrb_data$coupon)
nrb_data$coupon <- gsub ("^30$", "3", nrb_data$coupon)
nrb_data$coupon <- gsub ("^40$", "4", nrb_data$coupon)

nrb_data_survey <- as_tibble(nrb_data)
#nrb_data_survey_coupon <- nrb_data_survey %>%  select(coupon)
#write.xlsx(nrb_data_survey_coupon, "data/nrboret_maindata_coupon_clean.xlsx")

#Checking for duplicates:
# library(dplyr)
# dups_summary <- nrb_data %>%
#   group_by(coupon) %>%
#   summarize(count = n(), .groups= "drop") %>%
#   filter(count > 1)


#Invalid coupons in main data
coupon_inv_survey_data <- setdiff(nrb_data_survey$coupon,nrb_clean_ctf$COUPON) 
print(coupon_inv_survey_data) #Coupons in main data but not in coupon data = 31

#Valid coupons
nrb_valid_coupon_survey_data <- intersect(nrb_data_survey$coupon, nrb_clean_ctf$COUPON)
print(nrb_valid_coupon_survey_data) #Coupons that are in both datasets (coupon data & main data) = 390

nrb_invalid_coupon_survey_data <- setdiff(nrb_clean_ctf$COUPON, nrb_data_survey$coupon) 
print(nrb_invalid_coupon_survey_data, 22) #Coupons in ctf data but not in main data = 18


nrb_orphan_data <- nrb_data_survey %>%
  filter(coupon %in% nrb_orphans)


colnames(nrb_data_survey)
coupon_del <- intersect(nrb_data_survey$coupon, nrb_orphan_data$COUPON)
print(coupon_del)


orphan_coupon_codes <- nrb_ctf %>%
  filter(LABEL %in% nrb_orphans) %>%
  pull(COUPON)
nrb_orphan_data <- nrb_data_survey %>%
  filter(coupon %in% orphan_coupon_codes)
length(intersect(nrb_data_survey$coupon, orphan_coupon_codes))
