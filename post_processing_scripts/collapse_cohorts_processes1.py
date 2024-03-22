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
lon_lat_sum = '/home/smmrrr/TEM_output_processed/historical_run/lon_lat_counts/'
lon_lat_pfts = '/home/smmrrr/TEM_output_processed/historical_run/forest_lon_lat_pfts/'
run = 'historical_run/'
os.chdir('/home/smmrrr/TEM/TEM_Runs/TEM_parallel_run_support_code/'+run)

print(os.getcwd()) 




output_col_names = ['lon'
,'lat'
,'variable'
,'cohort_number'
,'stand_age'
,'potential_veg'
,'current_veg'
,'subtype'
,'community_type'
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




read_in_data = pd.read_csv('/home/smmrrr/TEM/TEM_Runs/TEM_parallel_run_support_code/'+run+'all_parallel_variable_info.csv')




print(read_in_data.loc[i])




##read in precipitation files
prec = pd.read_csv(read_in_data.loc[i, 'PREC']
           , names = input_col_names)
par = pd.read_csv(read_in_data.loc[i, 'PAR']
           , names = input_col_names)
nirr = pd.read_csv(read_in_data.loc[i, 'NIRR']
           , names = input_col_names)
tair = pd.read_csv(read_in_data.loc[i, 'TAIR']
           , names = input_col_names)
vpr = pd.read_csv(read_in_data.loc[i, 'VPR']
           , names = input_col_names)
ws10 = pd.read_csv(read_in_data.loc[i, 'WS10']
           , names = input_col_names)


print('data read in')
## shape input datasets wide to long
prec = pd.melt(prec, id_vars = ['lon','lat', 'Area', 'year'], value_vars = [
'Jan',
'Feb',
'Mar',
'Apr',
'May',
'Jun',
'Jul',
'Aug',
'Sep',
'Oct',
'Nov',
'Dec'], 
         var_name='month', value_name='prec'
        ,col_level=0)

par = pd.melt(par, id_vars = ['lon','lat', 'Area', 'year'], value_vars = [
'Jan',
'Feb',
'Mar',
'Apr',
'May',
'Jun',
'Jul',
'Aug',
'Sep',
'Oct',
'Nov',
'Dec'], 
         var_name='month', value_name='par'
        ,col_level=0)

nirr = pd.melt(nirr, id_vars = ['lon','lat', 'Area', 'year'], value_vars = [
'Jan',
'Feb',
'Mar',
'Apr',
'May',
'Jun',
'Jul',
'Aug',
'Sep',
'Oct',
'Nov',
'Dec'], 
         var_name='month', value_name='nirr'
        ,col_level=0)

tair = pd.melt(tair, id_vars = ['lon','lat', 'Area', 'year'], value_vars = [
'Jan',
'Feb',
'Mar',
'Apr',
'May',
'Jun',
'Jul',
'Aug',
'Sep',
'Oct',
'Nov',
'Dec'], 
         var_name='month', value_name='tair'
        ,col_level=0)

vpr = pd.melt(vpr, id_vars = ['lon','lat', 'Area', 'year'], value_vars = [
'Jan',
'Feb',
'Mar',
'Apr',
'May',
'Jun',
'Jul',
'Aug',
'Sep',
'Oct',
'Nov',
'Dec'], 
         var_name='month', value_name='vpr'
        ,col_level=0)

ws10 = pd.melt(ws10, id_vars = ['lon','lat', 'Area', 'year'], value_vars = [
'Jan',
'Feb',
'Mar',
'Apr',
'May',
'Jun',
'Jul',
'Aug',
'Sep',
'Oct',
'Nov',
'Dec'], 
         var_name='month', value_name='ws10'
        ,col_level=0)

##merge climate variables together
climate_vars = prec.merge(
            par,on = ['lon','lat', 'Area', 'year', 'month']
            ).merge(
            tair ,on = ['lon','lat', 'Area', 'year', 'month']                           
            ).merge(
            nirr ,on = ['lon','lat', 'Area', 'year', 'month']                           
            ).merge(
            vpr ,on = ['lon','lat', 'Area', 'year', 'month']                           
            ).merge(
            ws10 ,on = ['lon','lat', 'Area', 'year', 'month']                           
            )





del prec, par, tair, nirr, vpr, ws10
##subset to forest veg types 
# cohort_output = cohort_output.loc[cohort_output['current_veg'].isin(forest_vegs)] 
print('clim processed')

print('climate rows : '+ str(len(climate_vars)))





###read in cohort output
cohort_output = pd.read_csv(read_in_data.loc[i, 'output_paths']
            , names = output_col_names)



print('cohort rows read in : '+ str(len(cohort_output)))

# cohort_output




###summary table of lat, lon, num years, num cohorts, 
summary_lon_lat = cohort_output.groupby(['lon', 'lat'])[['year', 'cohort_number']].nunique()
summary_lon_lat.to_csv(lon_lat_sum+read_in_data.loc[i, 'output_var']+str(read_in_data.loc[i, 'output_group'])+'.csv'
                        ,index = False)




##melt cohort output
cohort_output = pd.melt(cohort_output, id_vars = ['lon','lat', 'cohort_area', 'land_area', 'year','variable', 'current_veg', 'stand_age'], value_vars = [
'Jan',
'Feb',
'Mar',
'Apr',
'May',
'Jun',
'Jul',
'Aug',
'Sep',
'Oct',
'Nov',
'Dec'], 
         var_name='month', value_name='value'
        ,col_level=0)

print('cohort rows wide to long : '+ str(len(cohort_output)))



# cohort_output




#### match pfts to the current veg, bin by standage for forests
conditions = [
 cohort_output['current_veg'].isin([50, 49, 52, 53, 54, 55, 56]) 
    ,cohort_output['current_veg'].isin([51, 47])
, cohort_output['current_veg'].isin([48, 46]) 
    ,cohort_output['current_veg'].isin([4, 5, 6, 8, 9, 
                                        10, 11, 16, 17, 18, 19, 20, 25, 33])
    ,cohort_output['current_veg'].isin([7, 12, 13, 14, 22, 23, 24, 25, 26, 27, 28, 30, 31])
    ,cohort_output['current_veg'].isin([15, 35, 29])
    ,cohort_output['current_veg'].isin([2, 3])
    ,cohort_output['current_veg'].isin([21])
]

values = [
          'crop', 
          'pasture', 
          'urban or suburban', 
          'forest', 
          'grass', 
          'shrub', 
          'tundra',
            'desert']
cohort_output['pft'] = np.select(conditions, values, default = 'other')

intervals_standage = [-1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 3000]
cohort_output['stand_age_bin'] = pd.cut(
    cohort_output['stand_age'], bins=intervals_standage)
# print(annual_current_veg[['pft', 'stand_age_bin']].value_counts())
cohort_output.loc[cohort_output['pft']!='forest', ['stand_age_bin']] =  cohort_output['stand_age_bin'].min()
cohort_output['stand_age_interval_min'] = cohort_output['stand_age_bin'].apply(lambda x: x.right).astype(int)




cohort_output['temp_weight'] = cohort_output['value'] * cohort_output['cohort_area'] 


aggregations = {
 'cohort_area':'sum',
 'land_area':'sum',
 'value':'mean',
    'temp_weight':'sum'
}


cohort_output = cohort_output.groupby(
    ['lon','lat','variable','pft','current_veg','year','month' ,'stand_age_interval_min']
).agg(
aggregations
)


# all_grids =  all_grids.reset_index()

cohort_output['value_weight'] = cohort_output['temp_weight']/cohort_output['cohort_area']
cohort_output = cohort_output.reset_index()
# cohort_output
print('cohort rows post cohort collapse : '+ str(len(cohort_output)))




forest_vegs = [4, 5, 6, 8, 9, 10, 11, 16, 17, 18, 19, 20, 25, 33]
forest_types = ["Boreal Forest", "Forested Boreal Wetlands", "Boreal Woodlands","Mixed Temperate Forests", 
               "Temperate Coniferous Forests", "Temperate Deciduous Forests", "Temperate Forested Wetlands", 
               "Tropical Evergreen Forests", "Tropical Forested Wetlands", "Tropical Deciduous Forests", "Xeromorphic Forests and Woodlands"
               ,"Tropical Forested Floodplains", "Temperate Forested Floodplains", "Temperate Broadleaved Evergreen Forests"]

forest_pfts = pd.DataFrame({
'current_veg':forest_vegs, 
    'forest_type':forest_types
})

cohort_output=cohort_output.merge(forest_pfts, on = 'current_veg', how = 'left')

merged_dataset = cohort_output.merge(
            climate_vars, how = 'left'
    ,on = ['lon','lat', 'year', 'month']
            )




# lon_lat_pfts

merged_dataset.to_csv(lon_lat_pfts+read_in_data.loc[i, 'output_var']+str(read_in_data.loc[i, 'output_group'])+'.csv'
                        ,index = False)


merged_dataset.loc[merged_dataset['pft']=='forest'].to_csv(lon_lat_pfts+'forests_'+read_in_data.loc[i, 'output_var']+str(read_in_data.loc[i, 'output_group'])+'.csv'
                        ,index = False)


