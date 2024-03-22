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



forest_vegs = [4, 5, 6, 8, 9, 10, 11, 16, 17, 18, 19, 20, 25, 33]
forest_types = ["Boreal Forest", "Forested Boreal Wetlands", "Boreal Woodlands","Mixed Temperate Forests", 
               "Temperate Coniferous Forests", "Temperate Deciduous Forests", "Temperate Forested Wetlands", 
               "Tropical Evergreen Forests", "Tropical Forested Wetlands", "Tropical Deciduous Forests", "Xeromorphic Forests and Woodlands"
               ,"Tropical Forested Floodplains", "Temperate Forested Floodplains", "Temperate Broadleaved Evergreen Forests"]

forest_pfts = pd.DataFrame({
'current_veg':forest_vegs, 
    'forest_type':forest_types
})

parser = argparse.ArgumentParser()
parser.add_argument("region", help = '')
parser.add_argument("var", help = '')
args = parser.parse_args()

#assign args to text values
region = args.region
print(region)
var = args.var
print(var)


# region = 'region_1/'
# var = 'GPP'


ensemble_dir = '/group/moniergrp/TEM_Large_Ensemble/run_support_files/large_ensemble/'

output_dir_path = '/group/moniergrp/TEM_Large_Ensemble/output_files/' 

intervals_standage = np.concatenate((np.arange(-1, 100, 5),np.array([124, 149, 3000])))



path_summary_future = pd.read_csv(output_dir_path+region+'future_path_summary.csv')
path_summary_historical = pd.read_csv(output_dir_path+region+'historical_path_summary.csv')
path_summary_pre_data = pd.read_csv(output_dir_path+region+'pre_data_path_summary.csv')

#####run future
loop_set = path_summary_future.loc[path_summary_future['variable']==var].reset_index()

### columns to keep for analysis
keep_cols = ['model','scenario','grid_group','lon', 'lat', 'variable', 'forest_type', 'current_veg', 'year',
       'silt_clay', 'stand_age_interval_min', 'cohort_area', 'land_area',
        'monthly_mean', 'cohort_annual_change_delta', 'cohort_annual_change_percent']
### dataset for all region 1
all_future = pd.DataFrame(columns=keep_cols)

for i in range(len(loop_set)):
    ###read in cohort slice
    cohort_output = pd.read_csv(ensemble_dir + region + loop_set.loc[i, 'path']
                , names = output_col_names)

    # print('cohort rows read in : '+ str(len(cohort_output)))


    # #### match pfts to the current veg, bin by standage for forests
    cohort_output=cohort_output.merge(forest_pfts, on = 'current_veg', how = 'inner')
    # print('cohort rows forest only : '+ str(len(cohort_output)))

    cohort_output['stand_age_bin'] = pd.cut(
        cohort_output['stand_age'], bins=intervals_standage)
    cohort_output['stand_age_interval_min'] = cohort_output['stand_age_bin'].apply(lambda x: x.left).astype(int) + 1

    cohort_output['monthly_mean'] = cohort_output['monthly_mean'].astype(float)
    # cohort_output['issue'] = 1*cohort_output['monthly_mean'] > 100000
    ### get cohort level change
    cohort_output['cohort_annual_prior_value'] = cohort_output.groupby(['lon', 'lat', 'cohort_number', 'current_veg'])['monthly_mean'].shift()
    cohort_output['cohort_annual_change_delta'] = cohort_output['monthly_mean'] - cohort_output['cohort_annual_prior_value']
    cohort_output['cohort_annual_change_percent'] = cohort_output['cohort_annual_change_delta'] / cohort_output['cohort_annual_prior_value']

    ### calculate temp weights for average calc
    cohort_output['temp_weight_monthly_mean'] = cohort_output['monthly_mean'] * cohort_output['cohort_area'] 
    cohort_output['temp_weight_cohort_annual_change_delta'] = cohort_output['cohort_annual_change_delta'] * cohort_output['cohort_area'] 
    cohort_output['temp_weight_cohort_annual_change_percent'] = cohort_output['cohort_annual_change_percent'] * cohort_output['cohort_area'] 
    # cohort_output[['monthly_mean', 'cohort_annual_change_delta', 'cohort_annual_change_percent']].describe()

    ### summarize by stand age bin
    cohort_output = cohort_output.groupby(
        ['lon','lat','variable','forest_type','current_veg','year','silt_clay','stand_age_interval_min']
    )[[ 'cohort_area','land_area','temp_weight_monthly_mean','temp_weight_cohort_annual_change_delta' , 'temp_weight_cohort_annual_change_percent']].sum()

    # print('cohort rows post binning : '+ str(len(cohort_output)))
    cohort_output=cohort_output.reset_index()
    ### finish weighted average calculation
    cohort_output['monthly_mean'] = (cohort_output['temp_weight_monthly_mean']/cohort_output['cohort_area']).round(5)
    cohort_output['cohort_annual_change_delta'] = (cohort_output['temp_weight_cohort_annual_change_delta']/cohort_output['cohort_area']).round(5)
    cohort_output['cohort_annual_change_percent'] = (cohort_output['temp_weight_cohort_annual_change_percent']/cohort_output['cohort_area']).round(5)
    cohort_output = cohort_output.loc[:, ~cohort_output.columns.str.contains('temp_weight')]
    ### get relevant info for group, model, scenario
    cohort_output['model'] = loop_set.loc[i,'model']
    cohort_output['scenario'] = loop_set.loc[i,'scenario']
    cohort_output['grid_group'] = loop_set.loc[i,'grid_group']

    all_future = pd.concat([all_future, cohort_output])
    print(f'all future {i} : '+ str(len(all_future)))


all_future.to_csv(output_dir_path+region+var+'_future.csv'
                        ,index = False)



del all_future


loop_set = path_summary_historical.loc[path_summary_historical['variable']==var].reset_index()
### columns to keep for analysis
keep_cols = ['model','grid_group','lon', 'lat', 'variable', 'forest_type', 'current_veg', 'year',
       'silt_clay', 'stand_age_interval_min', 'cohort_area', 'land_area',
        'monthly_mean', 'cohort_annual_change_delta', 'cohort_annual_change_percent']
### dataset for all region 1
all_historical = pd.DataFrame(columns=keep_cols)

for i in range(len(loop_set)):
    ###read in cohort slice
    cohort_output = pd.read_csv(ensemble_dir + region + loop_set.loc[i, 'path']
                , names = output_col_names)

    # print('cohort rows read in : '+ str(len(cohort_output)))


    # #### match pfts to the current veg, bin by standage for forests
    cohort_output=cohort_output.merge(forest_pfts, on = 'current_veg', how = 'inner')
    # print('cohort rows forest only : '+ str(len(cohort_output)))

    cohort_output['stand_age_bin'] = pd.cut(
        cohort_output['stand_age'], bins=intervals_standage)
    cohort_output['stand_age_interval_min'] = cohort_output['stand_age_bin'].apply(lambda x: x.left).astype(int) + 1
    ###flag potential problems
    cohort_output['monthly_mean'] = cohort_output['monthly_mean'].astype(float)
    # cohort_output['issue'] = 1*cohort_output['monthly_mean'] > 100000
    ### get cohort level change
    cohort_output['cohort_annual_prior_value'] = cohort_output.groupby(['lon', 'lat', 'cohort_number', 'current_veg'])['monthly_mean'].shift()
    cohort_output['cohort_annual_change_delta'] = cohort_output['monthly_mean'] - cohort_output['cohort_annual_prior_value']
    cohort_output['cohort_annual_change_percent'] = cohort_output['cohort_annual_change_delta'] / cohort_output['cohort_annual_prior_value']

    ### calculate temp weights for average calc
    cohort_output['temp_weight_monthly_mean'] = cohort_output['monthly_mean'] * cohort_output['cohort_area'] 
    cohort_output['temp_weight_cohort_annual_change_delta'] = cohort_output['cohort_annual_change_delta'] * cohort_output['cohort_area'] 
    cohort_output['temp_weight_cohort_annual_change_percent'] = cohort_output['cohort_annual_change_percent'] * cohort_output['cohort_area'] 
    # cohort_output[['monthly_mean', 'cohort_annual_change_delta', 'cohort_annual_change_percent']].describe()

    ### summarize by stand age bin
    cohort_output = cohort_output.groupby(
        ['lon','lat','variable','forest_type','current_veg','year','silt_clay','stand_age_interval_min']
    )[[ 'cohort_area','land_area','temp_weight_monthly_mean','temp_weight_cohort_annual_change_delta' , 'temp_weight_cohort_annual_change_percent']].sum()

    # print('cohort rows post binning : '+ str(len(cohort_output)))
    cohort_output=cohort_output.reset_index()
    ### finish weighted average calculation
    cohort_output['monthly_mean'] = (cohort_output['temp_weight_monthly_mean']/cohort_output['cohort_area']).round(5)
    cohort_output['cohort_annual_change_delta'] = (cohort_output['temp_weight_cohort_annual_change_delta']/cohort_output['cohort_area']).round(5)
    cohort_output['cohort_annual_change_percent'] = (cohort_output['temp_weight_cohort_annual_change_percent']/cohort_output['cohort_area']).round(5)
    cohort_output = cohort_output.loc[:, ~cohort_output.columns.str.contains('temp_weight')]
    ### get relevant info for group, model, scenario
    cohort_output['model'] = loop_set.loc[i,'model']
    cohort_output['grid_group'] = loop_set.loc[i,'grid_group']

    all_historical = pd.concat([all_historical, cohort_output])
    print(f'all historical {i} : '+ str(len(all_historical)))


all_historical.to_csv(output_dir_path+region+var+'_historical.csv'
                        ,index = False)


del all_historical


### run pre data
loop_set = path_summary_pre_data.loc[path_summary_pre_data['variable']==var].reset_index()
### columns to keep for analysis
keep_cols = ['model','grid_group','lon', 'lat', 'variable', 'forest_type', 'current_veg', 'year',
       'silt_clay', 'stand_age_interval_min', 'cohort_area', 'land_area',
        'monthly_mean', 'cohort_annual_change_delta', 'cohort_annual_change_percent']
### dataset for all region 1
all_pre_data = pd.DataFrame(columns=keep_cols)

for i in range(len(loop_set)):
    ###read in cohort slice
    cohort_output = pd.read_csv(ensemble_dir + region + loop_set.loc[i, 'path']
                , names = output_col_names)

    # print('cohort rows read in : '+ str(len(cohort_output)))


    # #### match pfts to the current veg, bin by standage for forests
    cohort_output=cohort_output.merge(forest_pfts, on = 'current_veg', how = 'inner')
    # print('cohort rows forest only : '+ str(len(cohort_output)))

    cohort_output['stand_age_bin'] = pd.cut(
        cohort_output['stand_age'], bins=intervals_standage)
    cohort_output['stand_age_interval_min'] = cohort_output['stand_age_bin'].apply(lambda x: x.left).astype(int) + 1
    ###flag potential problems
    cohort_output['monthly_mean'] = cohort_output['monthly_mean'].astype(float)
    # cohort_output['issue'] = 1*cohort_output['monthly_mean'] > 100000

    ### get cohort level change
    cohort_output['cohort_annual_prior_value'] = cohort_output.groupby(['lon', 'lat', 'cohort_number', 'current_veg'])['monthly_mean'].shift()
    cohort_output['cohort_annual_change_delta'] = cohort_output['monthly_mean'] - cohort_output['cohort_annual_prior_value']
    cohort_output['cohort_annual_change_percent'] = cohort_output['cohort_annual_change_delta'] / cohort_output['cohort_annual_prior_value']

    ### calculate temp weights for average calc
    cohort_output['temp_weight_monthly_mean'] = cohort_output['monthly_mean'] * cohort_output['cohort_area'] 
    cohort_output['temp_weight_cohort_annual_change_delta'] = cohort_output['cohort_annual_change_delta'] * cohort_output['cohort_area'] 
    cohort_output['temp_weight_cohort_annual_change_percent'] = cohort_output['cohort_annual_change_percent'] * cohort_output['cohort_area'] 
    # cohort_output[['monthly_mean', 'cohort_annual_change_delta', 'cohort_annual_change_percent']].describe()

    ### summarize by stand age bin
    cohort_output = cohort_output.groupby(
        ['lon','lat','variable','forest_type','current_veg','year','silt_clay','stand_age_interval_min']
    )[[ 'cohort_area','land_area','temp_weight_monthly_mean','temp_weight_cohort_annual_change_delta' , 'temp_weight_cohort_annual_change_percent']].sum()

    # print('cohort rows post binning : '+ str(len(cohort_output)))
    cohort_output=cohort_output.reset_index()
    ### finish weighted average calculation
    cohort_output['monthly_mean'] = (cohort_output['temp_weight_monthly_mean']/cohort_output['cohort_area']).round(5)
    cohort_output['cohort_annual_change_delta'] = (cohort_output['temp_weight_cohort_annual_change_delta']/cohort_output['cohort_area']).round(5)
    cohort_output['cohort_annual_change_percent'] = (cohort_output['temp_weight_cohort_annual_change_percent']/cohort_output['cohort_area']).round(5)
    cohort_output = cohort_output.loc[:, ~cohort_output.columns.str.contains('temp_weight')]
    ### get relevant info for group, model, scenario
    cohort_output['model'] = loop_set.loc[i,'model']
    cohort_output['grid_group'] = loop_set.loc[i,'grid_group']

    all_pre_data = pd.concat([all_pre_data, cohort_output])
    print(f'all pre data {i} : '+ str(len(all_pre_data)))


all_pre_data.to_csv(output_dir_path+region+var+'_pre_data.csv'
                        ,index = False)



