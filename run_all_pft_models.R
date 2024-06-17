X <- tropical_model_data[, ..present_features] 
Y <- tropical_model_data[, .(VEGC,SOILORGC,NPP)] 
trainIndex <- createDataPartition(Y$VEGC, p = 0.7, list = FALSE)

X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]
y_train <- Y[trainIndex,]
y_test <- Y[-trainIndex,]
tropical_earth.VEGC <- earth(y=y_train$VEGC, x=X_train, degree=2)



X <- temperate_broadleaf_model_data[, ..present_features] 
Y <- temperate_broadleaf_model_data[, .(VEGC,SOILORGC,NPP)] 
trainIndex <- createDataPartition(Y$VEGC, p = 0.7, list = FALSE)

X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]
y_train <- Y[trainIndex,]
y_test <- Y[-trainIndex,]
temperate_broadleaf_earth.VEGC <- earth(y=y_train$VEGC, x=X_train, degree=2)



X <- temperate_deciduous_model_data[, ..present_features] 
Y <- temperate_deciduous_model_data[, .(VEGC,SOILORGC,NPP)] 
trainIndex <- createDataPartition(Y$VEGC, p = 0.7, list = FALSE)

X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]
y_train <- Y[trainIndex,]
y_test <- Y[-trainIndex,]
temperate_deciduous_earth.VEGC <- earth(y=y_train$VEGC, x=X_train, degree=2)



X <- temperate_coniferous_model_data[, ..present_features] 
Y <- temperate_coniferous_model_data[, .(VEGC,SOILORGC,NPP)] 
trainIndex <- createDataPartition(Y$VEGC, p = 0.7, list = FALSE)

X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]
y_train <- Y[trainIndex,]
y_test <- Y[-trainIndex,]
temperate_coniferous_earth.VEGC <- earth(y=y_train$VEGC, x=X_train, degree=2)



X <- boreal_model_data[, ..present_features] 
Y <- boreal_model_data[, .(VEGC,SOILORGC,NPP)] 
trainIndex <- createDataPartition(Y$VEGC, p = 0.7, list = FALSE)

X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]
y_train <- Y[trainIndex,]
y_test <- Y[-trainIndex,]
boreal_earth.VEGC <- earth(y=y_train$VEGC, x=X_train, degree=2)


save(tropical_earth.VEGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/tropical_earth.VEGC.rda")
save(temperate_broadleaf_earth.VEGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/temperate_broadleaf_earth.VEGC.rda")
save(temperate_deciduous_earth.VEGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/temperate_deciduous_earth.VEGC.rda")
save(temperate_coniferous_earth.VEGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/temperate_coniferous_earth.VEGC.rda")
save(boreal_earth.VEGC,file = "/home/smmrrr/TEM_Analysis/TEM_Analysis/boreal_earth.VEGC.rda")
plotmo(boreal_earth.VEGC)

