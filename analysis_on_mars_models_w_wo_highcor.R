temperate_deciduous_model_data <- temperate_deciduous_model_data[ SOILORGC<15000& VEGC < 25000 ]


clm_features <- c("tswrf_v11_avg" ,"tswrf_v11_min" , "tswrf_v11_max" ,
                  "tmp_avg" ,"tmp_min" , "tmp_max" ,
                  "precip_avg" , "precip_min" , "precip_max" ,
                  "dtr_avg" , "dtr_min" , "dtr_max" ,
                  "vpr_avg" , "vpr_min" , "vpr_max" ,
                  "wind_avg" ,"wind_min" ,"wind_max" ,  
                  "s1" ,"s2" , "s3" ,  
                  "elev" ,  "co2" ,"ordinal_stand_age")
X <- temperate_deciduous_model_data[, ..clm_features] 
# X <- temperate_deciduous_model_data[, ..present_features] 
Y <- temperate_deciduous_model_data[, .(stand_age_interval_min,VEGC,SOILORGC,NPP)] 

trainIndex <- createDataPartition(Y$VEGC, p = 0.5, list = FALSE)

X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]
y_train <- Y[trainIndex,]
y_test <- Y[-trainIndex,]


hist_temperate_deciduous_earth.VEGC <- earth(y=y_train$VEGC, x=X_train, degree=2)
summary(hist_temperate_deciduous_earth.VEGC)
save(hist_temperate_deciduous_earth.VEGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/hist_temperate_deciduous_earth.VEGC.rda")
summary(hist_temperate_deciduous_earth.VEGC)




model_data <- readRDS("/home/smmrrr/TEM_Analysis/TEM_Analysis/model_data_MARS_tropical_historical.RDS")
model_data[,VEGC_yy := VEGC - VEGC_1_shift]
model_data[,SOILORGC_yy := SOILORGC - SOILORGC_1_shift]
model_data[,tswrf_v11_avg_yy := tswrf_v11_avg - tswrf_v11_avg_1_shift]
model_data[,tswrf_v11_min_yy := tswrf_v11_min - tswrf_v11_min_1_shift]
model_data[,tswrf_v11_max_yy := tswrf_v11_max - tswrf_v11_max_1_shift]

model_data[,tmp_avg_yy := tmp_avg - tmp_avg_1_shift]
model_data[,tmp_min_yy := tmp_min - tmp_min_1_shift]
model_data[,tmp_max_yy := tmp_max - tmp_max_1_shift]
model_data[,precip_avg_yy := precip_avg - precip_avg_1_shift]
model_data[,precip_min_yy := precip_min - precip_min_1_shift]

model_data[,precip_max_yy := precip_max - precip_max_1_shift]
model_data[,dtr_avg_yy := dtr_avg - dtr_avg_1_shift]
model_data[,dtr_min_yy := dtr_min - dtr_min_1_shift]
model_data[,dtr_max_yy := dtr_max - dtr_max_1_shift]
model_data[,vpr_avg_yy := vpr_avg - vpr_avg_1_shift]

model_data[,vpr_min_yy := vpr_min - vpr_min_1_shift]
model_data[,vpr_max_yy := vpr_max - vpr_max_1_shift]
model_data[,wind_avg_yy := wind_avg - wind_avg_1_shift]
model_data[,wind_min_yy := wind_min - wind_min_1_shift]
model_data[,wind_max_yy := wind_max - wind_max_1_shift]

model_data[,Ndep_Trendy_yy := Ndep_Trendy - Ndep_Trendy_1_shift]
model_data[,Nfer_crop_yy := Nfer_crop - Nfer_crop_1_shift]
model_data[,Nfer_pas_yy := Nfer_pas - Nfer_pas_1_shift]
model_data[,co2_yy := co2 - co2_1_shift]

load("/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.npp.rda")
load("/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.npp_highcor.rda")
load("/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.vegc.rda")
load("/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.vegc_highcor.rda")
load("/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.vegc_ratio.rda")
load("/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.vegc_ratio_highcor.rda")
# load("/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.soilorgc_ratio.rda")
load("/home/smmrrr/TEM_Analysis/TEM_Analysis/earth.soilorgc.rda")



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
yy_features <- c("s1" ,"s2" , "s3" ,  "eev" ,  "ordinal_stand_age"
                 , "tswrf_v11_avg_yy", "tswrf_v11_min_yy", "tswrf_v11_max_yy", "tmp_avg_yy",       "tmp_min_yy",      
                  "tmp_max_yy",       "precip_avg_yy",    "precip_min_yy",    "precip_max_yy",    "dtr_avg_yy",       "dtr_min_yy",       "dtr_max_yy",      
                 "vpr_avg_yy",       "vpr_min_yy",       "vpr_max_yy",       "wind_avg_yy",      "wind_min_yy",      "wind_max_yy",      "Ndep_Trendy_yy",  
                  "Nfer_crop_yy",     "Nfer_pas_yy",      "co2_yy" )

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
present_features <- c("tswrf_v11_avg" ,"tswrf_v11_min" , "tswrf_v11_max" ,
                      "tmp_avg" ,"tmp_min" , "tmp_max" ,
                      "precip_avg" , "precip_min" , "precip_max" ,
                      "dtr_avg" , "dtr_min" , "dtr_max" ,
                      "vpr_avg" , "vpr_min" , "vpr_max" ,
                      "wind_avg" ,"wind_min" ,"wind_max" ,  
                      "Ndep_Trendy" ,"Nfer_crop" ,  "Nfer_pas" ,  
                      "s1" ,"s2" , "s3" ,  
                      "elev" ,  "co2" ,"ordinal_stand_age" )

cor_npp <- c("ordinal_stand_age", "s1","s2","s3","co2"
             ,cor_dt[abs(NPP) > .2,Column]
)

cor_vegc <- c("ordinal_stand_age", "s1","s2","s3","co2"
              ,cor_dt[abs(VEGC) > .15,Column]
)
cor_vegc_ratio <- c("ordinal_stand_age", "s1","s2","s3","co2"
                    ,cor_dt[abs(VEGC_ratio) > .07,Column]
)


X_present_features <- model_data[VEGC_yy %between% c(-1000,1000), ..present_features]
X_present_ratio_features <- model_data[VEGC_yy %between% c(-1000,1000), ..present_ratio_features]
X_cor_npp <- model_data[VEGC_yy %between% c(-1000,1000), ..cor_npp]
X_cor_vegc <- model_data[VEGC_yy %between% c(-1000,1000), ..cor_vegc]
X_cor_vegc_ratio <- model_data[VEGC_yy %between% c(-1000,1000), ..cor_vegc_ratio]


Y <- model_data[VEGC_yy %between% c(-1000,1000),.(year, stand_age_interval_min,VEGC_ratio, VEGC, NPP, SOILORGC, SOILORGC_ratio )]

trainIndex <- createDataPartition(Y$VEGC, p = 0.7, list = FALSE)

X_present_features <- X_present_features[-trainIndex, ]
X_present_ratio_features <- X_present_ratio_features[-trainIndex, ]
X_cor_npp <- X_cor_npp[-trainIndex, ]
X_cor_vegc <- X_cor_vegc[-trainIndex, ]
X_cor_vegc_ratio <- X_cor_vegc_ratio[-trainIndex, ]

earth.npp$x <- X_present_features[trainIndex,]
earth.vegc$x <- X_present_features[trainIndex,]
earth.vegc_ratio$x <- X_present_ratio_features[trainIndex,]

y_train <- Y[trainIndex,]
y_test <- Y[-trainIndex,]

plot(evimp(earth.npp), main = 'NPP Variable Importance')
plot(evimp(earth.vegc), main = 'VEGC Variable Importance')
plot(evimp(earth.vegc_ratio), main = 'VEGC Delta Variable Importance')


plotmo(earth.npp)
plotmo(earth.vegc)
plotmo(earth.vegc_ratio)

y_test$npp_pred <- predict(earth.npp, X_present_features)
y_test$npp_highcor_pred <- predict(earth.npp_highcor, X_cor_npp)
y_test$vegc_pred <- predict(earth.vegc,  X_present_features)
y_test$vegc_highcor_pred <- predict(earth.vegc_highcor, X_cor_vegc)
y_test$vegc_ratio_pred <- predict(earth.vegc_ratio, X_present_ratio_features)
y_test$vegc_ratio_highcor_pred <- predict(earth.vegc_ratio_highcor, X_cor_vegc_ratio)
y_test$soilorgc_pred <- predict(earth.soilorgc,  X_present_features)

y_test$npp_res <- y_test$NPP - y_test$npp_pred
y_test$npp_highcor_res <- y_test$NPP - y_test$npp_highcor_pred
y_test$vegc_res <- y_test$VEGC - y_test$vegc_pred
y_test$vegc_highcor_res <- y_test$VEGC - y_test$vegc_highcor_pred
y_test$vegc_ratio_res <- y_test$VEGC_ratio - y_test$vegc_ratio_pred
y_test$vegc_ratio_highcor_res <- y_test$VEGC_ratio - y_test$vegc_ratio_highcor_pred
y_test$soilorgc_res <- y_test$SOILORGC - y_test$soilorgc_pred


###plot kde distribution plots
###variance over time and by stand age

paste("npp RMSE : ", sqrt(mean((y_test$npp_res)^2))*12)
paste("npp_highcor RMSE : ", sqrt(mean((y_test$npp_highcor_res)^2)))
paste("vegc RMSE : ", sqrt(mean((y_test$vegc_res)^2)))
paste("vegc_highcor RMSE : ", sqrt(mean((y_test$vegc_highcor_res)^2)))
paste("vegc_ratio RMSE : ", sqrt(mean((y_test$vegc_ratio_res)^2)))
paste("vegc_ratio_highcor RMSE : ", sqrt(mean((y_test$vegc_ratio_highcor_res)^2)))
paste("soilorgc RMSE : ", sqrt(mean((y_test$soilorgc_res)^2)))



paste("npp R2 : ", 1 - (sum((y_test$npp_res)^2))/ (sum((y_test$NPP - mean(y_test$NPP))^2)) )
paste("npp_highcor R2 : ", 1 - (sum((y_test$npp_highcor_res)^2))/ (sum((y_test$NPP - mean(y_test$NPP))^2)) )
paste("vegc R2 : ", 1 - (sum((y_test$vegc_res)^2))/ (sum((y_test$VEGC - mean(y_test$VEGC))^2)) )
paste("vegc_highcor R2 : ", 1 - (sum((y_test$vegc_highcor_res)^2))/ (sum((y_test$VEGC - mean(y_test$VEGC))^2)) )
paste("vegc_ratio R2 : ", 1 - (sum((y_test$vegc_ratio_res)^2))/ (sum((y_test$VEGC_ratio - mean(y_test$VEGC_ratio))^2)) )
paste("vegc_ratio_highcor R2 : ", 1 - (sum((y_test$vegc_ratio_highcor_res)^2))/ (sum((y_test$VEGC_ratio - mean(y_test$VEGC_ratio))^2)) )
paste("soilorgc R2 : ", 1 - (sum((y_test$soilorgc_res)^2))/ (sum((y_test$SOILORGC - mean(y_test$SOILORGC))^2)) )

ggplot(y_test, aes(x = year, y = npp_res*12)) +
  stat_summary(fun = mean, geom = "col", fill = 'cyan4') + # To show the mean value per year
  theme_minimal() +
  labs(x = "Year", y = "NPP Residual", title = "Mean Value by Year")

ggplot(y_test, aes(x = stand_age_interval_min, y = npp_res*12)) +
  stat_summary(fun = mean, geom = "col", fill = 'dodgerblue4') + # To show the mean value per year
  theme_minimal() +
  labs(x = "Stand Age", y = "NPP Residual", title = "Mean Value by Stand Age")


ggplot(y_test, aes(x = year, y = npp_res)) +
  stat_summary(fun = mean, geom = "col") + # To show the mean value per year
  theme_minimal() +
  labs(x = "Year", y = "NPP Residual", title = "Mean Value by Year")

ggplot(y_test, aes(x = stand_age_interval_min, y = npp_res)) +
  stat_summary(fun = mean, geom = "col") + # To show the mean value per year
  theme_minimal() +
  labs(x = "Stand Age", y = "NPP Residual", title = "Mean Value by Stand Age")


ggplot(y_test, aes(x = year, y = vegc_res)) +
  stat_summary(fun = mean, geom = "col", fill = 'cyan4') + # To show the mean value per year
  theme_minimal() +
  labs(x = "Year", y = "VEGC Residual", title = "Mean Value by Year")

ggplot(y_test, aes(x = stand_age_interval_min, y = vegc_res)) +
  stat_summary(fun = mean, geom = "col", fill = 'dodgerblue4') + # To show the mean value per year
  theme_minimal() +
  labs(x = "Stand Age", y = "VEGC Residual", title = "Mean Value by Stand Age")



ggplot(y_test, aes(x = year, y = vegc_ratio_res)) +
  stat_summary(fun = mean, geom = "col", fill = 'cyan4') + # To show the mean value per year
  theme_minimal() +
  labs(x = "Year", y = "VEGC Ratio Residual", title = "Mean Value by Year")


ggplot(y_test, aes(x = stand_age_interval_min, y = vegc_ratio_res)) +
  stat_summary(fun = mean, geom = "col", fill = 'dodgerblue4') + # To show the mean value per year
  theme_minimal() +
  labs(x = "Stand Age", y = "VEGC Ratio Residual", title = "Mean Value by Stand Age")


ggplot(y_test, aes(x = year, y = vegc_ratio_highcor_res)) +
  stat_summary(fun = mean, geom = "col", fill = 'cyan4') + # To show the mean value per year
  theme_minimal() +
  labs(x = "Year", y = "VEGC Ratio Residual", title = "Mean Value by Year")

###plot kde distribution plots

plot_kde_with_means(y_test, NPP, npp_pred, "NPP", "Emulated NPP")
plot_kde_with_means(y_test, NPP, npp_highcor_pred, "NPP", "Emulated NPP \n(cor vars)")

plot_kde_with_means(y_test, VEGC, vegc_pred, "VEGC", "Emulated VEGC")
plot_kde_with_means(y_test, VEGC, vegc_highcor_pred, "VEGC", "Emulated VEGC \n(cor vars)")

plot_kde_with_means(y_test, VEGC_ratio, vegc_ratio_pred, "VEGC_ratio", "Emulated VEGC_ratio")
plot_kde_with_means(y_test, VEGC_ratio, vegc_ratio_highcor_pred, "VEGC_ratio", "Emulated VEGC_ratio \n(cor vars)")

plot_kde_with_means(y_test, NPP, npp_pred, "NPP", "Emulated NPP")
plot_kde_with_means(y_test, NPP, npp_highcor_pred, "NPP", "Emulated NPP \n(cor vars)")


12*mean(y_test$NPP, na.rm = TRUE)
12*mean(y_test$npp_pred, na.rm = TRUE)
12*quantile(y_test$NPP, .25, na.rm = TRUE)
12*quantile(y_test$npp_pred, .25, na.rm = TRUE)
12*quantile(y_test$NPP, .75, na.rm = TRUE)
12*quantile(y_test$npp_pred, .75, na.rm = TRUE)

mean(y_test$VEGC, na.rm = TRUE)
mean(y_test$vegc_pred, na.rm = TRUE)
quantile(y_test$VEGC, .25, na.rm = TRUE)
quantile(y_test$vegc_pred, .25, na.rm = TRUE)
quantile(y_test$VEGC, .75, na.rm = TRUE)
quantile(y_test$vegc_pred, .75, na.rm = TRUE)

mean(y_test$VEGC_ratio, na.rm = TRUE)
mean(y_test$vegc_ratio_pred, na.rm = TRUE)
quantile(y_test$VEGC_ratio, .25, na.rm = TRUE)
quantile(y_test$vegc_ratio_pred, .25, na.rm = TRUE)
quantile(y_test$VEGC_ratio, .75, na.rm = TRUE)
quantile(y_test$vegc_ratio_pred, .75, na.rm = TRUE)





plot_kde_with_means <- function(data, var1, var2, var1_label, var2_label) {
  # Capture the variable expressions
  var1_expr <- enquo(var1)
  var2_expr <- enquo(var2)
  
  # Calculate the means
  mean_var1 <- mean(data[[quo_name(var1_expr)]], na.rm = TRUE)
  mean_var2 <- mean(data[[quo_name(var2_expr)]], na.rm = TRUE)
  quantile25_var1 <- quantile(data[[quo_name(var1_expr)]], .25, na.rm = TRUE)
  quantile25_var2 <- quantile(data[[quo_name(var2_expr)]], .25, na.rm = TRUE)
  quantile75_var1 <- quantile(data[[quo_name(var1_expr)]], .75, na.rm = TRUE)
  quantile75_var2 <- quantile(data[[quo_name(var2_expr)]], .75, na.rm = TRUE)
  fill_colors <- setNames(c("maroon4", "deepskyblue4"), c(var1_label, var2_label))
  
  # Create the plot
  ggplot(data) +
    # Density plot for the first variable with some transparency
    geom_density(aes(x = !!var1_expr, fill = var1_label), alpha = 0.9, adjust = 1) +
    # Density plot for the second variable with some transparency
    geom_density(aes(x = !!var2_expr, fill = var2_label), alpha = 0.5, adjust = 1) +
    
    # Vertical line for the mean of the first variable
    geom_vline(aes(xintercept = mean_var1), linetype = "dashed", color = "maroon4") +
    # Vertical line for the mean of the second variable
    geom_vline(aes(xintercept = mean_var2), linetype = "dashed", color = "deepskyblue4") +

    # Vertical line for the mean of the first variable
    geom_vline(aes(xintercept = quantile25_var1), linetype = "dashed", color = "maroon4") +
    # Vertical line for the mean of the second variable
    geom_vline(aes(xintercept = quantile25_var2), linetype = "dashed", color = "deepskyblue4") +

    # Vertical line for the mean of the first variable
    geom_vline(aes(xintercept = quantile75_var1), linetype = "dashed", color = "maroon4") +
    # Vertical line for the mean of the second variable
    geom_vline(aes(xintercept = quantile75_var2), linetype = "dashed", color = "deepskyblue4") +
    
    scale_fill_manual(values = fill_colors) +    # Add labels and title if needed
    labs(fill = "Variable", title = paste("KDE of" , var1_label) ) +
    
    # Custom legend for the vertical lines
    guides(color = guide_legend(title = "Mean")) +
    
    # Make the background theme clean
    theme_minimal()
}




