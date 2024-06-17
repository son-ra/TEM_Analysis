pfts <- c("Tropical", "Temperate_Broadleaf","Temperate_Deciduous","Temperate_Coniferous","Boreal")
tropical_model_data <- rbindlist(list(
  fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[1],'_trainingset_r_1_9.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[1],'_trainingset_r_10_19.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[1],'_trainingset_r_20_29.csv'))
))

temperate_deciduous_model_data <- rbindlist(list(
  fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[3],'_trainingset_r_1_9.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[3],'_trainingset_r_10_19.csv'))
  , fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/',pfts[3],'_trainingset_r_20_29.csv'))
))

load("/home/smmrrr/TEM_Analysis/TEM_Analysis/tropical_earth.VEGC.rda")
load("/home/smmrrr/TEM_Analysis/TEM_Analysis/temperate_broadleaf_earth.VEGC.rda")
load("/home/smmrrr/TEM_Analysis/TEM_Analysis/temperate_deciduous_earth.VEGC.rda")
load("/home/smmrrr/TEM_Analysis/TEM_Analysis/temperate_coniferous_earth.VEGC.rda")
load("/home/smmrrr/TEM_Analysis/TEM_Analysis/boreal_earth.VEGC.rda")

summary(tropical_earth.VEGC)
summary(temperate_broadleaf_earth.VEGC)
summary(temperate_deciduous_earth.VEGC)
summary(temperate_coniferous_earth.VEGC)
summary(boreal_earth.VEGC)



plot(evimp(tropical_earth.VEGC), main = 'Tropical Variable Importance')
plot(evimp(temperate_broadleaf_earth.VEGC), main = 'Broadleaf Variable Importance')
plot(evimp(temperate_deciduous_earth.VEGC), main = 'Deciduous Variable Importance')
plot(evimp(temperate_coniferous_earth.VEGC), main = 'Coniferous Variable Importance')
plot(evimp(boreal_earth.VEGC), main = 'Boreal Variable Importance')





