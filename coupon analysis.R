#Eldoret data
rm(list=ls())

if(!require(pacman))
  library(pacman)
library(dplyr)
pacman:: p_load( openxlsx, readxl, dplyr, readr, haven, plyr,car,ggplot2,Hmisc, broom, psych, tidyr 
        ) #Installing and loading the listed/required packages
pacman:: p_update() #Updates all installed packages to their latest versions


#Loading coupon data
eld <- read_excel("data/Eldoret_coupon.xlsx")
#Removing orphan coupons
orphans <- readLines("data/orphans.txt") #orphans is a manually prepared .txt file from extracting the identified orphan coupons in the data
eld_clean <- eld [!eld$LABEL %in% orphans,] #Removing orphans we have 410 valid coupons, including 4 seeds.

#Loading main data
eld_data <-  read_dta("data/eldoret_data.dta")
eld_data$coupon <- gsub("\\.", "", eld_data$coupon) #Formatting for consistency in values of the coupons column
eld_data$coupon <-   gsub("1-0 ---SEED", "1", eld_data$coupon)
eld_data$coupon <- gsub ("1-1", "11", eld_data$coupon)
eld_data$coupon <- gsub ("2_0", "2", eld_data$coupon)
eld_data$coupon <- gsub ("30", "3", eld_data$coupon)
eld_data$coupon <- gsub ("40", "4", eld_data$coupon)

eld_data <- as_tibble(eld_data)


#Checking for duplicates:
# dups_summary <- eld_data %>%
#   group_by(coupon) %>%
#   summarize(count = n(), .groups= "drop") %>%
#   filter(count > 1)

#Invalid coupons in main data
coupon_inv_data <- setdiff(eld_data$coupon,eld_clean$COUPON) 
print(coupon_inv_data) #Coupons in main data but not in coupon data = 31

#Valid coupons
coupon_val_data <- intersect(eld_data$coupon, eld_clean$COUPON)
print(coupon_val_data) #Coupons that are in both datasets (coupon data & main data) = 390

coupon_inv_c <- setdiff(eld_clean$COUPON, eld_data$coupon) 
print(coupon_inv_c) #Coupons in coupon data but not in main data = 18


orphan_data <- as.data.frame(orphans) %>% 
  dplyr::rename(LABELS = orphans)
matched_data <- eld %>%
  filter(LABEL %in% orphan_data$LABELS)
orphan_data <- matched_data
coupon_del <- intersect(eld_data$coupon, orphan_data$COUPON)
print(coupon_del)









