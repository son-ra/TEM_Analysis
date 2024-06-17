library(earth)
library(caret)
library(dplyr)
library(tidyr)
library(zoo)
library(data.table)
library(stats)
library(corrplot)
# Set seed for reproducibility
set.seed(42)


# Read in the CSV file
# model_data <- fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/Tropical_trainingset_r_1_9.csv')
model_data <- rbindlist(list(
  fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/Tropical_trainingset_r_1_9.csv')
  , fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/Tropical_trainingset_r_10_19.csv')
  , fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/Tropical_trainingset_r_20_29.csv')
))
print(paste("n lat/lons", nrow(unique(model_data, by = c("lon","lat")))))
input_data <- fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/global_input_vars.csv')
# Define variables to compare
model_data <- input_data[model_data, on = c('lon', 'lat', 'year')]
rm(input_data)

# acf(model_data$VEGC)
# pacf(model_data$VEGC)
# ccf(model_data$VEGC, model_data$precip_avg)


variables_to_compare <- c('VEGC', 'SOILORGC'
                          # ,'LAI', 'VSM', 'NETNMIN', 'AVAILN'
                          ,"tswrf_v11_avg" ,"tswrf_v11_min" , "tswrf_v11_max" ,
                          "tmp_avg" ,"tmp_min" , "tmp_max" ,
                          "precip_avg" , "precip_min" , "precip_max" ,
                          "dtr_avg" , "dtr_min" , "dtr_max" ,
                          "vpr_avg" , "vpr_min" , "vpr_max" ,
                          "wind_avg" ,"wind_min" ,"wind_max" ,  
                          "Ndep_Trendy" ,"Nfer_crop" ,  "Nfer_pas" , "co2")


start_yr <- 1900
end_yr <- 1920
# Create base comparison data table by filtering and summarizing
base_comparison <- model_data[year >= start_yr & year <= end_yr, lapply(.SD, mean, na.rm = TRUE), 
                              by = .(lon, lat, ordinal_stand_age), .SDcols = variables_to_compare]
setnames(base_comparison, old = variables_to_compare, new = paste0(variables_to_compare, "_base"))
nrow(model_data)
# Merge model_data with the base_comparison to get corresponding base values
model_data <- base_comparison[model_data, on = c('lon', 'lat', 'ordinal_stand_age')]
rm(base_comparison)
nrow(model_data)
nrow(model_data[VEGC_base == 0])/nrow(model_data)
# nrow(model_data[VEGC_ratio>5 ])/nrow(model_data)
nrow(model_data[is.na(VEGC_base)])/nrow(model_data)
hist(model_data$ordinal_stand_age)
hist(model_data[is.na(VEGC_base)]$ordinal_stand_age)
hist(model_data[!is.na(VEGC_base)]$ordinal_stand_age)


  # Filter out rows where the monthly_mean_base is equal to zero
# model_data <- model_data[ !is.na(VEGC_base)]

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
model_data <- model_data[order(lon, lat, year,ordinal_stand_age)]

# time_lags <- c(1, 5, 10, 20)

roll_avg_fun <- function(x, n) {
  shift(frollmean(x, n = n, align = "right", na.rm = TRUE), n=1, type="lag")  # You can adjust arguments as needed
}

new_col_names <- paste0(variables_to_compare, "_1_shift")

model_data[, (new_col_names) := lapply(.SD, shift, n = 1, type="lag"), 
           by = .(lon,lat,ordinal_stand_age), 
           .SDcols = variables_to_compare]
nlag <- 5
new_col_names <- paste0(variables_to_compare, "_rolling_", nlag)
model_data[, (new_col_names) := lapply(.SD, roll_avg_fun, n = nlag), 
           by = .(lon,lat,ordinal_stand_age), 
           .SDcols = variables_to_compare]

nlag <- 20
new_col_names <- paste0(variables_to_compare, "_rolling_", nlag)

model_data[, (new_col_names) := lapply(.SD, roll_avg_fun, n = nlag), 
           by = .(lon,lat,ordinal_stand_age), 
           .SDcols = variables_to_compare]


# model_data[lon==26&lat==0&ordinal_stand_age==8, .(year,VEGC, VEGC_yy, VEGC_1_shift, VEGC_rolling_5, VEGC_rolling_20)]

# # Calculate rolling means for all variables and lags
# for (lag in time_lags) {
#   # Create new column names for the rolling averages
#   new_col_names <- paste0(variables_to_compare, "_rolling_", lag)
#   
#   # Calculate the rolling averages using .SD and .SDcols
#   dataset[, (new_col_names) := lapply(.SD, roll_avg_fun, n = lag), 
#           by = .(date_col), 
#           .SDcols = variables_to_compare]
# }

7424880
nrow(model_data)
model_data <- model_data[year>=1950 ]
saveRDS(model_data, file="/home/smmrrr/TEM_Analysis/TEM_Analysis/model_data_MARS_tropical_historical.RDS")
nrow(model_data)
model_data <- model_data[ SOILORGC<30000 & AVAILN < 10000 & NETNMIN < 10000]
nrow(model_data)
model_data[, (names(model_data)) := lapply(.SD, function(x) replace(x, is.infinite(x), NA))]
model_data <- na.omit(model_data)
nrow(model_data)
unique(model_data$i.region)
colnames(model_data )

model_data[, VEGC_yy :=VEGC- VEGC_1_shift]
model_data[, VEGC_20y :=VEGC- VEGC_rolling_20]
model_data[, SOILORGC_yy :=SOILORGC- SOILORGC_1_shift]
hist(model_data$SOILORGC_yy)
hist(model_data[VEGC_yy %between% c(-1000,1000), VEGC_yy], breaks=40)
hist(model_data[VEGC_ratio %between% c(-5000,10000), VEGC_ratio], breaks=40)
hist(model_data$SOILORGC_ratio)
hist(model_data$VEGC_ratio)
model_data[lon==26&lat==0&ordinal_stand_age==8, .(year,VEGC, VEGC_yy, VEGC_1_shift)]

features_ratio <- c("tswrf_v11_avg_ratio" ,   "tswrf_v11_min_ratio" ,   "tswrf_v11_max_ratio" ,   "tmp_avg_ratio" ,        
"tmp_min_ratio" ,         "tmp_max_ratio" ,         "precip_avg_ratio" ,      "precip_min_ratio" ,     
"precip_max_ratio" ,      "dtr_avg_ratio" ,         "dtr_min_ratio" ,         "dtr_max_ratio" ,        
"vpr_avg_ratio" ,         "vpr_min_ratio" ,         "vpr_max_ratio" ,         "wind_avg_ratio" ,       
"wind_min_ratio" ,        "wind_max_ratio" ,        "Ndep_Trendy_ratio" ,     "Nfer_crop_ratio" ,      
"Nfer_pas_ratio" ,    "co2_ratio", "s1" ,"s2" , "s3" ,  
"elev" ,"ordinal_stand_age" 
)

present_features <- c("tswrf_v11_avg" ,"tswrf_v11_min" , "tswrf_v11_max" ,
              "tmp_avg" ,"tmp_min" , "tmp_max" ,
              "precip_avg" , "precip_min" , "precip_max" ,
              "dtr_avg" , "dtr_min" , "dtr_max" ,
              "vpr_avg" , "vpr_min" , "vpr_max" ,
              "wind_avg" ,"wind_min" ,"wind_max" ,  
              "Ndep_Trendy" ,"Nfer_crop" ,  "Nfer_pas" ,  
              "s1" ,"s2" , "s3" ,  
              "elev" ,  "co2" ,"ordinal_stand_age" )



present_ratio_features <- c("ordinal_stand_age","tswrf_v11_avg",  "tswrf_v11_min", 
                  "tswrf_v11_max",  "tmp_avg","tmp_min","tmp_max","precip_avg",
                  "precip_min", "precip_max", "dtr_avg","dtr_min","dtr_max",   
                  "vpr_avg","vpr_min","vpr_max","wind_avg",   "wind_min",  
                  "wind_max",   "Ndep_Trendy","Nfer_crop",  "Nfer_pas", "s1", "s2", "s3", "elev",   "co2",   
                  "tswrf_v11_avg_ratio","tswrf_v11_min_ratio"   ,
                  "tswrf_v11_max_ratio","tmp_avg_ratio",  "tmp_min_ratio",  "tmp_max_ratio",  "precip_avg_ratio",  
                  "precip_min_ratio",   "precip_max_ratio",   "dtr_avg_ratio",  "dtr_min_ratio",  "dtr_max_ratio", 
                  "vpr_avg_ratio",  "vpr_min_ratio",  "vpr_max_ratio",  "wind_avg_ratio", "wind_min_ratio",
                  "wind_max_ratio", "Ndep_Trendy_ratio",  "Nfer_crop_ratio","Nfer_pas_ratio", "co2_ratio")

present_lag_features <- c("ordinal_stand_age","tswrf_v11_avg",  "tswrf_v11_min", 
                          "tswrf_v11_max",  "tmp_avg","tmp_min","tmp_max","precip_avg",
                          "precip_min", "precip_max", "dtr_avg","dtr_min","dtr_max",   
                          "vpr_avg","vpr_min","vpr_max","wind_avg",   "wind_min",  
                          "wind_max",   "Ndep_Trendy","Nfer_crop",  "Nfer_pas", "s1", "s2", "s3", "elev",   "co2",   
                          "tswrf_v11_avg_rolling_5","tswrf_v11_min_rolling_5"   ,
                          "tswrf_v11_max_rolling_5","tmp_avg_rolling_5",  "tmp_min_rolling_5",  "tmp_max_rolling_5",  "precip_avg_rolling_5",  
                          "precip_min_rolling_5",   "precip_max_rolling_5",   "dtr_avg_rolling_5",  "dtr_min_rolling_5",  "dtr_max_rolling_5", 
                          "vpr_avg_rolling_5",  "vpr_min_rolling_5",  "vpr_max_rolling_5",  "wind_avg_rolling_5", "wind_min_rolling_5",
                          "wind_max_rolling_5", "Ndep_Trendy_rolling_5",  "Nfer_crop_rolling_5","Nfer_pas_rolling_5", "co2_rolling_5",                   "tswrf_v11_avg_rolling_20","tswrf_v11_min_rolling_20"   ,
                          "tswrf_v11_max_rolling_20","tmp_avg_rolling_20",  "tmp_min_rolling_20",  "tmp_max_rolling_20",  "precip_avg_rolling_20",  
                          "precip_min_rolling_20",   "precip_max_rolling_20",   "dtr_avg_rolling_20",  "dtr_min_rolling_20",  "dtr_max_rolling_20", 
                          "vpr_avg_rolling_20",  "vpr_min_rolling_20",  "vpr_max_rolling_20",  "wind_avg_rolling_20", "wind_min_rolling_20",
                          "wind_max_rolling_20", "Ndep_Trendy_rolling_20",  "Nfer_crop_rolling_20","Nfer_pas_rolling_20", "co2_rolling_20", 
                          "tswrf_v11_avg_1_shift" , "tswrf_v11_min_1_shift",  "tswrf_v11_max_1_shift" , "tmp_avg_1_shift",
                          "tmp_min_1_shift","tmp_max_1_shift","precip_avg_1_shift", "precip_min_1_shift", "precip_max_1_shift", "dtr_avg_1_shift",
                          "dtr_min_1_shift","dtr_max_1_shift","vpr_avg_1_shift","vpr_min_1_shift","vpr_max_1_shift",  
                          "Ndep_Trendy_1_shift","Nfer_crop_1_shift",  "Nfer_pas_1_shift" )


shift_features <- c("ordinal_stand_age","tswrf_v11_avg",  "tswrf_v11_min", 
                  "tswrf_v11_max",  "tmp_avg","tmp_min","tmp_max","precip_avg",
                  "precip_min", "precip_max", "dtr_avg","dtr_min","dtr_max",   
                  "vpr_avg","vpr_min","vpr_max","wind_avg",   "wind_min",  
                  "wind_max",   "Ndep_Trendy","Nfer_crop",  "Nfer_pas", "s1", "s2", "s3", "elev",   "co2",   
                  "tswrf_v11_avg_1_shift" , "tswrf_v11_min_1_shift",  "tswrf_v11_max_1_shift" , "tmp_avg_1_shift",
                  "tmp_min_1_shift","tmp_max_1_shift","precip_avg_1_shift", "precip_min_1_shift", "precip_max_1_shift", "dtr_avg_1_shift",
                  "dtr_min_1_shift","dtr_max_1_shift","vpr_avg_1_shift","vpr_min_1_shift","vpr_max_1_shift",  
                  "Ndep_Trendy_1_shift","Nfer_crop_1_shift",  "Nfer_pas_1_shift" )


# Initialize an empty list to store the correlation results
cor_list <- list()

# Loop through the specific column names
for (col in colnames(model_data)[grepl("avg|min|max", colnames(model_data))]) {
  # Create a list to hold the correlation coefficients for the current column
  cor_values <- list(Column = col)
  
  # Calculate the correlation for each of the specific pairs and add to the list
  cor_values[['VEGC']] <- cor(model_data[[col]], model_data[['VEGC']], use = "complete.obs")
  cor_values[['VEGC_yy']] <- cor(model_data[[col]], model_data[['VEGC_yy']], use = "complete.obs")
  cor_values[['VEGC_ratio']] <- cor(model_data[[col]], model_data[['VEGC_ratio']], use = "complete.obs")
  cor_values[['VEGC_20y']] <- cor(model_data[[col]], model_data[['VEGC_20y']], use = "complete.obs")
  cor_values[['NPP']] <- cor(model_data[[col]], model_data[['NPP']], use = "complete.obs")
  
  # Append this list of correlations for the column to the overall list
  cor_list[[col]] <- cor_values
  print(col)
}

# Combine the list of correlation values into a data.table
cor_dt <- rbindlist(lapply(cor_list, as.list), fill = TRUE, use.names = TRUE)
cor_dt_long <- melt(cor_dt, id.vars = "Column", variable.name = "Variable", value.name = "Correlation")
cor_dt_long

ggplot(cor_dt_long[grepl("Base", Column)], aes(x = Variable, y = Column, fill = Correlation)) +
  geom_tile(color = "white") + # Use white lines to separate the tiles
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0, limit = c(-1, 1), space = "Lab", name="Correlation Coefficient") +
  theme_minimal() + # Minimal theme
  theme(axis.text.x = element_text(angle = 45, hjust = 1), # Rotate x axis labels
        axis.title = element_blank()) # Remove axis titles if not needed




# Create the predictor matrix and response vector
names(dt)[apply(is.na(dt), 2, any)]

##### NPP model
X <- model_data[VEGC_yy %between% c(-1000,1000), ..shift_features]
Y <- model_data[VEGC_yy %between% c(-1000,1000),.(VEGC_ratio, VEGC, VEGC_yy, NPP, VEGC_20y )]

trainIndex <- createDataPartition(Y$VEGC, p = 0.7, list = FALSE)
# X_train_ratio <- X_ratio[trainIndex, ]
# X_test_ratio <- X_ratio[-trainIndex, ]
X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]
y_train <- Y[trainIndex,]
y_test <- Y[-trainIndex,]

X <- model_data[VEGC_yy %between% c(-1000,1000), ..yy_features]
X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]

#####NPP with shift features
earth.npp_yy <- earth(y=y_train$NPP, x=X_train, degree=2)
summary(earth.npp_yy)
# save(earth.npp_yy, file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.npp_yy.rda")

X <- model_data[VEGC_yy %between% c(-1000,1000), ..present_features]
X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]

#####NPP with shift features
earth.npp <- earth(y=y_train$NPP, x=X_train, degree=2)
summary(earth.npp)
save(earth.npp, file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.npp.rda")

### .2 rsquared with shift features
cor_npp <- c("ordinal_stand_age", "s1","s2","s3","co2"
  ,cor_dt[abs(NPP) > .2,Column]
)
X <- model_data[VEGC_yy %between% c(-1000,1000), ..cor_npp]
X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]


earth.npp_highcor <- earth(y=y_train$NPP, x=X_train, degree=2)
summary(earth.npp_highcor)
save(earth.npp_highcor, file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.npp_highcor.rda")

#####VEGC, soilorgc with present time step
X <- model_data[VEGC_yy %between% c(-1000,1000), ..present_features]
X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]


earth.vegc <- earth(y=y_train$VEGC, x=X_train, degree=2)
summary(earth.vegc)

save(earth.vegc, file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.vegc.rda")
earth.vegc2 <- earth.vegc
load("/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.vegc.rda")
y_pred  <- predict(earth.vegc , X_test)

#####VEGC, soilorgc with present features
cor_vegc <- c("ordinal_stand_age", "s1","s2","s3","co2"
             ,cor_dt[abs(VEGC) > .15,Column]
)
X <- model_data[VEGC_yy %between% c(-1000,1000), ..cor_vegc]
X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]

earth.vegc_highcor <- earth(y=y_train$VEGC, x=X_train, degree=2)
summary(earth.vegc_highcor)

save(earth.vegc_highcor, file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.vegc_highcor.rda")

#####VEGC ratio with lag and present features



X <- model_data[VEGC_yy %between% c(-1000,1000), ..present_ratio_features]
X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]

earth.vegc_ratio <- earth(y=y_train$VEGC_ratio, x=X_train, degree=2)
summary(earth.vegc_ratio)

save(earth.vegc_ratio, file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.vegc_ratio.rda")


#####VEGC ratio with all features
cor_vegc_ratio <- c("ordinal_stand_age", "s1","s2","s3","co2"
              ,cor_dt[abs(VEGC_ratio) > .07,Column]
)
X <- model_data[VEGC_yy %between% c(-1000,1000), ..cor_vegc_ratio]
X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]

earth.vegc_ratio_highcor <- earth(y=y_train$VEGC_ratio, x=X_train, degree=2)
summary(earth.vegc_ratio_highcor)

save(earth.vegc_ratio_highcor, file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.vegc_ratio_highcor.rda")


#####VEGC diff from 20 year with all features

X <- model_data[VEGC_yy %between% c(-1000,1000), ..present_ratio_features]
X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]

earth.soilorgc_ratio <- earth(y=y_train$SOILORGC_ratio, x=X_train, degree=2)
summary(earth.soilorgc_ratio)

save(earth.soilorgc_ratio, file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.soilorgc_ratio.rda")




X <- model_data[VEGC_yy %between% c(-1000,1000), ..present_features]
X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]


earth.soilorgc <- earth(y=y_train$VEGC, x=X_train, degree=2)
summary(earth.soilorgc)

save(earth.soilorgc, file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.soilorgc.rda")

resid <- y_test$VEGC-y_pred
# length(y_pred[y_pred<0])/length(y_pred)
sqrt(mean(resid^2))
1-(sum((y_test$VEGC-y_pred)^2)/sum((y_test$VEGC-mean(y_test$VEGC))^2 ))







summary(earth.vegc_ratio)
summary(earth.vegc)
summary(earth.soilorgc)
summar <- (earth.NPP)
summary(earth.GPP)

plot(evimp(earth.vegc))
plot(evimp(earth.vegc_ratio))
plot(evimp(earth.NPP))
plot(evimp(earth.GPP))

plot((earth.vegc))
plotmo((earth.vegc))
sqrt(mean(test_data$resid_vegc^2))
1-(sum(test_data$resid_vegc^2)/sum((test_data$VEGC-mean(test_data$VEGC))^2 ))

plot((earth.vegc_ratio))
plotmo((earth.vegc_ratio))
sqrt(mean(test_data$resid_vegc_ratio^2))
1-(sum(test_data$resid_vegc_ratio^2)/sum((test_data$VEGC_ratio-mean(test_data$VEGC_ratio))^2 ))

plot((earth.NPP))
plotmo((earth.NPP))
sqrt(mean(test_data$resid_NPP^2))
1-(sum(test_data$resid_NPP^2)/sum((test_data$NPP-mean(test_data$NPP))^2 ))

plot((earth.GPP))
plotmo((earth.GPP))
sqrt(mean(test_data$resid_GPP^2))
1-(sum(test_data$resid_GPP^2)/sum((test_data$GPP-mean(test_data$GPP))^2 ))


# earth.mod$rsq.per.response
plotmo(earth.vegc_ratio)
# plotmo(earth.mod,nresponse = 2)
summary(earth.vegc_ratio, digits = 2, style = "pmax")
plot(earth.vegc_ratio)

print("VEGC Ratio")
y_pred_vegc_ratio  <- predict(earth.vegc_ratio , X_test_ratio)
y_pred_vegc  <- predict(earth.vegc , X_test)
y_pred_soilorgc  <- predict(earth.soilorgc , X_test)
y_pred_NPP  <- predict(earth.NPP , X_test)
y_pred_GPP  <- predict(earth.GPP , X_test)

resid <- y_test-y_pred
length(y_pred[y_pred<0])/length(y_pred)
sqrt(mean(resid^2))
1-(sum((y_test-y_pred)^2)/sum((y_test-mean(y_test))^2 ))

### scatter plot of predicted versus actuals
# important predictors by variable


test_data <- model_data[-trainIndex,.(year, stand_age_interval_min
                                      ,VEGC_ratio, VEGC, SOILORGC, NPP, GPP, NCE)]

test_data[,y_pred_vegc_ratio:=y_pred_vegc_ratio]  
test_data[,y_pred_vegc:=y_pred_vegc] 
test_data[,y_pred_soilorgc:=y_pred_soilorgc] 
test_data[,y_pred_NPP:=y_pred_NPP]
test_data[,y_pred_GPP:=y_pred_GPP]

test_data[,resid_vegc_ratio:=y_pred_vegc_ratio - VEGC_ratio]  
test_data[,resid_vegc:=y_pred_vegc - VEGC] 
test_data[,resid_NPP:=y_pred_NPP - NPP]
test_data[,resid_GPP:=y_pred_GPP - GPP]

plot(test_data$VEGC, test_data$resid_vegc, 
     main = "Simple Scatterplot", # Title of the plot
     xlab = "VEGC",       # Label for the x-axis
     ylab = "Residual",       # Label for the y-axis
     col = "skyblue",                # Color of points
     
     pch = 16
     # ,                    # Type of points (16 is solid circle)
     # xlim = c(0, 6),              # X-axis limits
     # ylim = c(0, 7)               # Y-axis limits
)

plot(test_data$year, test_data$resid_vegc, 
     main = "Simple Scatterplot", # Title of the plot
     xlab = "year",       # Label for the x-axis
     ylab = "Residual",       # Label for the y-axis
     col = "skyblue",                # Color of points
     
     pch = 16
     # ,                    # Type of points (16 is solid circle)
     # xlim = c(0, 6),              # X-axis limits
     # ylim = c(0, 7)               # Y-axis limits
)


ggplot(test_data, aes(x = year, y = resid_vegc)) +
  stat_summary(fun = mean, geom = "col") + # To show the mean value per year
  theme_minimal() +
  labs(x = "Year", y = "VEGC Residual", title = "Mean Value by Year")

ggplot(test_data, aes(x = stand_age_interval_min, y = resid_vegc)) +
  stat_summary(fun = mean, geom = "col") + # To show the mean value per year
  theme_minimal() +
  labs(x = "Stand Age", y = "VEGC Residual", title = "Mean Value by Stand Age")

ggplot(test_data, aes(x = year, y = resid_vegc_ratio)) +
  stat_summary(fun = mean, geom = "col") + # To show the mean value per year
  theme_minimal() +
  labs(x = "Year", y = "VEGC Ratio Residual", title = "Mean Value by Year")

ggplot(test_data, aes(x = stand_age_interval_min, y = resid_vegc_ratio)) +
  stat_summary(fun = mean, geom = "col") + # To show the mean value per year
  theme_minimal() +
  labs(x = "Stand Age", y = "VEGC Ratio Residual", title = "Mean Value by Stand Age")

ggplot(test_data, aes(x = year, y = resid_NPP)) +
  stat_summary(fun = mean, geom = "col") + # To show the mean value per year
  theme_minimal() +
  labs(x = "Year", y = "NPP Residual", title = "Mean Value by Year")

ggplot(test_data, aes(x = year, y = resid_GPP)) +
  stat_summary(fun = mean, geom = "col") + # To show the mean value per year
  theme_minimal() +
  labs(x = "Year", y = "GPP Residual", title = "Mean Value by Year")

ggplot(test_data, aes(x = stand_age_interval_min, y = resid_NPP)) +
  stat_summary(fun = mean, geom = "col") + # To show the mean value per year
  theme_minimal() +
  labs(x = "Stand Age", y = "NPP Residual", title = "Mean Value by Stand Age")

ggplot(test_data, aes(x = stand_age_interval_min, y = resid_GPP)) +
  stat_summary(fun = mean, geom = "col") + # To show the mean value per year
  theme_minimal() +
  labs(x = "Stand Age", y = "GPP Residual", title = "Mean Value by Stand Age")


 plot(test_data$stand_age_interval_min, test_data$resid_vegc, 
     main = "Simple Scatterplot", # Title of the plot
     xlab = "Stand Age",       # Label for the x-axis
     ylab = "Residual",       # Label for the y-axis
     col = "skyblue",                # Color of points
     
     pch = 16
     # ,                    # Type of points (16 is solid circle)
     # xlim = c(0, 6),              # X-axis limits
     # ylim = c(0, 7)               # Y-axis limits
)

plot(test_data$VEGC, test_data$resid_vegc, 
     main = "Simple Scatterplot", # Title of the plot
     xlab = "VEGC",       # Label for the x-axis
     ylab = "Residual",       # Label for the y-axis
     col = "skyblue",                # Color of points
     
     pch = 16
     # ,                    # Type of points (16 is solid circle)
     # xlim = c(0, 6),              # X-axis limits
     # ylim = c(0, 7)               # Y-axis limits
)


plot(test_data$VEGC_ratio, test_data$resid_vegc_ratio, 
     main = "Simple Scatterplot", # Title of the plot
     xlab = "VEGC Ratio",       # Label for the x-axis
     ylab = "Residual",       # Label for the y-axis
     col = "skyblue",                # Color of points
     
     pch = 16
     # ,                    # Type of points (16 is solid circle)
     # xlim = c(0, 6),              # X-axis limits
     # ylim = c(0, 7)               # Y-axis limits
)

plot(test_data$NPP, test_data$resid_NPP, 
     main = "Simple Scatterplot", # Title of the plot
     xlab = "NPP",       # Label for the x-axis
     ylab = "Residual",       # Label for the y-axis
     col = "skyblue",                # Color of points
     
     pch = 16
     # ,                    # Type of points (16 is solid circle)
     # xlim = c(0, 6),              # X-axis limits
     # ylim = c(0, 7)               # Y-axis limits
)


plot(test_data$GPP, test_data$resid_GPP, 
     main = "Simple Scatterplot", # Title of the plot
     xlab = "GPP",       # Label for the x-axis
     ylab = "Residual",       # Label for the y-axis
     col = "skyblue",                # Color of points
     
     pch = 16
     # ,                    # Type of points (16 is solid circle)
     # xlim = c(0, 6),              # X-axis limits
     # ylim = c(0, 7)               # Y-axis limits
)
### residuals by stand age
### residuals by year




# Create the predictor matrix and response vector

X <- model_data[, ..features]
Y <- model_data$VEGC


earth.vegc <- earth(y=y_train, x=X_train, degree=6)
# earth.mod$rsq.per.response
plotmo(earth.vegc)
# plotmo(earth.mod,nresponse = 2)
summary(earth.vegc, digits = 2, style = "pmax")
plot(earth.vegc)

print("VEGC")
y_pred <- predict(earth.mod, X_test)
resid <- y_test-y_pred
length(y_pred[y_pred<0])/length(y_pred)
sqrt(mean(resid^2))
1-(sum((y_test-y_pred)^2)/sum((y_test-mean(y_test))^2 ))



X <- model_data[, ..features]
Y <- model_data$GPP


earth.gpp <- earth(y=y_train, x=X_train, degree=6)
# earth.mod$rsq.per.response
plotmo(earth.vegc)
# plotmo(earth.mod,nresponse = 2)
summary(earth.vegc, digits = 2, style = "pmax")
plot(earth.vegc)

print("GPP")
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




