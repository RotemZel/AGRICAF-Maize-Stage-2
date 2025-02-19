# c price forecast; region; 
# forecast was made using production

################################################################################
#--------------------- 0. load the necessities 
################################################################################

#c = 'cocoa'

setwd(paste0('~/price_forecasting/',c,'_prices'))
source(paste0('master_cmaf_',c,'.R'))

library(tidyverse)

setwd(wd_region_analyse_proc)
rm(list=setdiff(ls(), 
                c('wd_main', 'wd_region_analyse_proc','c')))

#--------------------------------------------------------------------------------
# define functions & parameters ###
#--------------------------------------------------------------------------------

#geographic scale
geo = 'region'

# model input (default)
def_input = c('production', 'yield')

# Create a function to rename the dataset
rename_dataset <- function(new_name, old_name) {
  assign(new_name, get(old_name), envir = .GlobalEnv)
  rm(list = old_name, envir = .GlobalEnv)
}

#create function to upload results and merge
merge_fun <- function(x){
  my_data <- list()
  
  files <- list.files(pattern = x) # any file in directory that contains x
  for (i in files) 
  {
    load(i)
    if(x == 'records'){
      my_data[[i]] <- records
    } else if(x == 'rank'){
      my_data[[i]] <- rank_
    } else{ 
      print('error')}
  }
  my_data <- do.call(rbind, my_data)
  
  return(my_data)
}

# -------------- 1. Merge the records and save ---------------- 
x = 'records'

records <- merge_fun(x = x)
title1 <- paste0(x,'_',geo,'.RData')

#------------- 2. Relative importance, based on average --------------

# Pay attention to differences between models:data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAWElEQVR42mNgGPTAxsZmJsVqQApgmGw1yApwKcQiT7phRBuCzzCSDSHGMKINIeDNmWQlA2IigKJwIssQkHdINgxfmBBtGDEBS3KCxBc7pMQgMYE5c/AXPwAwSX4lV3pTWwAAAABJRU5ErkJggg==
### RF (%IncMSE) - accuracy increase if x is in the model
### GBM (relative influence) - squared error decreased if x is in the model
### CART (variable importance) - role of variable in reducing the RSS
### LM (relative influence) - |t| = |𝛽i/SE(𝛽i)|
x = 'rank'
rank <- merge_fun(x = x)
title2 <- paste0(x,'_',geo,'.RData')

rank <- rank %>%  
  # replace negative importance (rf) by 0 and Inf (gam_GCV.Cp) by 10
  mutate(var_imp = case_when(is.infinite(contribute) ~ 10,
                             contribute < 0 ~ 0,
                             .default = contribute), .keep = 'unused') %>%
  #dplyr::group_by(var, forecast_model, month, g_scale, d_input) %>%
  dplyr::reframe(contribute = mean(var_imp), 
                 .by = c(var, forecast_model, month, lags, g_scale, d_input)) %>%
  drop_na()

#--------------------------------------------------------------------------------
# 2.4. arrange relative importance output ###
#--------------------------------------------------------------------------------
setwd(paste0(wd_main,'/analyse_processed'))

save(records, file = title1)
save(rank, file = title2)