#31-05-2024 c price forecast; region

# table of contents:
# 0. general settings
# 1. data import and preparation of summarising environment 
# 5. Summarise & Save

################################################################################
#------------------------------- 0. general settings
################################################################################
#c = 'cocoa'

setwd(paste0('~/price_forecasting/',c,'_prices'))
source(paste0('master_cmaf_',c,'.R'))

#### load packages ####\
library(tidyverse)

rm(list=setdiff(ls(), 
                c('wd_main', 'wd_data','c',
                  'wd_region', 'wd_region_analyse_proc')))

setwd(wd_data)

# load data
load('default_data.RData')
load('monthly_obs.RData')

level1 <- names(default_data)

################################################################################
#--------------------- 1. preparation of input ~ output information 
################################################################################

# data will have different levels:
## Level 1 = default input: [1] "country" [2] "region" 
## Level 2 = lag/data for specific horizon (lag = 1:12)
### Example: default_data[[1]][[8]] forecast based on country scale, 8 months ahead

my_data <- default_data$region

# Find the position of first column ends with "_N" (number)
z <- max(grep("_\\d+$", colnames(my_data)))

# Define the range of years
start_year <- 1962

my_data <- my_data %>%
  # turn Inf into 99.9
  mutate(across(where(is.numeric), 
                ~ ifelse(. == Inf, 99.9, 
                         ifelse(. == -Inf, -99.9, .)))) %>%
  # Mutate columns to replace NA or NaN with 0 within the specified range of years
  mutate(across(where(is.numeric), 
                ~ ifelse(year >= start_year & 
                           year <= max(my_data$year) - 1 & 
                           is.na(.) | is.nan(.), 0, .))) %>%
  tidyr::drop_na() %>%
  relocate(all_of(c('feature_head','date','year','month','obs.')), .before = 1)

# Split the dataframe by feature_head
my_data <- split(my_data, f = my_data$feature_head)

setwd(wd_region_analyse_proc)
save(my_data, file = "analyse_data.RData")