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
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("i", help = '')
args = parser.parse_args()

#assign args to text values
i = int(args.i)
print(i)
run = 'parallel_new_input'
os.chdir('/home/smmrrr/TEM/TEM_Runs/'+run)

print(os.getcwd()) 

output_paths = glob.glob(r'*.csv[0123456789]*')
input_paths = glob.glob('*.HVD*')

print(len(output_paths))
print(len(input_paths))
ouput_data_path = '/home/smmrrr/TEM_Analysis/usa_runs_processed/'

read_in_data = pd.read_csv('/home/smmrrr/TEM_Analysis/TEM_Analysis/test_parallel_run/all_parallel_variable_info.csv')
print(read_in_data.loc[i])


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

###read in cohort output
cohort_output = pd.read_csv(read_in_data.loc[i, 'output_paths']
            , names = output_col_names)

##read in precipitation files
prec = pd.read_csv(read_in_data.loc[i, 'PREC']
           , names = input_col_names)
par = pd.read_csv(read_in_data.loc[i, 'PAR']
           , names = input_col_names)
clds = pd.read_csv(read_in_data.loc[i, 'CLDS']
           , names = input_col_names)
tair = pd.read_csv(read_in_data.loc[i, 'TAIR']
           , names = input_col_names)
vpr = pd.read_csv(read_in_data.loc[i, 'VPR']
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

clds = pd.melt(clds, id_vars = ['lon','lat', 'Area', 'year'], value_vars = [
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
         var_name='month', value_name='clds'
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

##merge climate variables together
climate_vars = prec.merge(
            par,on = ['lon','lat', 'Area', 'year', 'month']
            ).merge(
            tair ,on = ['lon','lat', 'Area', 'year', 'month']                           
            ).merge(
            clds ,on = ['lon','lat', 'Area', 'year', 'month']                           
            ).merge(
            vpr ,on = ['lon','lat', 'Area', 'year', 'month']                           
            )

##subset to forest veg types 
# cohort_output = cohort_output.loc[cohort_output['current_veg'].isin(forest_vegs)] 
print('clim processed')
##melt cohort output
cohort_output = pd.melt(cohort_output, id_vars = ['lon','lat', 'cohort_area', 'land_area', 'year', 'current_veg', 'stand_age'], value_vars = [
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
cohort_output = cohort_output[cohort_output['cohort_area']>0]
print('cohort processed')

agg_cohort_output = cohort_output.merge(
            climate_vars, how = 'left'
    ,on = ['lon','lat', 'year', 'month']
            )

print('climate and cohort merged')
print(agg_cohort_output.count())

cohort_area = lambda x: np.average(x, weights=agg_cohort_output.loc[x.index, "cohort_area"])  # https://stackoverflow.com/questions/31521027/groupby-weighted-average-and-sum-in-pandas-dataframe
land_area = lambda x: np.average(x, weights=agg_cohort_output.loc[x.index, "land_area"])  # https://stackoverflow.com/questions/31521027/groupby-weighted-average-and-sum-in-pandas-dataframe



merged_dataset = agg_cohort_output.groupby([
        'month','year','current_veg', 'stand_age']).agg(cohort_area=('cohort_area', 'sum'), total_area=('land_area', 'sum'),
                                                                              value_weighted=('value', cohort_area), 
                                                                           prec = ('prec', land_area),
                                                                           par = ('par', land_area),
                                                                           tair = ('tair', land_area),
                                                                           clds = ('clds', land_area),
                                                                           vpr = ('vpr', land_area))
merged_dataset.rename(columns={'value_weighted':read_in_data.loc[i, 'output_var'] + '_weighted'}, inplace = True)
print('rename')


# agg_cohort_output.to_csv(ouput_data_path+'merged_dataset_'+read_in_data.loc[i, 'output_group']+'.csv', index=False)
print(merged_dataset.count())

merged_dataset= merged_dataset.reset_index()
merged_dataset.to_csv(ouput_data_path+read_in_data.loc[i, 'output_var']+'_'+str(read_in_data.loc[i, 'output_group'])+'_'+'processed.csv')
forest_vegs = [4, 5, 6, 8, 9, 10, 11, 16, 17, 18, 19, 20, 25, 33]
forests = merged_dataset.loc[merged_dataset['current_veg'].isin(forest_vegs)]
print(forests.count())
forests.to_csv(ouput_data_path+'forests_'+read_in_data.loc[i, 'output_var']+'_'+str(read_in_data.loc[i, 'output_group'])+'_'+'processed.csv')
