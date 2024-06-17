library(corrplot)

load("/home/smmrrr/TEM_Analysis/TEM_Analysis/boreal_earth.VEGC.rda")
cor_features <- c("nirr_avg", "nirr_min", "nirr_max", "prec_avg",
                      "prec_min", "prec_max", "tair_avg", "tair_min", "tair_max",
                      "trange_avg", "trange_min", "trange_max", "vpr_avg",
                      "vpr_min", "vpr_max", "wind_avg", "wind_min",
                      "wind_max" ,"s1" ,"s2" , "s3" ,  
                      "elev" ,  "co2" , "AOT40_rcp45_avg" ,"AOT40_rcp45_min",
                      "AOT40_rcp45_max", "Ndep_rcp45"     ,
                      "Nfer_crop"    ,   "Nfer_pas" ,
                      "ordinal_stand_age","VEGC", "SOILORGC","NPP", "VSM","AVAILN")

tt <- cor(boreal_model_data[AVAILN<1200,..cor_features])
corrplot(tt, method = "color", type = "upper", order = "hclust",
         tl.col = "black", tl.srt = 45, # Text label color and rotation
         addCoef.col = "black"
         ,number.digits = 1
         ,number.cex = .7) # Add correlation coefficients to the plot

vegc_cors <- tt[rownames(tt)=="VEGC"]
rownames(tt)[which(abs(vegc_cors)>.1)]
cor_features <- c( "nirr_max", "prec_avg", "prec_min", "prec_max", "tair_max",          
  "vpr_max","s3", "elev", "AOT40_rcp45_avg", "AOT40_rcp45_max", "ordinal_stand_age" ,"co2"
 #  "VEGC", "SOILORGC"          
 # "NPP", "VSM", "AVAILN"
 )
present_features <- c("nirr_avg", "nirr_min", "nirr_max", 
                      "tair_avg", "tair_min", "tair_max",
                      "prec_avg","prec_min", "prec_max", 
                      "trange_avg", "trange_min", "trange_max", 
                      "vpr_avg", "vpr_min", "vpr_max", 
                      "wind_avg", "wind_min", "wind_max" ,
                      "Ndep_rcp45","Nfer_crop",   "Nfer_pas" ,
                      "s1" ,"s2" , "s3" , "elev" ,  
                      "co2" , "ordinal_stand_age")

present_features_hist <- c("tswrf_v11_avg" ,"tswrf_v11_min" , "tswrf_v11_max" ,
                      "tmp_avg" ,"tmp_min" , "tmp_max" ,
                      "precip_avg" , "precip_min" , "precip_max" ,
                      "dtr_avg" , "dtr_min" , "dtr_max" ,
                      "vpr_avg" , "vpr_min" , "vpr_max" ,
                      "wind_avg" ,"wind_min" ,"wind_max" ,  
                      "Ndep_Trendy" ,"Nfer_crop" ,  "Nfer_pas" ,  
                      "s1" ,"s2" , "s3" ,  
                      "elev" ,  "co2" ,"ordinal_stand_age" )


# X <- boreal_model_data[, ..cor_features] 
X <- boreal_model_data[, ..clm_features]
Y <- boreal_model_data[, .(stand_age_interval_min, VEGC,SOILORGC,NPP)] 
trainIndex <- createDataPartition(Y$VEGC, p = 0.5, list = FALSE)

X_train <- X[trainIndex, ]
y_train <- Y[trainIndex,]


GFDL_ssp245_boreal_earth.VEGC_prune <- earth(y=y_train$VEGC, x=X_train, degree=2,newvar.penalty=.2)

Y$vegc_pred <- predict(GFDL_ssp245_boreal_earth.VEGC, X)
Y$vegc_res <- Y$VEGC - Y$vegc_pred

paste("VEGC RMSE : ", sqrt(mean((Y$vegc_res)^2)))
paste("VEGC R2 : ", 1 - (sum((Y$vegc_res)^2))/ (sum((Y$VEGC - mean(Y$VEGC))^2)) )
nrow(Y[vegc_pred<0])/nrow(Y)
Y[vegc_pred<0, vegc_pred:=0]

plot_kde_with_means(Y, VEGC, vegc_pred, "VEGC", "Emulated VEGC")

plot_stand_age_range(Y)
