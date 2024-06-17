
hist_input_data <- fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/global_input_vars.csv')
variables_to_compare <- c(
  # ,'LAI', 'VSM', 'NETNMIN', 'AVAILN'
  "tswrf_v11_avg" ,"tswrf_v11_min" , "tswrf_v11_max" ,
  "tmp_avg" ,"tmp_min" , "tmp_max" ,
  "precip_avg" , "precip_min" , "precip_max" ,
  "dtr_avg" , "dtr_min" , "dtr_max" ,
  "vpr_avg" , "vpr_min" , "vpr_max" ,
  "wind_avg" ,"wind_min" ,"wind_max" ,  
  "Ndep_Trendy" ,"Nfer_crop" ,  "Nfer_pas" , "co2")


start_yr <- 2000 
end_yr <- 2021
# Create base comparison data table by filtering and summarizing
base_comparison <- hist_input_data[year >= start_yr & year <= end_yr,
                                   lapply(.SD, mean, na.rm = TRUE), 
                                   .SDcols = variables_to_compare]


setnames(base_comparison, old = colnames(base_comparison), new = paste0(colnames(base_comparison), "_base"))
fwrite(base_comparison, '/home/smmrrr/TEM_Analysis/TEM_Analysis/base_climate_comparison_2000_2021.csv')
rm(hist_input_data)

tropical_model_data <- fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/','GFDL-ESM4_ssp245_',pfts[1],'_trainingset_r_1_29.csv'))
input_data <- fread('/home/smmrrr/TEM_Analysis/TEM_Analysis/GFDL-ESM4_ssp245_global_input_vars.csv')
tropical_model_data <- tropical_model_data[year >=2020]

tropical_model_data <- input_data[tropical_model_data, on = c('lon','lat','year')]
tropical_model_data <- tropical_model_data[ SOILORGC<15000& VEGC < 30000 ]
plot_clm_var_cor(na.omit(tropical_model_data))

tropical_grid <- unique(tropical_model_data[, c("lon","lat")], by = c("lon","lat"))
fwrite(tropical_grid, '/home/smmrrr/TEM_Analysis/TEM_Analysis/tropical_grid.csv')

plot_clm_var_cor(temperate_coniferous_model_data)

temperate_coniferous_grid <- unique(temperate_coniferous_model_data[, c("lon","lat")], by = c("lon","lat"))
fwrite(temperate_coniferous_grid, '/home/smmrrr/TEM_Analysis/TEM_Analysis/temperate_coniferous_grid.csv')

rm(GFDL_ssp245_temperate_coniferous_earth.VEGC, hist_input_data, temperate_coniferous_grid, temperate_coniferous_model_data)


rm(tropical_model_data)



temperate_deciduous_model_data <- fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/','GFDL-ESM4_ssp245_',pfts[3],'_trainingset_r_1_29.csv'))
temperate_deciduous_model_data <- temperate_deciduous_model_data[year >=2020]

temperate_deciduous_model_data <- input_data[temperate_deciduous_model_data, on = c('lon','lat','year')]
temperate_deciduous_model_data <- temperate_deciduous_model_data[ SOILORGC<15000& VEGC < 25000 ]
plot_clm_var_cor(na.omit(temperate_deciduous_model_data))

temperate_deciduous_grid <- unique(temperate_deciduous_model_data[, c("lon","lat")], by = c("lon","lat"))
fwrite(temperate_deciduous_grid, '/home/smmrrr/TEM_Analysis/TEM_Analysis/temperate_deciduous_grid.csv')

####### boreal

boreal_model_data <- fread(paste0('/home/smmrrr/TEM_Analysis/TEM_Analysis/','GFDL-ESM4_ssp245_',pfts[5],'_trainingset_r_1_29.csv'))
boreal_model_data <- boreal_model_data[year >=2020]

boreal_model_data <- input_data[boreal_model_data, on = c('lon','lat','year')]
boreal_model_data <- boreal_model_data[ SOILORGC<17000& VEGC < 17000 ]
plot_clm_var_cor(na.omit(boreal_model_data))

boreal_grid <- unique(boreal_model_data[, c("lon","lat")], by = c("lon","lat"))
fwrite(boreal_grid, '/home/smmrrr/TEM_Analysis/TEM_Analysis/boreal_grid.csv')


