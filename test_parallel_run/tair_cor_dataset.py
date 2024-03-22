#!/usr/bin/env python


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
import metpy  # accessor needed to parse crs
import calendar
import argparse
import seaborn as sns
from shapely.geometry import Point
import geopandas
from geodatasets import get_path
import glob


cmip6 = glob.glob(r'/home/smmrrr/cleaned_climate_input/CMIP6/*tair.csv')

print(len(cmip6))


file = cmip6[0]
model_merge = pd.read_csv(file, names = ["lon", 'lat','var' ,'Area', 'year', 'sum', 'max', 'average'
 , 'min', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'
 , 'Nov', 'Dec', 'Area_Name']
               )
model_merge = model_merge.loc[model_merge['year']>= 2015]

model_merge = pd.melt(model_merge , id_vars = ['lon','lat', 'Area', 'year'], value_vars = [
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
         var_name='month', value_name=re.sub(r'/home/smmrrr/cleaned_climate_input/CMIP6/|.csv', '',file)
        ,col_level=0)




for file in cmip6[1:38]:

    model = pd.read_csv(file, names = ["lon", 'lat','var' ,'Area', 'year', 'sum', 'max', 'average'
     , 'min', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'
     , 'Nov', 'Dec', 'Area_Name']
                   )
    model = model.loc[model['year']>= 2015]

    model = pd.melt(model , id_vars = ['lon','lat', 'Area', 'year'], value_vars = [
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
             var_name='month', value_name=re.sub(r'/home/smmrrr/cleaned_climate_input/CMIP6/|.csv', '',file)
            ,col_level=0)
    
    model_merge = model_merge.merge(model, on = ['lon','lat', 'Area', 'year', 'month'], how='left')
    print(file, ' ', len(model_merge))
    
model_merge.to_csv('/home/smmrrr/TEM_Analysis/TEM_Analysis/test_parallel_run/model_merge_tair_all_info.csv')
    
    
