library(earth)
library(caret)
library(dplyr)
library(tidyr)
library(zoo)
library(data.table)
library(stats)

pfts <- c("Tropical", "Temperate_Broadleaf","Temperate_Deciduous"
         ,"Temperate_Coniferous","Boreal")

#####read in training and testing data
pft <- pfts[1]
pft

X_train <- fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/model_data/merged_outliers_removed/', pft,'_cru_hist_canesm5_ssp245_X_train.csv'))
X_test <-  fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/model_data/merged_outliers_removed/', pft,'_cru_hist_canesm5_ssp245_X_test.csv'))
Y_train <-  fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/model_data/merged_outliers_removed/', pft,'_cru_hist_canesm5_ssp245_Y_train.csv'))
Y_test <-  fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/model_data/merged_outliers_removed/', pft,'_cru_hist_canesm5_ssp245_Y_test.csv'))

####run model for each var
# Variables
var_list <- c('GPP', 'NPP', 'VEGC', 'SOILORGC')
metrics_list <- list()

# Assuming X_train and Y_train are data.tables or data.frames
for (var in var_list) {
  # Fit the model
  earth_model <- earth(y = Y_train[[var]], x = X_train, degree = 2)
  
  # Save the model
  model_filename <- paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/models/earth_model_', var, '_', pft, '.rda')
  save(earth_model, file = model_filename)
  
  # Predictions
  Y_train[[paste0(var, '_pred')]] <- predict(earth_model, newdata = X_train)
  Y_test[[paste0(var, '_pred')]] <- predict(earth_model, newdata = X_test)
  
  # Evaluation Metrics
  r2_train <- postResample(pred = Y_train[[paste0(var, '_pred')]], obs = Y_train[[var]])[["Rsquared"]]
  r2_test <- postResample(pred = Y_test[[paste0(var, '_pred')]], obs = Y_test[[var]])[["Rsquared"]]
  rmse_train <- sqrt(mean((Y_train[[paste0(var, '_pred')]] - Y_train[[var]])^2))
  rmse_test <- sqrt(mean((Y_test[[paste0(var, '_pred')]] - Y_test[[var]])^2))
  bias_train <- mean(Y_train[[paste0(var, '_pred')]] - Y_train[[var]])
  bias_test <- mean(Y_test[[paste0(var, '_pred')]] - Y_test[[var]])
  
  # Store the results in the list
  metrics_list[[length(metrics_list) + 1]] <- list(
    Variable = var,
    R2_Train = r2_train,
    R2_Test = r2_test,
    RMSE_Train = rmse_train,
    RMSE_Test = rmse_test,
    Bias_Train = bias_train,
    Bias_Test = bias_test
  )
  print(metrics_list)
}

# Convert the metrics_list to a data.table or data.frame for better usability
metrics_dt <- rbindlist(metrics_list)
print(metrics_dt)
###save metrics and output training and testing

