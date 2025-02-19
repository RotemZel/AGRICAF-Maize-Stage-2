#31-04-2024 soybean price forecast; country, production data

# table of contents:
# 1. records: define model's weight relative to error
# 2. rank: normalise varImp (contribute) values 
# 3. filter data to relevant variables and save

################################################################################
#------------------------------- 0. general settings
################################################################################
c = ''

setwd(paste0('~/price_forecasting/',c,'_prices'))
source(paste0('master_cmaf_',c,'.R'))

#### load packages ####
library(tidyverse)

#geographic scale
geo = 'country'

# model input (default)
def_input = c('production', 'yield')

rm(list=setdiff(ls(), 
                c('wd_main', 'wd_data',
                  'wd_country', 'wd_country_analyse_proc',
                  'geo', 'def_input')))

setwd(paste0(wd_main,'/analyse_processed'))
load(paste0('rank','_',geo,'.RData'))
load(paste0('records','_',geo,'.RData')) 

#----------------- 1. records: define model's weight relative to error ---------------#

# define a weight function
weight_fun = function(df){
  mod_weight <- df %>%
    group_by(forecast_model, g_scale, d_input, month, lags) %>%
    # total errors of model (aggregation of all years)
    summarise(error = sum(error)) %>%
    group_by(month, lags, g_scale, d_input) %>%
    # keep only 2 options with lowest error
    slice_min(error, n = 2) %>%
    # total errors of all models (g_scales, inputs can't come together!)
    mutate(tot_error = sum(error)) %>%
    # % of model's error out of total error
    mutate(weight = 1-(tot_error/error)) %>%
    # Normalize weights to sum to 1
    mutate(weight = weight/sum(weight)) %>%
    ungroup()
}
  
mod_weight <- weight_fun(df = records)

#----------------- 2. rank: normalise varImp (contribute) values  ---------------#

rank <- rank %>%
  drop_na() %>%
  right_join(y = mod_weight, 
            by = c('month', 'lags','forecast_model','g_scale','d_input')) %>%
  # Scale the variable importance within (0,1) range
  mutate(var_imp = as.numeric(scale(contribute,
                         center = min(contribute),
                         scale = max(contribute) - min(contribute))),
         .by = 'forecast_model')

rank <- rank %>% 
  group_by(var, month, lags, g_scale, d_input) %>%
  mutate(var_imp = var_imp*weight) %>%
  summarise(var_imp = mean(var_imp))
  
vars_to_forecast <- rank %>%
  group_by(month, lags, g_scale, d_input) %>%
  slice_max(order_by = var_imp, n = 19) %>%
  ungroup()


#----------------- 3. build a new dataset: remove irrelevant features ---------------#
setwd(wd_country_analyse_proc)
load("analyse_data.RData")


# merge all data into 1 dataset
my_data <- lapply(names(my_data), function(dataset_name) {
  def_input = dataset_name
  result <- my_data[[dataset_name]] %>% as.data.frame()
  
  after_loc = which(colnames(result) == 'month')
  
  dataset <- result %>%
    # after 'month'
    mutate(d_input = def_input,  g_scale = geo, .after = after_loc)
  
  y = which(colnames(dataset) == 'obs.')
  result <- pivot_longer(dataset, names_to = 'var', values_to = 'value', 
                         cols = !(1:y), values_drop_na = F)
  return(result)
})

my_data <- do.call(rbind, my_data)

# Define the conditions for filtering
filter_conditions <- function(x) {
  all(x == 0 | x > 99)
}

# Group by "var" and filter rows based on conditions
my_data <- my_data %>%
  mutate(value = ifelse(is.infinite(value), 99.9, value)) %>%
  group_by(var, d_input, g_scale) %>%
  filter(!filter_conditions(value))

situation <- expand.grid(month = 1:12, lags = 1:12, g_scale = geo, d_input = def_input)

forecast_data <- list()

for (run in 1:nrow(situation)){
  
  vars <- vars_to_forecast %>%
    filter(month == situation[run,'month'] & 
             lags == situation[run,'lags'] & 
             d_input == situation[run,'d_input'] & 
             g_scale == situation[run,'g_scale']) %>%
    dplyr::select(var) %>%
    arrange(var)
  
  vars <- c(vars$var)
  
  forecast_data[[run]] <- my_data %>%
    filter(month == situation[run,'month'] &
             d_input == situation[run,'d_input'] & 
             g_scale == situation[run,'g_scale']) %>%
    mutate(lags = situation[run,'lags'], .after = month) %>%
    as.data.frame() %>%
    filter(var %in% vars)
}

my_data <- do.call(rbind, forecast_data)
my_data <- my_data %>%
  arrange(date)

setwd(paste0(wd_country,'/forecast_processed'))
save(my_data, file = "forecast_data.RData")

# test
test <- my_data %>%
  filter(month == 2 & lags == 5 & d_input == 'production' & g_scale == geo) %>%
  dplyr::select(-c(month, lags, d_input, g_scale)) %>%
  pivot_wider(names_from = var)

View(test)