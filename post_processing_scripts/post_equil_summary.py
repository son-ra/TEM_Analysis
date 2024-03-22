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

print(region)

models = [
'AWIxxCMxx1xx1xxMR', 'BCCxxCSM2xxMR', 'CanESM5', 'MIROC6', 'MPIxxESM1xx2xxHR', 'MPIxxESM1xx2xxLR', 'MRIxxESM2xx0'
]




ensemble_dir = '/group/moniergrp/TEM_Large_Ensemble/run_support_files/large_ensemble/'

output_dir_path = '/group/moniergrp/TEM_Large_Ensemble/output_files/' 



all_region = pd.DataFrame()
all_area = pd.DataFrame()

# for region in regions:
for model in models:
    files = os.listdir(ensemble_dir+region+'/pre_data/'+model+'/var_out/')
    for file in files:
        data = pd.read_csv(ensemble_dir+region+'/pre_data/'+model+'/var_out/'+file, names = output_col_names)
        if len(data) > 0:
            # print(len(data))
            data=data.merge(forest_pfts, on = 'current_veg', how = 'inner')
            # print(len(data))

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

            data = data.groupby(
                ['lon','lat','variable','forest_type','current_veg','year','silt_clay','region']
            )[data.columns[data.columns.str.contains('weight|area')]
            ].sum()
            # print(len(data))
            # ###sum up by lat lon year var

            # ####recalculate values
            data=data.reset_index()
            # ### finish weighted average calculation
            data['monthly_mean'] = (data['monthly_mean_weight']/ data['cohort_area']).round(2)
            data['Jan'] = (data['Jan_weight']/ data['cohort_area']).round(2)
            data['Feb'] = (data['Feb_weight']/ data['cohort_area']).round(2)
            data['Mar'] = (data['Mar_weight']/ data['cohort_area']).round(2)
            data['Apr'] = (data['Apr_weight']/ data['cohort_area']).round(2)
            data['May'] = (data['May_weight']/ data['cohort_area']).round(2)
            data['Jun'] = (data['Jun_weight']/ data['cohort_area']).round(2)
            data['Jul'] = (data['Jul_weight']/ data['cohort_area']).round(2)
            data['Aug'] = (data['Aug_weight']/ data['cohort_area']).round(2)
            data['Sep'] = (data['Sep_weight']/ data['cohort_area']).round(2)
            data['Oct'] = (data['Oct_weight']/ data['cohort_area']).round(2)
            data['Nov'] = (data['Nov_weight']/ data['cohort_area']).round(2)
            data['Dec'] = (data['Dec_weight']/ data['cohort_area']).round(2)

            # ###give relevant information
            data['model'] = model
            data['file'] = file

            all_region = pd.concat([all_region, data])
### save after region
all_region.to_csv(output_dir_path+region+'/lat_lon_year_var_equil.csv', index=False)

all_region = all_region.groupby(
    ['lon','lat','variable','forest_type','current_veg','silt_clay','region']
)[all_region.columns[all_region.columns.str.contains('weight|area')]
].sum()

all_region['monthly_mean'] = (all_region['monthly_mean_weight']/ all_region['cohort_area']).round(2)
all_region['Jan'] = (all_region['Jan_weight']/ all_region['cohort_area']).round(2)
all_region['Feb'] = (all_region['Feb_weight']/ all_region['cohort_area']).round(2)
all_region['Mar'] = (all_region['Mar_weight']/ all_region['cohort_area']).round(2)
all_region['Apr'] = (all_region['Apr_weight']/ all_region['cohort_area']).round(2)
all_region['May'] = (all_region['May_weight']/ all_region['cohort_area']).round(2)
all_region['Jun'] = (all_region['Jun_weight']/ all_region['cohort_area']).round(2)
all_region['Jul'] = (all_region['Jul_weight']/ all_region['cohort_area']).round(2)
all_region['Aug'] = (all_region['Aug_weight']/ all_region['cohort_area']).round(2)
all_region['Sep'] = (all_region['Sep_weight']/ all_region['cohort_area']).round(2)
all_region['Oct'] = (all_region['Oct_weight']/ all_region['cohort_area']).round(2)
all_region['Nov'] = (all_region['Nov_weight']/ all_region['cohort_area']).round(2)
all_region['Dec'] = (all_region['Dec_weight']/ all_region['cohort_area']).round(2)

##summarize by lat, lon, var
all_region['run_region'] = region
all_region = all_region.reset_index()
# all_area = pd.concat([all_area , all_region])

all_region.to_csv(output_dir_path+region+'/lat_lon_equil.csv', index=False)

