pfts <- c("Tropical", "Temperate_Broadleaf","Temperate_Deciduous","Temperate_Coniferous","Boreal")


base_comparison <- fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/base_climate_comparison_2000_2021.csv')
base_comparison <- base_comparison[, .(tmp_avg, precip_avg)]

input_data <- fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL-ESM4_ssp245_global_input_vars.csv')

annual_avg <- input_data[year >= 2021,  lapply(.SD, mean, na.rm = TRUE)
           , by = .(year), .SDcols = c("tair_avg", "prec_avg")]

annual_avg$compare_tair <- base_comparison$tmp_avg_base
annual_avg$compare_prec <- base_comparison$precip_avg_base
annual_avg[, tair_delta := tair_avg-compare_tair]
annual_avg[, prec_ratio := prec_avg/compare_prec-1]
annual_avg[, temp_degree := floor(tair_delta)]
annual_avg[, prec_change := round(100*prec_ratio)]
annual_avg
rm(hist_input_data)
control <- annual_avg[temp_degree==0 & prec_change < 5, year]
plus1 <- annual_avg[temp_degree==1, year]
plus2 <- annual_avg[temp_degree==2, year]
plus3 <- annual_avg[temp_degree==3, year]
prec8_10 <- annual_avg[prec_change%between%c(8,10), year]
prec5_7 <- annual_avg[prec_change%between%c(5,7), year]
clm_features <- c("nirr_avg", "nirr_min", "nirr_max", "prec_avg",
                  "prec_min", "prec_max", "tair_avg", "tair_min", "tair_max",
                  "trange_avg", "trange_min", "trange_max", "vpr_avg",
                  "vpr_min", "vpr_max", "wind_avg", "wind_min",
                  "wind_max" ,"s1" ,"s2" , "s3" ,  
                  "elev" ,  "co2" ,"ordinal_stand_age")
temperate_deciduous_grid <- unique(temperate_deciduous_model_data[, c("lon","lat")], by = c("lon","lat"))


standage_avgs <- rbind(
  generate_stand_age_predictions(control, GFDL_ssp245_temperate_deciduous_earth.VEGC, temperate_deciduous_grid, 'control')
  ,generate_stand_age_predictions(plus1, GFDL_ssp245_temperate_deciduous_earth.VEGC, temperate_deciduous_grid, 'plus1')
  ,generate_stand_age_predictions(plus2, GFDL_ssp245_temperate_deciduous_earth.VEGC, temperate_deciduous_grid, 'plus2')
  ,generate_stand_age_predictions(prec5_7, GFDL_ssp245_temperate_deciduous_earth.VEGC, temperate_deciduous_grid, 'prec5_7')
  ,generate_stand_age_predictions(prec8_10, GFDL_ssp245_temperate_deciduous_earth.VEGC, temperate_deciduous_grid, 'prec8_10')
)
standage_avgs

ggplot(standage_avgs, aes(x = ordinal_stand_age, y = mean_VEGC_pred, color = label, group = label)) +
  geom_line() +
  labs(title = "Temperate Deciduous Forest Average Response to Annual Climate Change",
       x = "Ordinal Stand Age",
       y = "Average Vegetation Carbon (gC/m2) by Stand Age",
       color = "Group") +
  theme_minimal()

load("/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL_ssp245_tropical_earth.VEGC.rda")

tropical_grid <- unique(tropical_model_data[, c("lon","lat")], by = c("lon","lat"))
rm(tropical_model_data)
standage_avgs <- rbind(
  generate_stand_age_predictions(control, GFDL_ssp245_tropical_earth.VEGC, tropical_grid, 'control')
  ,generate_stand_age_predictions(plus1, GFDL_ssp245_tropical_earth.VEGC, tropical_grid, 'plus1')
  ,generate_stand_age_predictions(plus2, GFDL_ssp245_tropical_earth.VEGC, tropical_grid, 'plus2')
  ,generate_stand_age_predictions(prec5_7, GFDL_ssp245_tropical_earth.VEGC, tropical_grid, 'prec5_7')
  ,generate_stand_age_predictions(prec8_10, GFDL_ssp245_tropical_earth.VEGC, tropical_grid, 'prec8_10')
)
standage_avgs

ggplot(standage_avgs, aes(x = ordinal_stand_age, y = mean_VEGC_pred, color = label, group = label)) +
  geom_line() +
  labs(title = "Tropical Forest Average Response to Climate Change",
       x = "Ordinal Stand Age",
       y = "Average Vegetation Carbon (gC/m2) by Stand Age",
       color = "Group") +
  theme_minimal()



boreal_grid <- unique(boreal_grid[, c("lon","lat")], by = c("lon","lat"))
rm(boreal_model_data)

standage_avgs <- rbind(
  generate_stand_age_predictions(control, GFDL_ssp245_tropical_earth.VEGC, boreal_grid, 'control')
  ,generate_stand_age_predictions(plus1, GFDL_ssp245_tropical_earth.VEGC, boreal_grid, 'plus1')
  ,generate_stand_age_predictions(plus2, GFDL_ssp245_tropical_earth.VEGC, boreal_grid, 'plus2')
  ,generate_stand_age_predictions(prec5_7, GFDL_ssp245_tropical_earth.VEGC, boreal_grid, 'prec5_7')
  ,generate_stand_age_predictions(prec8_10, GFDL_ssp245_tropical_earth.VEGC, boreal_grid, 'prec8_10')
)
standage_avgs

ggplot(standage_avgs, aes(x = ordinal_stand_age, y = mean_VEGC_pred, color = label, group = label)) +
  geom_line() +
  labs(title = "Tropical Forest Average Response to Climate Change",
       x = "Ordinal Stand Age",
       y = "Average Vegetation Carbon (gC/m2) by Stand Age",
       color = "Group") +
  theme_minimal()



# stand_ages <- data.table(ordinal_stand_age=0:22)
# stand_ages[, dummy_key := 1]
# 
# control_input <-input_data[year %in%control]
# control_input <- control_input[temperate_deciduous_grid, on = .(lon,lat)]
# 
# control_input[, dummy_key := 1]
# control_input <- control_input[stand_ages, on = "dummy_key", allow.cartesian = TRUE][, dummy_key := NULL]
# 
# 
# control_input$VEGC_pred <- predict(GFDL_ssp245_temperate_deciduous_earth.VEGC, control_input[,..clm_features])
# control_input$VEGC_pred[control_input$VEGC_pred<0] <- 0
# 
# control_sa <- control_input[, mean(VEGC_pred), by = .(ordinal_stand_age)]
# control_sa[,'label':= 'control']


