#31-04-2024 c price forecast; country

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
                  'wd_country', 'wd_country_analyse_proc')))

setwd(wd_data)

# Get information about files in the working directory
file_info <- file.info(dir())

# Subset to include only RData files
RData_files <- file_info[grep("^default_.*\\.RData$", rownames(file_info)), ]

# Get the most recently modified file
most_recent_file <- rownames(RData_files)[which.max(RData_files$mtime)]

# Load the most recently modified RData file
load(most_recent_file)

# Rename the loaded data to "default_data"
assign("default_data", get(ls(pattern = "^default_.*$")))

level1 <- names(default_data)

################################################################################
#--------------------- 1. preparation of input ~ output information 
################################################################################

# data will have different levels:
## Level 1 = default input: [1] "country" [2] "country" 
## Level 2 = lag/data for specific horizon (lag = 1:12)
### Example: default_data[[1]][[8]] forecast based on country scale, 8 months ahead


# Find the position of the last column that ends with "_N"
z <- max(grep("_\\d+$", colnames(default_production[[1]])))

# Define the range of years
start_year <- 1962

my_data <- default_data$country %>%
  # turn Inf into 99.9
  mutate(across(
    where(is.numeric), 
                ~ ifelse(. == Inf, 99.9, 
                         ifelse(. == -Inf, -99.9, .)))) %>%
  # Mutate columns to replace NA or NaN with 0 within the specified range of years
  # but select numeric columns with specified column names
  mutate_at(vars((z+1):ncol(.)), ~ 
              ifelse(year >= start_year & 
                       year <= max(default_data$country$year) - 1 & 
                       is.na(.) | is.nan(.), 0, .)) %>%
  tidyr::drop_na((z+1):ncol(.)) %>%
  relocate(obs., .after = month)

# Split the dataframe by feature_head
my_data <- split(my_data, f = my_data$feature_head)

setwd(wd_country_analyse_proc)
save(my_data, file = "analyse_data.RData")