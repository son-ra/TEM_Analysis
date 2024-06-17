library(earth)
library(caret)
library(dplyr)
library(tidyr)
library(zoo)
library(data.table)
# Set seed for reproducibility
set.seed(42)


# Read in the CSV file
# model_data <- fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/Tropical_trainingset_r_1_9.csv')
model_data <- fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/Tropical_trainingset_r_1_9.csv')
testing_data <- fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/Tropical_trainingset_r_10_19.csv')
input_data <- fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/global_input_vars.csv')
# Define variables to compare
# variables_to_compare <- c('monthly_mean', 'tswrf_v11', 'tmp', 'precip', 'dtr', 'vpr', 'wind', 'co2', 'Ndep_Trendy')
variables_to_compare <- c('VEGC', 'LAI', 'VSM', 'NETNMIN', 'AVAILN')
variables_to_compare <- c('VEGC', 'LAI', 'VSM', 'NETNMIN', 'AVAILN'
                          ,"tswrf_v11_avg" ,"tswrf_v11_min" , "tswrf_v11_max" ,
                          "tmp_avg" ,"tmp_min" , "tmp_max" ,
                          "precip_avg" , "precip_min" , "precip_max" ,
                          "dtr_avg" , "dtr_min" , "dtr_max" ,
                          "vpr_avg" , "vpr_min" , "vpr_max" ,
                          "wind_avg" ,"wind_min" ,"wind_max" ,  
                          "Ndep_Trendy" ,"Nfer_crop" ,  "Nfer_pas" ,  
                          "co2" )
model_data <- input_data[model_data, on = c('lon', 'lat', 'year')]
testing_data <- input_data[testing_data, on = c('lon', 'lat', 'year')]

start_yr <- 1900
end_yr <- 1920
# Create base comparison data table by filtering and summarizing
base_comparison <- model_data[year >= start_yr & year <= end_yr, lapply(.SD, mean, na.rm = TRUE), 
                              by = .(lon, lat, ordinal_stand_age), .SDcols = variables_to_compare]
setnames(base_comparison, old = variables_to_compare, new = paste0(variables_to_compare, "_base"))
nrow(model_data)
# Merge model_data with the base_comparison to get corresponding base values
model_data <- base_comparison[model_data, on = c('lon', 'lat', 'ordinal_stand_age')]
nrow(model_data)
nrow(model_data[VEGC_base == 0])/nrow(model_data)
# nrow(model_data[VEGC_ratio>5 ])/nrow(model_data)
nrow(model_data[is.na(VEGC_base)])/nrow(model_data)

# Filter out rows where the monthly_mean_base is equal to zero
model_data <- model_data[ !is.na(VEGC_base)]

# model_data[,VEGC_ratio := VEGC-VEGC_base]
for (var in variables_to_compare) {
  ts_column <- var       # Time series data column name
  base_column <- paste0(var, '_base')   # Baseline data column name
  ratio_column <- paste0(var, '_ratio') # Name for the new column
  
  # Compute the ratio or difference and update model_data by reference
  if (grepl('precip',var)==TRUE) {
    print(var)
    model_data[, (ratio_column) := get(ts_column) / get(base_column)]
  } else {
    model_data[, (ratio_column) := get(ts_column) - get(base_column)]
  }
}

base_comparison <- testing_data[year >= start_yr & year <= end_yr, lapply(.SD, mean, na.rm = TRUE), 
                                by = .(lon, lat, ordinal_stand_age), .SDcols = variables_to_compare]
setnames(base_comparison, old = variables_to_compare, new = paste0(variables_to_compare, "_base"))
nrow(testing_data)
# Merge testing_data with the base_comparison to get corresponding base values
testing_data <- base_comparison[testing_data, on = c('lon', 'lat', 'ordinal_stand_age')]
nrow(testing_data)
nrow(testing_data[VEGC_base == 0])/nrow(testing_data)
# nrow(testing_data[VEGC_ratio>5 ])/nrow(testing_data)
nrow(testing_data[is.na(VEGC_base)])/nrow(testing_data)

# Filter out rows where the monthly_mean_base is equal to zero
testing_data <- testing_data[ !is.na(VEGC_base)]

# testing_data[,VEGC_ratio := VEGC-VEGC_base]
for (var in variables_to_compare) {
  ts_column <- var       # Time series data column name
  base_column <- paste0(var, '_base')   # Baseline data column name
  ratio_column <- paste0(var, '_ratio') # Name for the new column
  
  # Compute the ratio or difference and update testing_data by reference
  if (grepl('precip',var)==TRUE) {
    print(var)
    testing_data[, (ratio_column) := get(ts_column) / get(base_column)]
  } else {
    testing_data[, (ratio_column) := get(ts_column) - get(base_column)]
  }
}
# Subset the data to include only rows where the year is greater than 1950
model_data <- model_data[year > 1950]
testing_data <- testing_data[year > 1950]
nrow(model_data)
# model_data <- input_data[model_data, on = c('lon', 'lat', 'year')]
# testing_data <- input_data[testing_data, on = c('lon', 'lat', 'year')]
nrow(model_data)

hist(model_data$VEGC)
hist(testing_data$VEGC)
hist(model_data$VEGC_ratio, breaks = 40)
hist(model_data$NPP, breaks = 40)
hist(model_data$LAI_ratio, breaks = 40)
hist(model_data$VSM_ratio, breaks = 40)
hist(model_data$NETNMIN_ratio, breaks = 40)
hist(model_data$AVAILN_ratio, breaks = 40)
hist(model_data$VEGC_base)
hist(model_data$SOILORGC)
hist(model_data$AVAILN, breaks = 40) ###outliers
hist(model_data$GPP)
hist(model_data$LAI)
hist(model_data$NCE, breaks=40)
hist(model_data$NEP)
hist(model_data$NETNMIN, breaks=40)##outliers
hist(model_data$NPP)
hist(model_data$VEGINNPP)
hist(model_data$VSM)

# Create a histogram of the monthly_mean_ratio column with 40 bins
hist(model_data$monthly_mean_ratio, breaks=40, main="Histogram of Monthly Mean Ratio", xlab="Monthly Mean Ratio")
hist(model_data$tswrf_v11_ratio, breaks=40, main="Histogram of Monthly Mean Ratio", xlab="Monthly Mean Ratio")
hist(model_data$tmp_ratio, breaks=40, main="Histogram of Monthly Mean Ratio", xlab="Monthly Mean Ratio")
hist(model_data$precip_ratio, breaks=40, main="Histogram of Monthly Mean Ratio", xlab="Monthly Mean Ratio")
hist(model_data$dtr_ratio, breaks=40, main="Histogram of Monthly Mean Ratio", xlab="Monthly Mean Ratio")
hist(model_data$vpr_ratio, breaks=40, main="Histogram of Monthly Mean Ratio", xlab="Monthly Mean Ratio")
model_data <- model_data %>% 
  arrange(lat, lon, year) %>% # Ensure the data is ordered
  group_by(lat, lon) %>% # Group by lat/lon
  mutate(lag_tmp_ratio = lag(tmp_ratio, 1)) # Create lagged variable

# Now compute the 5-year rolling average
model_data <- model_data %>%
  mutate(moving_avg_tmp_ratio = rollapply(data = lag_tmp_ratio, width = 5, FUN = mean, align = 'right', fill = NA))

# This will perform the 5-year moving average on the lagged 'tmp_ratio', aligning the window to the right, 
# which means each value of 'moving_avg_tmp_ratio' will be the average of the current and previous 4 years. 
# The na.pad argument pads the result with NAs to maintain the same length as the input.

# If you wish to drop the NA values that result from padding (first few years where 5-year average can't be calculated)
model_data <- model_data %>%
  filter(!is.na(moving_avg_tmp_ratio)&!is.na(lag_tmp_ratio)) # Remove rows where the 5-year moving average is NA



features <- c('tswrf_v11_avg_ratio', 'tmp_avg_ratio', 'precip_avg_ratio',
              # 'lag_tmp_avg_ratio','moving_avg_tmp_avg_ratio',
              'dtr_avg_ratio', 'vpr_avg_ratio', 'wind_avg_ratio', 'co2_ratio', 'ordinal_stand_age')

features <- c( 'ordinal_stand_age', "LAI_ratio", "VSM_ratio","NETNMIN_ratio" ,"AVAILN_ratio"  )
features <- c( 'ordinal_stand_age', "LAI", "VSM","NETNMIN" ,"AVAILN"  )

features <- c('tswrf_v11_ts', 'tmp_ts', 'precip_ts','silt_clay',
              'dtr_ts', 'vpr_ts', 'wind_ts', 'co2_ts', 'ordinal_stand_age')

features <- c("tswrf_v11_avg_ratio" ,   "tswrf_v11_min_ratio" ,   "tswrf_v11_max_ratio" ,   "tmp_avg_ratio" ,        
"tmp_min_ratio" ,         "tmp_max_ratio" ,         "precip_avg_ratio" ,      "precip_min_ratio" ,     
"precip_max_ratio" ,      "dtr_avg_ratio" ,         "dtr_min_ratio" ,         "dtr_max_ratio" ,        
"vpr_avg_ratio" ,         "vpr_min_ratio" ,         "vpr_max_ratio" ,         "wind_avg_ratio" ,       
"wind_min_ratio" ,        "wind_max_ratio" ,        "Ndep_Trendy_ratio" ,     "Nfer_crop_ratio" ,      
"Nfer_pas_ratio" ,    "co2_ratio", "s1" ,"s2" , "s3" ,  
"elev" ,"ordinal_stand_age" 
)
features <- c("tswrf_v11_avg" ,"tswrf_v11_min" , "tswrf_v11_max" ,
"tmp_avg" ,"tmp_min" , "tmp_max" ,
"precip_avg" , "precip_min" , "precip_max" ,
"dtr_avg" , "dtr_min" , "dtr_max" ,
"vpr_avg" , "vpr_min" , "vpr_max" ,
"wind_avg" ,"wind_min" ,"wind_max" ,  
"Ndep_Trendy" ,"Nfer_crop" ,  "Nfer_pas" ,  
"s1" ,"s2" , "s3" ,  
"elev" ,  "co2" ,"ordinal_stand_age" )
# Create the predictor matrix and response vector
model_data[, (names(model_data)) := lapply(.SD, function(x) replace(x, is.infinite(x), NA))]
testing_data[, (names(testing_data)) := lapply(.SD, function(x) replace(x, is.infinite(x), NA))]

model_data <- na.omit(model_data)
testing_data <- na.omit(testing_data)

X <- model_data[, ..features]
# X[, (features) := lapply(.SD, scale), .SDcols = features]
# Y <- scale(model_data$VEGC)
# Y <- model_data$VEGC_ratio
Y <- model_data$VEGC
# Y <- model_data$NPP
# Y <- model_data$SOILORGC

# Y <- model_data[, .(VEGC,SOILORGC)]


# You can uncomment the next line if you want to apply the square root transformation to Y
# Y <- sqrt(model_data$monthly_mean_ratio)


# Split the data into training and testing sets
X_train <- X
X_test <- testing_data[, ..features]
y_train <- Y
y_test <- testing_data$VEGC



# trainIndex <- createDataPartition(Y$VEGC, p = 0.7, list = FALSE)
# X_train <- X[trainIndex, ]
# X_test <- X[-trainIndex, ]
# y_train <- Y[trainIndex,]
# y_test <- Y[-trainIndex,]

earth.mod <- earth(y=y_train, x=X_train, degree=6)
# earth.mod$rsq.per.response
plotmo(earth.mod)
# plotmo(earth.mod,nresponse = 2)
summary(earth.mod, digits = 2, style = "pmax")
plot(earth.mod)


y_pred <- predict(earth.mod, X_test)
resid <- y_test-y_pred
length(y_pred[y_pred<0])/length(y_pred)
sqrt(mean(resid^2))
1-(sum((y_test-y_pred)^2)/sum((y_test-mean(y_test))^2 ))


###for two responses
y_pred <- predict(earth.mod, X_test)
resid_veg <- y_test[,1]-y_pred[,1]
resid_soil <- y_test[,2]-y_pred[,2]
length(y_pred[y_pred[,1]<0])/nrow(y_pred)
length(y_pred[y_pred[,2]<0])/nrow(y_pred)
sqrt(mean(resid_veg^2))
sqrt(mean(resid_soil^2))
1-(sum((y_test[,1]-y_pred[,1])^2)/sum((y_test[,1]-mean(y_test[,1]))^2 ))
1-(sum((y_test[,2]-y_pred[,2])^2)/sum((y_test[,2]-mean(y_test[,2]))^2 ))




