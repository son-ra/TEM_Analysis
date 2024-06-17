#!/usr/bin/env python
# coding: utf-8



import matplotlib.pyplot as plt
import numpy as np

import gpflow
import pandas as pd
import os
import matplotlib.pyplot as plt
import re
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
import seaborn as sns
import statsmodels.api as sm
import time
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score
import statsmodels.api as sm
import tensorflow as tf




model_data = pd.read_csv('/home/smmrrr/TEM_Analysis/TEM_Analysis/region_3_test_model_data_conif_vegc.csv')
unique_bins = sorted(model_data.stand_age_interval_min.unique())
bin_to_ordinal = {bin_val: idx for idx, bin_val in (enumerate(unique_bins))}
print(bin_to_ordinal, flush = True)
model_data['ordinal_stand_age'] = model_data['stand_age_interval_min'].map(bin_to_ordinal)
model_data['ordinal_stand_age'].describe()
# model_data = model_data.loc[model_data['year']>=1900]




variables_to_compare = ['monthly_mean', 'tswrf_v11', 'tmp', 'precip', 'dtr', 'vpr', 'wind','co2','Ndep_Trendy']

base_comparison = model_data.loc[model_data['year'].between(1900,1950)].groupby(
    ['lon','lat','ordinal_stand_age'])[variables_to_compare].mean().reset_index()


model_data=model_data.merge(base_comparison, on = ['lon','lat','ordinal_stand_age'], suffixes = ('_ts', '_base'))
model_data=model_data.loc[model_data['monthly_mean_base']!=0]
# Iterate over the list of variables and create new columns in model_data for their ratios
for var in variables_to_compare:
    ts_column = f"{var}_ts"     # Time series data column name
    base_column = f"{var}_base" # Baseline data column name
    ratio_column = f"{var}_ratio" # Name for the new ratio column

    # Compute the ratio and create a new column in model_data
    if (var =='precip'):
        model_data[ratio_column] = model_data[ts_column] / model_data[base_column]
    else:
        model_data[ratio_column] = model_data[ts_column] - model_data[base_column]




model_data = model_data.loc[model_data['year']>=1950]
# model_data = model_data.loc[model_data['monthly_mean_ratio']<=3]




model_data.columns




# Define the features and target variable
X = np.array(model_data[['stand_age_interval_min','tswrf_v11_ratio', 'tmp_ratio', 'precip_ratio',
       'dtr_ratio', 'vpr_ratio', 'wind_ratio', 'co2_ratio',
       'Ndep_Trendy_ratio']])
Y = np.array(model_data['monthly_mean_ratio'])
# Y = np.sqrt(model_data['monthly_mean_ratio'])

# Split the data into training and testing sets (80% train, 20% test)
# randomness can be controlled with a defined `random_state`
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.3, random_state=42)
# Y = np.array(
#     model_data.loc[:, 'monthly_mean_ratio']
# )
# X = np.array(
#      # model_data.loc[model_data['year']>=2020,['ordinal_stand_age']]
#      model_data.loc[:,['ordinal_stand_age','tmp_ratio']]
# )
Y = Y.reshape(len(Y),1)






# rng = np.random.default_rng(1234)
# n_inducing = 500




rng = np.random.default_rng(1234)

# Calculate the percentiles (assuming X is sorted, if not, you need to sort it first)
# "percentiles" is an array of percentiles to calculate
percentiles = [10, 25, 50, 75, 90]
percentile_indices = np.percentile(np.arange(len(Y)), percentiles).astype(int)
percentile_indices




rng = np.random.default_rng(12345)
bin_size = 1200
# Calculate the percentile values on Y
percentiles = [0, 10, 25, 50, 75, 90, 100]
percentile_values = np.percentile(Y_train, percentiles)
print(percentile_values, flush = True)
subset_indices = np.array([])
# subset_indices= subset_indices.reshape((0, 1))
# For each pair of percentile values, select the indices of 100 points from within that range
for i in range(len(percentile_values) - 1):
    # Get the value range for the current bin
    low, high = percentile_values[i], percentile_values[i+1]
    
    # Find the indices where Y falls within the current percentile range 
    # Assuming Y is 1D and has the same length as the rows or columns of X
    in_range_indices = np.array(np.where((Y_train >= low) & (Y_train < high)))
    print(in_range_indices, flush = True)
    in_range_indices=in_range_indices.reshape(in_range_indices.shape[1],1)
    # Randomly select up to 100 indices within this range
    # Here we are careful to only take as many indices as are available if there are fewer than 100
    selected_indices = rng.choice(in_range_indices, size= bin_size, replace=False)
    # selected_indices=selected_indices.reshape()
    # Extend the subset_indices list with the selected indices
    if (i==0):
        subset_indices=selected_indices
    else:
        subset_indices=np.vstack([subset_indices,selected_indices])
# subset_indices.shape
# Using the selected indices, we can now reference the corresponding rows from X
inducing_variable = X_train[subset_indices.flatten(),:]








model = gpflow.models.SGPR(
    (X, Y),
    kernel=gpflow.kernels.RBF(),
    # kernel=gpflow.kernels.SquaredExponential(),
    inducing_variable=inducing_variable,
        # noise_variance=1.0  # Set to some reasonable initial value
)




print(gpflow.utilities.print_summary(model, "notebook"), flush = True)





start_time = time.time()
adam_optimizer = tf.optimizers.Adam(learning_rate=0.1)

# Run the optimization loop
# Perform a number of optimization steps
num_iterations = 1000  # Choose an appropriate number of iterations for your problem
for i in range(num_iterations):
    adam_optimizer.minimize(model.training_loss, model.trainable_variables)
    if (i % 100 ==0):
        print(i, flush = True)
        elapsed_time_minutes = (time.time() - start_time) / 60
        print(f"Elapsed time: {elapsed_time_minutes:.2f} minutes", flush = True)






print(gpflow.utilities.print_summary(model, "notebook"), flush = True)
###save model
model.compiled_predict_f = tf.function(
    lambda Xnew: model.predict_f(Xnew, full_cov=False),
    input_signature=[tf.TensorSpec(shape=[None, X_train.shape[1]], dtype=tf.float64)],
)
model.compiled_predict_y = tf.function(
    lambda Xnew: model.predict_y(Xnew, full_cov=False),
    input_signature=[tf.TensorSpec(shape=[None, X_train.shape[1]], dtype=tf.float64)],
)

save_dir = "/home/smmrrr/TEM_Analysis/TEM_Analysis/models/"
save_name = "gp_7200ip_1000iter_all_vars"
tf.saved_model.save(model, save_dir+save_name)




# loaded_model = tf.saved_model.load( save_dir+save_name)




mean, var =  model.predict_y(
X_test
)

Y_pred = mean.numpy().flatten()
# Y_test = np.array(model_data.loc[model_data['year'].between(1950,2020),'monthly_mean_ratio'])

# Calculate the sum of squares of residuals
SS_res = np.sum((Y_test - Y_pred) ** 2)

# Calculate the total sum of squares
SS_tot = np.sum((Y_test - np.mean(Y_test)) ** 2)
rmse = np.sqrt(SS_res/len(Y_test))
# Calculate the R² score
r2_score = 1 - (SS_res / SS_tot)
print("Test RMSE: ",rmse, flush = True)
print("Test R2: ",r2_score, flush = True)





mean, var = model.predict_y(
#     np.array(
#      model_data.loc[model_data['year'].between(1950,2020),[['tmp_ratio', 'co2_ratio', 'ordinal_stand_age']]]
# )
X_train
)

Y_pred = mean.numpy().flatten()
# Y_test = np.array(model_data.loc[model_data['year'].between(1950,2020),'monthly_mean_ratio'])

# Calculate the sum of squares of residuals
SS_res = np.sum((Y_train - Y_pred) ** 2)

# Calculate the total sum of squares
SS_tot = np.sum((Y_train - np.mean(Y_train)) ** 2)
rmse = np.sqrt(SS_res/len(Y_test))
# Calculate the R² score
r2_score = 1 - (SS_res / SS_tot)
print("Train RMSE: ",rmse, flush = True)
print("Train R2: ",r2_score, flush = True)

