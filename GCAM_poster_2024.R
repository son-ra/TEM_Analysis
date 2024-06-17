load("/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_temperate_deciduous_earth.VEGC.rda")
summary(GFDL_ssp245_temperate_deciduous_earth.VEGC)
GFDL_ssp245_temperate_deciduous_earth.VEGC$coefficients
plotmo(GFDL_ssp245_temperate_deciduous_earth.VEGC)
plotmo(hist_temperate_deciduous_earth.VEGC)

plot(evimp(GFDL_ssp245_temperate_deciduous_earth.VEGC))
plot(evimp(hist_temperate_deciduous_earth.VEGC))


# h(tswrf_v11_max-297.35)                       -23.0586977
# h(297.35-tswrf_v11_max)                       -26.9248913
# h(tmp_max-28.5)                              -752.7902132
# h(28.5-tmp_max)                             -1369.2408050



pfts <- c("Tropical", "Temperate_Broadleaf","Temperate_Deciduous","Temperate_Coniferous","Boreal")

input_data <- fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL-ESM4_ssp245_global_input_vars.csv')
clm_features <- c("nirr_avg", "nirr_min", "nirr_max", "prec_avg",
                  "prec_min", "prec_max", "tair_avg", "tair_min", "tair_max",
                  "trange_avg", "trange_min", "trange_max", "vpr_avg",
                  "vpr_min", "vpr_max", "wind_avg", "wind_min",
                  "wind_max" ,"s1" ,"s2" , "s3" ,  
                  "elev" ,  "co2" ,"ordinal_stand_age")

present_features <- c("nirr_avg", "nirr_min", "nirr_max", "prec_avg",
                  "prec_min", "prec_max", "tair_avg", "tair_min", "tair_max",
                  "trange_avg", "trange_min", "trange_max", "vpr_avg",
                  "vpr_min", "vpr_max", "wind_avg", "wind_min",
                  "wind_max" ,"s1" ,"s2" , "s3" ,  
                  "elev" ,  "co2" , "AOT40_rcp45_avg" ,"AOT40_rcp45_min",
                  "AOT40_rcp45_max", "Ndep_rcp45"     ,
                  "Nfer_crop"    ,   "Nfer_pas" ,
                  "ordinal_stand_age")
tt <- cor(boreal_model_data[,c(present_features, "VEGC")])

tropical_model_data <- fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/','GFDL-ESM4_ssp245_',pfts[1],'_trainingset_r_1_29.csv'))



tropical_model_data <- input_data[tropical_model_data, on = c('lon','lat','year')]

tropical_model_data <- tropical_model_data[year >=2020]

hist(tropical_model_data$VEGC)

hist(tropical_model_data$SOILORGC)

nrow(tropical_model_data[ SOILORGC<15000& VEGC < 30000 ])/nrow(tropical_model_data)
tropical_model_data <- tropical_model_data[ SOILORGC<15000& VEGC < 30000 ]

hist(tropical_model_data$VEGC)

hist(tropical_model_data$SOILORGC)

hist(tropical_model_data$NPP)



X <- tropical_model_data[, ..clm_features] 
Y <- tropical_model_data[, .(stand_age_interval_min,VEGC,SOILORGC,NPP)] 
trainIndex <- createDataPartition(Y$VEGC, p = 0.5, list = FALSE)

X_train <- X[trainIndex, ]
y_train <- Y[trainIndex,]


GFDL_ssp245_tropical_earth.VEGC <- earth(y=y_train$VEGC, x=X_train, degree=2)
# GFDL_ssp245_tropical_earth.NPP <- earth(y=y_train$NPP, x=X_train, degree=2)
# GFDL_ssp245_tropical_earth.SOILORGC <- earth(y=y_train$SOILORGC, x=X_train, degree=2)


summary(GFDL_ssp245_tropical_earth.VEGC)
# summary(GFDL_ssp245_tropical_earth.NPP)
# summary(GFDL_ssp245_tropical_earth.SOILORGC)



save(GFDL_ssp245_tropical_earth.VEGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_tropical_earth.VEGC.rda")
# save(GFDL_ssp245_tropical_earth.NPP,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_tropical_earth.NPP.rda")
# save(GFDL_ssp245_tropical_earth.SOILORGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_tropical_earth.SOILORGC.rda")
rm(X_train,y_train)

X_test <- X[-trainIndex, ]
y_test <- Y[-trainIndex,]


y_test$vegc_pred <- predict(GFDL_ssp245_tropical_earth.VEGC, X_test)
y_test$vegc_res <- y_test$VEGC - y_test$vegc_pred

paste("VEGC RMSE : ", sqrt(mean((y_test$vegc_res)^2)))
paste("VEGC R2 : ", 1 - (sum((y_test$vegc_res)^2))/ (sum((y_test$VEGC - mean(y_test$VEGC))^2)) )
nrow(y_test[vegc_pred<0])/nrow(y_test)
nrow(y_test[vegc_pred>30000])/nrow(y_test)
y_test[vegc_pred<0, vegc_pred:=0]

plot_kde_with_means(y_test[VEGC<1e5 & vegc_pred<30000], VEGC, vegc_pred, "VEGC", "Emulated VEGC")
plot_stand_age_range(y_test)


temperate_coniferous_model_data <- fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/','GFDL-ESM4_ssp245_',pfts[4],'_trainingset_r_1_29.csv'))
temperate_coniferous_model_data <- input_data[temperate_coniferous_model_data, on = c('lon','lat','year')]
temperate_coniferous_model_data <- temperate_coniferous_model_data[year >=2020]
hist(temperate_coniferous_model_data$VEGC)
hist(temperate_coniferous_model_data$SOILORGC)
hist(temperate_coniferous_model_data$NPP)
nrow(temperate_coniferous_model_data[ SOILORGC<15000& VEGC < 20000 ])/nrow(temperate_coniferous_model_data)
temperate_coniferous_model_data <- temperate_coniferous_model_data[ SOILORGC<15000& VEGC < 20000 ]


X <- temperate_coniferous_model_data[, ..clm_features]
Y <- temperate_coniferous_model_data[, .(VEGC,SOILORGC,NPP)]
trainIndex <- createDataPartition(Y$VEGC, p = 0.5, list = FALSE)

X_train <- X[trainIndex, ..clm_features]
# X_test <- X[-trainIndex, ]
y_train <- Y[trainIndex,.(VEGC,SOILORGC,NPP)]
# y_test <- Y[-trainIndex,]


GFDL_ssp245_temperate_coniferous_earth.VEGC <- earth(y=y_train$VEGC, x=X_train, degree=2)
GFDL_ssp245_temperate_coniferous_earth.NPP <- earth(y=y_train$NPP, x=X_train, degree=2)
GFDL_ssp245_temperate_coniferous_earth.SOILORGC <- earth(y=y_train$SOILORGC, x=X_train, degree=2)


summary(GFDL_ssp245_temperate_coniferous_earth.VEGC)
summary(GFDL_ssp245_temperate_coniferous_earth.NPP)
summary(GFDL_ssp245_temperate_coniferous_earth.SOILORGC)

save(GFDL_ssp245_temperate_coniferous_earth.VEGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_temperate_coniferous_earth.VEGC2.rda")
save(GFDL_ssp245_temperate_coniferous_earth.NPP,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_temperate_coniferous_earth.NPP.rda")
save(GFDL_ssp245_temperate_coniferous_earth.SOILORGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_temperate_coniferous_earth.SOILORGC.rda")


load("/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_temperate_coniferous_earth.VEGC.rda")

temperate_deciduous_model_data <- fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/','GFDL-ESM4_ssp245_',pfts[3],'_trainingset_r_1_29.csv'))
temperate_deciduous_model_data <- input_data[temperate_deciduous_model_data, on = c('lon','lat','year')]
temperate_deciduous_model_data <- temperate_deciduous_model_data[year >=2020]

hist(temperate_deciduous_model_data$VEGC)
hist(temperate_deciduous_model_data$SOILORGC)
nrow(temperate_deciduous_model_data[ SOILORGC<15000& VEGC < 25000 ])/nrow(temperate_deciduous_model_data)
temperate_deciduous_model_data <- temperate_deciduous_model_data[ SOILORGC<15000& VEGC < 25000 ]

X <- temperate_deciduous_model_data[, ..clm_features] 
# X <- temperate_deciduous_model_data[, ..present_features] 
Y <- temperate_deciduous_model_data[, .(stand_age_interval_min,VEGC,SOILORGC,NPP)] 
trainIndex <- createDataPartition(Y$VEGC, p = 0.5, list = FALSE)

X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]
y_train <- Y[trainIndex,]
y_test <- Y[-trainIndex,]


GFDL_ssp245_temperate_deciduous_earth.VEGC <- earth(y=y_train$VEGC, x=X_train, degree=2)
# GFDL_ssp245_temperate_deciduous_earth.VEGC_clm <- earth(y=y_train$VEGC, x=X_train, degree=2)
# GFDL_ssp245_temperate_deciduous_earth.NPP <- earth(y=y_train$NPP, x=X_train, degree=2)
# GFDL_ssp245_temperate_deciduous_earth.SOILORGC <- earth(y=y_train$SOILORGC, x=X_train, degree=2)
save(GFDL_ssp245_temperate_deciduous_earth.VEGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_temperate_deciduous_earth.VEGC.rda")
# save(GFDL_ssp245_temperate_deciduous_earth.NPP,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_temperate_deciduous_earth.NPP.rda")
# save(GFDL_ssp245_temperate_deciduous_earth.SOILORGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_temperate_deciduous_earth.SOILORGC.rda")


summary(GFDL_ssp245_temperate_deciduous_earth.VEGC)
# summary(GFDL_ssp245_temperate_deciduous_earth.NPP)
# summary(GFDL_ssp245_temperate_deciduous_earth.SOILORGC)
y_test$vegc_pred <- predict(GFDL_ssp245_temperate_deciduous_earth.VEGC, X_test)
y_test$vegc_res <- y_test$VEGC - y_test$vegc_pred

paste("VEGC RMSE : ", sqrt(mean((y_test$vegc_res)^2)))
paste("VEGC R2 : ", 1 - (sum((y_test$vegc_res)^2))/ (sum((y_test$VEGC - mean(y_test$VEGC))^2)) )
nrow(y_test[vegc_pred<0])/nrow(y_test)
y_test[vegc_pred<0, vegc_pred:=0]

plot_kde_with_means(y_test, VEGC, vegc_pred, "VEGC", "Emulated VEGC")

plot_stand_age_range(y_test)



boreal_model_data <- fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/','GFDL-ESM4_ssp245_',pfts[5],'_trainingset_r_1_29.csv'))
boreal_model_data <- input_data[boreal_model_data, on = c('lon','lat','year')]
boreal_model_data <- boreal_model_data[year >=2020]

hist(boreal_model_data$VEGC)
hist(boreal_model_data$SOILORGC)
nrow(boreal_model_data[ SOILORGC<17000& VEGC < 17000 ])/nrow(boreal_model_data)
boreal_model_data <- boreal_model_data[ SOILORGC<17000& VEGC < 17000 ]

X <- boreal_model_data[, ..clm_features] 
X <- boreal_model_data[, ..present_features] 
Y <- boreal_model_data[, .(stand_age_interval_min, VEGC,SOILORGC,NPP)] 
trainIndex <- createDataPartition(Y$VEGC, p = 0.5, list = FALSE)

X_train <- X[trainIndex, ]
y_train <- Y[trainIndex,]


GFDL_ssp245_boreal_earth.VEGC_chem <- earth(y=y_train$VEGC, x=X_train, degree=2)
GFDL_ssp245_boreal_earth.VEGC <- earth(y=y_train$VEGC, x=X_train, degree=2)
# GFDL_ssp245_boreal_earth.NPP <- earth(y=y_train$NPP, x=X_train, degree=2)
# GFDL_ssp245_boreal_earth.SOILORGC <- earth(y=y_train$SOILORGC, x=X_train, degree=2)

summary(GFDL_ssp245_boreal_earth.VEGC_chem)
summary(GFDL_ssp245_boreal_earth.VEGC)
summary(boreal_earth.VEGC)
# summary(GFDL_ssp245_boreal_earth.NPP)
# summary(GFDL_ssp245_boreal_earth.SOILORGC)

load("/home/smmrrr/TEM_Analysis/TEM_Analysis/boreal_earth.VEGC.rda")

save(GFDL_ssp245_boreal_earth.VEGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_boreal_earth.VEGC.rda")
save(GFDL_ssp245_boreal_earth.NPP,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_boreal_earth.NPP.rda")
save(GFDL_ssp245_boreal_earth.SOILORGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_boreal_earth.SOILORGC.rda")

X_test <- X[-trainIndex, ]
y_test <- Y[-trainIndex,]





temperate_coniferous_model_data <- fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/','GFDL-ESM4_ssp245_',pfts[4],'_trainingset_r_1_29.csv'))



tropical_model_data <- input_data[tropical_model_data, on = c('lon','lat','year')]

tropical_model_data <- tropical_model_data[year >=2020]

hist(tropical_model_data$VEGC)

hist(tropical_model_data$SOILORGC)

nrow(tropical_model_data[ SOILORGC<15000& VEGC < 30000 ])/nrow(tropical_model_data)
tropical_model_data <- tropical_model_data[ SOILORGC<15000& VEGC < 30000 ]

hist(tropical_model_data$VEGC)

hist(tropical_model_data$SOILORGC)

hist(tropical_model_data$NPP)



X <- tropical_model_data[, ..clm_features] 
Y <- tropical_model_data[, .(stand_age_interval_min,VEGC,SOILORGC,NPP)] 
trainIndex <- createDataPartition(Y$VEGC, p = 0.5, list = FALSE)

X_train <- X[trainIndex, ]
y_train <- Y[trainIndex,]


GFDL_ssp245_tropical_earth.VEGC <- earth(y=y_train$VEGC, x=X_train, degree=2)
# GFDL_ssp245_tropical_earth.NPP <- earth(y=y_train$NPP, x=X_train, degree=2)
# GFDL_ssp245_tropical_earth.SOILORGC <- earth(y=y_train$SOILORGC, x=X_train, degree=2)


summary(GFDL_ssp245_tropical_earth.VEGC)
# summary(GFDL_ssp245_tropical_earth.NPP)
# summary(GFDL_ssp245_tropical_earth.SOILORGC)



save(GFDL_ssp245_tropical_earth.VEGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_tropical_earth.VEGC.rda")
# save(GFDL_ssp245_tropical_earth.NPP,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_tropical_earth.NPP.rda")
# save(GFDL_ssp245_tropical_earth.SOILORGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_tropical_earth.SOILORGC.rda")
rm(X_train,y_train)

X_test <- X[-trainIndex, ]
y_test <- Y[-trainIndex,]


y_test$vegc_pred <- predict(GFDL_ssp245_tropical_earth.VEGC, X_test)
y_test$vegc_res <- y_test$VEGC - y_test$vegc_pred

paste("VEGC RMSE : ", sqrt(mean((y_test$vegc_res)^2)))
paste("VEGC R2 : ", 1 - (sum((y_test$vegc_res)^2))/ (sum((y_test$VEGC - mean(y_test$VEGC))^2)) )
nrow(y_test[vegc_pred<0])/nrow(y_test)
nrow(y_test[vegc_pred>30000])/nrow(y_test)
y_test[vegc_pred<0, vegc_pred:=0]

plot_kde_with_means(y_test[VEGC<1e5 & vegc_pred<30000], VEGC, vegc_pred, "VEGC", "Emulated VEGC")
plot_stand_age_range(y_test)

