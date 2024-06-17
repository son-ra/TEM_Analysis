#!/usr/bin/env python
# coding: utf-8



import os
import matplotlib.pyplot as plt
import re
import numpy as np
from scipy import stats
#import optshrink as opt # package we create
import numpy as np
# import scipy.io as sio
import h5py
import matplotlib.pyplot as plt
import pandas as pd
import xarray as xr
import cartopy.crs as ccrs
import seaborn as sns
from shapely.geometry import Point
import geopandas as gp
from geodatasets import get_path
from shapely.geometry import Polygon
import argparse




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



# regions = ['region_1',
# 'region_2',
# 'region_3',
# 'region_4',
# 'region_5',
# 'region_8',
# 'region_20',
# 'region_6',
# 'region_7',
# 'region_19',
# 'region_21']
parser = argparse.ArgumentParser()
parser.add_argument("region", help = '')
args = parser.parse_args()

#assign args to text values
region = args.region

print(region, flush = True)



ensemble_dir = '/group/moniergrp/TEM_Large_Ensemble/run_support_files/ssp370_future_runs/'
ensemble_model = 'CanESM5xx1'
output_dir_path = '/group/moniergrp/TEM_Large_Ensemble/output_files/CanESM5xx1_ssp370/' 
intervals_standage = np.concatenate((np.arange(-1, 100, 5),np.array([124, 149, 3000])))



all_region = pd.DataFrame()
all_region_stand_age = pd.DataFrame()

# for region in regions:
files = os.listdir(ensemble_dir+region+"/"+ensemble_model+'/var_out/')
for file in files:
    data = pd.read_csv(ensemble_dir+region+"/"+ensemble_model+'/var_out/'+file, names = output_col_names)
    if len(data) > 0:
        # print(len(data))
        data=data.merge(forest_pfts, on = 'current_veg', how = 'inner')
        # print(len(data))
        data['stand_age_bin'] = pd.cut(
                    data['stand_age'], bins=intervals_standage)
        data['stand_age_interval_min'] = data['stand_age_bin'].apply(lambda x: x.left).astype(int) + 1
        data['file'] = file

        #####create weight for variables
        data['monthly_mean_weight'] = data['monthly_mean']* data['cohort_area']
        data['Jan_weight'] = data['Jan']* data['cohort_area']
        data['Feb_weight'] = data['Feb']* data['cohort_area']
        data['Mar_weight'] = data['Mar']* data['cohort_area']
        data['Apr_weight'] = data['Apr']* data['cohort_area']
        data['May_weight'] = data['May']* data['cohort_area']
        data['Jun_weight'] = data['Jun']* data['cohort_area']
        data['Jul_weight'] = data['Jul']* data['cohort_area']
        data['Aug_weight'] = data['Aug']* data['cohort_area']
        data['Sep_weight'] = data['Sep']* data['cohort_area']
        data['Oct_weight'] = data['Oct']* data['cohort_area']
        data['Nov_weight'] = data['Nov']* data['cohort_area']
        data['Dec_weight'] = data['Dec']* data['cohort_area']


        #####group by stand age bin
        data = data.groupby(
            ['lon','lat','year','variable','stand_age_interval_min','forest_type','current_veg','community_type','silt_clay','region','file']
        )[data.columns[data.columns.str.contains('weight|area')]
        ].sum()
        # ####recalculate values
        data=data.reset_index()
        # ### finish weighted average calculation
        data['monthly_mean'] = (data['monthly_mean_weight']/ data['cohort_area'])
        data['Jan'] = (data['Jan_weight']/ data['cohort_area'])
        data['Feb'] = (data['Feb_weight']/ data['cohort_area'])
        data['Mar'] = (data['Mar_weight']/ data['cohort_area'])
        data['Apr'] = (data['Apr_weight']/ data['cohort_area'])
        data['May'] = (data['May_weight']/ data['cohort_area'])
        data['Jun'] = (data['Jun_weight']/ data['cohort_area'])
        data['Jul'] = (data['Jul_weight']/ data['cohort_area'])
        data['Aug'] = (data['Aug_weight']/ data['cohort_area'])
        data['Sep'] = (data['Sep_weight']/ data['cohort_area'])
        data['Oct'] = (data['Oct_weight']/ data['cohort_area'])
        data['Nov'] = (data['Nov_weight']/ data['cohort_area'])
        data['Dec'] = (data['Dec_weight']/ data['cohort_area'])

        # ###give relevant information

        all_region_stand_age = pd.concat([all_region_stand_age, data])

        ####group by lat/lon/year
        data = data.groupby(
            ['lon','lat','year','variable','forest_type','current_veg','community_type','silt_clay','region','file']
        )[data.columns[data.columns.str.contains('weight|area')]
        ].sum()
        # print(len(data))
        # ###sum up by lat lon year var

        # ####recalculate values
        data=data.reset_index()
        # ### finish weighted average calculation
        data['monthly_mean'] = (data['monthly_mean_weight']/ data['cohort_area'])
        data['Jan'] = (data['Jan_weight']/ data['cohort_area'])
        data['Feb'] = (data['Feb_weight']/ data['cohort_area'])
        data['Mar'] = (data['Mar_weight']/ data['cohort_area'])
        data['Apr'] = (data['Apr_weight']/ data['cohort_area'])
        data['May'] = (data['May_weight']/ data['cohort_area'])
        data['Jun'] = (data['Jun_weight']/ data['cohort_area'])
        data['Jul'] = (data['Jul_weight']/ data['cohort_area'])
        data['Aug'] = (data['Aug_weight']/ data['cohort_area'])
        data['Sep'] = (data['Sep_weight']/ data['cohort_area'])
        data['Oct'] = (data['Oct_weight']/ data['cohort_area'])
        data['Nov'] = (data['Nov_weight']/ data['cohort_area'])
        data['Dec'] = (data['Dec_weight']/ data['cohort_area'])

        # ###give relevant information

        all_region = pd.concat([all_region, data])

### save after region
all_region_stand_age.to_csv(output_dir_path+region+'_lat_lon_year_standage_var.csv', index=False,float_format='%.2f')
all_region.to_csv(output_dir_path+region+'_lat_lon_year_var.csv', index=False,float_format='%.2f')
all_region['run_region'] = region

all_region_area = all_region.groupby(
    ['lon','lat','variable','forest_type','current_veg','community_type','silt_clay','region','run_region']
)[all_region.columns[all_region.columns.str.contains('weight|area')]
].sum()

all_region_area['monthly_mean'] = (all_region_area['monthly_mean_weight']/ all_region_area['cohort_area'])
all_region_area['Jan'] = (all_region_area['Jan_weight']/ all_region_area['cohort_area'])
all_region_area['Feb'] = (all_region_area['Feb_weight']/ all_region_area['cohort_area'])
all_region_area['Mar'] = (all_region_area['Mar_weight']/ all_region_area['cohort_area'])
all_region_area['Apr'] = (all_region_area['Apr_weight']/ all_region_area['cohort_area'])
all_region_area['May'] = (all_region_area['May_weight']/ all_region_area['cohort_area'])
all_region_area['Jun'] = (all_region_area['Jun_weight']/ all_region_area['cohort_area'])
all_region_area['Jul'] = (all_region_area['Jul_weight']/ all_region_area['cohort_area'])
all_region_area['Aug'] = (all_region_area['Aug_weight']/ all_region_area['cohort_area'])
all_region_area['Sep'] = (all_region_area['Sep_weight']/ all_region_area['cohort_area'])
all_region_area['Oct'] = (all_region_area['Oct_weight']/ all_region_area['cohort_area'])
all_region_area['Nov'] = (all_region_area['Nov_weight']/ all_region_area['cohort_area'])
all_region_area['Dec'] = (all_region_area['Dec_weight']/ all_region_area['cohort_area'])

##summarize by lat, lon, var
all_region_area = all_region_area.reset_index()

all_region_area.to_csv(output_dir_path+region+'_lat_lon.csv', index=False,float_format='%.2f')


all_region_year = all_region.groupby(
    ['year','variable','forest_type','current_veg','community_type', 'run_region']
)[all_region.columns[all_region.columns.str.contains('weight|area')]
].sum()

all_region_year['monthly_mean'] = (all_region_year['monthly_mean_weight']/ all_region_year['cohort_area'])
all_region_year['Jan'] = (all_region_year['Jan_weight']/ all_region_year['cohort_area'])
all_region_year['Feb'] = (all_region_year['Feb_weight']/ all_region_year['cohort_area'])
all_region_year['Mar'] = (all_region_year['Mar_weight']/ all_region_year['cohort_area'])
all_region_year['Apr'] = (all_region_year['Apr_weight']/ all_region_year['cohort_area'])
all_region_year['May'] = (all_region_year['May_weight']/ all_region_year['cohort_area'])
all_region_year['Jun'] = (all_region_year['Jun_weight']/ all_region_year['cohort_area'])
all_region_year['Jul'] = (all_region_year['Jul_weight']/ all_region_year['cohort_area'])
all_region_year['Aug'] = (all_region_year['Aug_weight']/ all_region_year['cohort_area'])
all_region_year['Sep'] = (all_region_year['Sep_weight']/ all_region_year['cohort_area'])
all_region_year['Oct'] = (all_region_year['Oct_weight']/ all_region_year['cohort_area'])
all_region_year['Nov'] = (all_region_year['Nov_weight']/ all_region_year['cohort_area'])
all_region_year['Dec'] = (all_region_year['Dec_weight']/ all_region_year['cohort_area'])

##summarize by lat, lon, var
all_region_year = all_region_year.reset_index()

all_region_year.to_csv(output_dir_path+region+'_year.csv', index=False,float_format='%.2f')

