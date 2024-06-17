library(earth)
library(caret)
library(dplyr)
library(tidyr)
library(zoo)
library(data.table)
library(stats)

# Set seed for reproducibility
set.seed(42)

pfts <- c("Tropical", "Temperate_Broadleaf","Temperate_Deciduous","Temperate_Coniferous","Boreal")
pft <- pfts[3]
tropical_model_data <- rbindlist(list(
  fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[1],'_trainingset_r_1_9.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[1],'_trainingset_r_10_19.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[1],'_trainingset_r_20_29.csv'))
))

temperate_broadleaf_model_data <- rbindlist(list(
  fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[2],'_trainingset_r_1_9.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[2],'_trainingset_r_10_19.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[2],'_trainingset_r_20_29.csv'))
))

temperate_deciduous_model_data <- rbindlist(list(
  fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[3],'_trainingset_r_1_9.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[3],'_trainingset_r_10_19.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[3],'_trainingset_r_20_29.csv'))
))

temperate_coniferous_model_data <- rbindlist(list(
  fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[4],'_trainingset_r_1_9.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[4],'_trainingset_r_10_19.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[4],'_trainingset_r_20_29.csv'))
))

boreal_model_data <- rbindlist(list(
  fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[5],'_trainingset_r_1_9.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[5],'_trainingset_r_10_19.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[5],'_trainingset_r_20_29.csv'))
))

input_data <- fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/global_input_vars.csv')

tropical_model_data <- input_data[tropical_model_data, on = c('lon','lat','year')]

temperate_broadleaf_model_data <- input_data[temperate_broadleaf_model_data, on = c('lon','lat','year')]

temperate_deciduous_model_data <- input_data[temperate_deciduous_model_data, on = c('lon','lat','year')]

temperate_coniferous_model_data <- input_data[temperate_coniferous_model_data, on = c('lon','lat','year')]

boreal_model_data <- input_data[boreal_model_data, on = c('lon','lat','year')]

# nrow(model_data)
# model_data <- model_data[year>=1950 ]
tropical_model_data <- tropical_model_data[year >=1950]

temperate_broadleaf_model_data <- temperate_broadleaf_model_data[year >=1950]

temperate_deciduous_model_data <- temperate_deciduous_model_data[year >=1950]

temperate_coniferous_model_data <- temperate_coniferous_model_data[year >=1950]

boreal_model_data <- boreal_model_data[year >=1950]



present_features <- c("tswrf_v11_avg" ,"tswrf_v11_min" , "tswrf_v11_max" ,
                      "tmp_avg" ,"tmp_min" , "tmp_max" ,
                      "precip_avg" , "precip_min" , "precip_max" ,
                      "dtr_avg" , "dtr_min" , "dtr_max" ,
                      "vpr_avg" , "vpr_min" , "vpr_max" ,
                      "wind_avg" ,"wind_min" ,"wind_max" ,  
                      "Ndep_Trendy" ,"Nfer_crop" ,  "Nfer_pas" ,  
                      "s1" ,"s2" , "s3" ,  
                      "elev" ,  "co2" ,"ordinal_stand_age" )

# hist(tropical_model_data$VEGC)
# hist(temperate_broadleaf_model_data$VEGC)
# hist(temperate_deciduous_model_data$VEGC)
# hist(temperate_coniferous_model_data$VEGC)
# hist(boreal_model_data$VEGC)
# 
# hist(tropical_model_data$SOILORGC)
# hist(temperate_broadleaf_model_data$SOILORGC)
# hist(temperate_deciduous_model_data$SOILORGC)
# hist(temperate_coniferous_model_data$SOILORGC)
# hist(boreal_model_data$SOILORGC)
# 
# hist(tropical_model_data$NPP)
# hist(temperate_broadleaf_model_data$NPP)
# hist(temperate_deciduous_model_data$NPP)
# hist(temperate_coniferous_model_data$NPP)
# hist(boreal_model_data$NPP)

###tropical
hist(model_data[ SOILORGC<15000 , SOILORGC])
nrow(model_data[ SOILORGC<15000])/nrow(model_data)

nrow(tropical_model_data[ SOILORGC<15000& VEGC < 34000 ])/nrow(tropical_model_data)
nrow(temperate_broadleaf_model_data[ SOILORGC<15000& VEGC < 34000 ])/nrow(temperate_broadleaf_model_data)
nrow(temperate_deciduous_model_data[ SOILORGC<15000& VEGC < 34000 ])/nrow(temperate_deciduous_model_data)
nrow(temperate_coniferous_model_data[ SOILORGC<15000& VEGC < 34000 ])/nrow(temperate_coniferous_model_data)
nrow(boreal_model_data[ SOILORGC<15000& VEGC < 34000 ])/nrow(boreal_model_data)

###deciduous
tropical_model_data <- tropical_model_data[ SOILORGC<15000& VEGC < 34000 ]
temperate_broadleaf_model_data <- temperate_broadleaf_model_data[ SOILORGC<15000& VEGC < 34000 ]
temperate_deciduous_model_data <- temperate_deciduous_model_data[ SOILORGC<15000& VEGC < 34000 ]
temperate_coniferous_model_data <- temperate_coniferous_model_data[ SOILORGC<15000& VEGC < 34000 ]
boreal_model_data <- boreal_model_data[ SOILORGC<15000& VEGC < 34000 ]


# model_data <- na.omit(model_data)
# 
# X <- model_data[, ..present_features]
# Y <- model_data[,.(VEGC, SOILORGC, NPP)]
# 
# 
# trainIndex <- createDataPartition(Y$VEGC, p = 0.7, list = FALSE)
# 
# X_train <- X[trainIndex, ]
# X_test <- X[-trainIndex, ]
# y_train <- Y[trainIndex,]
# y_test <- Y[-trainIndex,]
# 
# earth.VEGC.tropical <- earth.VEGC
# 
# earth.VEGC <- earth(y=y_train$VEGC, x=X_train, degree=2)
# summary(earth.VEGC)
# earth.SOILORGC <- earth(y=y_train$SOILORGC, x=X_train, degree=2)
# summary(earth.VEGC)
# earth.NPP <- earth(y=y_train$NPP, x=X_train, degree=2)
# summary(earth.VEGC)
