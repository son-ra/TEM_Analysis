#!/usr/bin/env python
# coding: utf-8



import xarray as xr
import cftime 
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import re
import os
import time
import logging
import cartopy.crs as ccrs
import metpy  
import calendar
import argparse
import glob

parser = argparse.ArgumentParser()
parser.add_argument("i", help = '')
args = parser.parse_args()

#assign args to text values
i = int(args.i)
print(i)


run = 'historical_run/'
dir_path = '/home/smmrrr/TEM/TEM_Runs/TEM_parallel_run_support_code/'+run

output_col_names = ['lon'
,'lat'
,'variable'
,'cohort_number'
,'stand_age'
,'potential_veg'
,'current_veg'
,'community_type'
,'subtype'
,'silt_clay'  ###check this order
,'lc_state'
,'land_area'
,'cohort_area'
,'year'
,'annual_sum'
,'monthly_maximum'
,'monthly_mean'
,'monthly_minimum'
,'Jan'
,'Feb'
,'Mar'
,'Apr'
,'May'
,'Jun'
,'Jul'
,'Aug'
,'Sep'
,'Oct'
,'Nov'
,'Dec'
,'region']

input_col_names = ["lon", 'lat','var' ,'Area', 'year', 'sum', 'max', 'average'
         , 'min', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'
         , 'Nov', 'Dec', 'Area_Name']




read_in_data = pd.read_csv(dir_path+'VEGC_ORGC_info.csv')




###read in cohort output
cohort_output = pd.read_csv(dir_path + read_in_data.loc[i, 'output_paths']
            , names = output_col_names)

print('cohort rows read in : '+ str(len(cohort_output)))





forest_subtypes_num = [4, 5, 6, 10, 12]
forest_subtypes_names = ["Boreal", "Temperate Coniferous", "Temperate Deciduous", "Tropical", "Temperate Broadleaved Evergreen Forests"]

forest_subtypes = pd.DataFrame({
'subtype':forest_subtypes_num, 
    'forest_type':forest_subtypes_names
})




cohort_output=cohort_output.loc[(cohort_output['subtype'].isin(forest_subtypes['subtype']))& (cohort_output['year']>=1800)]

# cohort_output.loc[(cohort_output['subtype'].isin(forest_subtypes['subtype']))]
# len(cohort_output)




#### match pfts to the current veg, bin by standage for forests
cohort_output=cohort_output.merge(forest_subtypes, on = 'subtype', how = 'left')

intervals_standage = [-1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 3000]
cohort_output['stand_age_bin'] = pd.cut(
    cohort_output['stand_age'], bins=intervals_standage)
cohort_output['stand_age_interval_min'] = cohort_output['stand_age_bin'].apply(lambda x: x.left).astype(int) + 1




cohort_output['temp_weight'] = cohort_output['monthly_mean'] * cohort_output['cohort_area'] 



cohort_output = cohort_output.groupby(
    ['lon','lat','variable','forest_type','subtype','year','silt_clay','stand_age_interval_min']
)[[ 'cohort_area','land_area','temp_weight' ]].sum()


cohort_output['value_weight'] = cohort_output['temp_weight']/cohort_output['cohort_area']
cohort_output = cohort_output.reset_index()
print('cohort rows post cohort collapse : '+ str(len(cohort_output)))
# cohort_output




cohort_output=cohort_output.drop(['temp_weight'], axis=1)




# lon_lat_pfts

cohort_output.to_csv('/home/smmrrr/TEM_output_processed/historical_run_model_data/'+read_in_data.loc[i, 'output_var']+str(read_in_data.loc[i, 'output_group'])+'.csv'
                        ,index = False)




