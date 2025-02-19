# c price forecast; country
# forecast was made using production

################################################################################
#--------------------- 0. load the necessities 
################################################################################

#c = 'maize'

setwd(paste0('~/price_forecasting/',c,'_prices'))
source(paste0('master_cmaf_',c,'.R'))

library(tidyverse)

setwd(paste0(wd_country,'/forecast_processed'))
rm(list=setdiff(ls(), 
                c('wd_main', 'wd_country','c')))

#--------------------------------------------------------------------------------
# define functions & parameters ###
#--------------------------------------------------------------------------------

#geographic scale
geo = 'country'

# model input (default)
def_input = c('production', 'yield')
#def_input = 'production'

# Create a function to rename the dataset
rename_dataset <- function(new_name, old_name) {
  assign(new_name, get(old_name), envir = .GlobalEnv)
  rm(list = old_name, envir = .GlobalEnv)
}

#create functions to upload results and merge
import_tables <- function(x){
  files <- list.files(pattern = x) # any file in directory that contains x
  # Import files into a list
  data_list <- lapply(files, readRDS)
  data_list <- do.call(rbind, data_list)
  
  return(data_list)
}

#create functions to upload results and merge
import_lists <- function(x){
  # Get a list of all RData files in the current directory starting with "records_"
  file_list <- list.files(pattern = x, full.names = TRUE)
  
  # Initialize an empty list to store the data
  data_list <- list()
  
  # Loop through each file and load it into the list
  for (file in file_list) 
    {
    # Extract the name of the object from the file name
    obj_name <- sub(".*/(.*)\\.RData", "\\1", file)
    # Load the data from the RData file into the list
    data_list[[obj_name]] <- get(load(file))
  }
  data_list <- do.call(rbind, data_list)
  
  return(data_list)
}

# -------------- 1. Merge the records and save ---------------- 
x = 'records'

records <- import_lists(x = x)
title1 <- paste0(x,'_',geo,'.RDS')

#------------- 2. Relative importance, based on average --------------

# Pay attention to differences between models:
### RF (%IncMSE) - accuracy increase if x is in the model
### GBM (relative influence) - squared error decreased if x is in the model
### CART (variable importance) - role of variable in reducing the RSS
### LM (relative influence) - |t| = |𝛽i/SE(𝛽i)|
x = 'rank'
rank <- import_lists(x = x)
title2 <- paste0(x,'_',geo,'.RDS')

# rank <- rank %>%  
#   # replace negative importance (rf) by 0 and Inf (gam_GCV.Cp) by 10
#   mutate(var_imp = case_when(is.infinite(contribute) ~ 10,
#                              contribute < 0 ~ 0,
#                              .default = contribute), .keep = 'unused') %>%
#   #dplyr::group_by(var, forecast_model, month, g_scale, d_input) %>%
#   dplyr::reframe(contribute = mean(var_imp), 
#                  .by = c(var, forecast_model, month, g_scale, d_input))

#--------------------------------------------------------------------------------
# 2.4. arrange relative importance output ###
#--------------------------------------------------------------------------------
setwd(paste0(wd_main,'/forecast_processed'))

saveRDS(records, file = title1)
saveRDS(rank, file = title2)