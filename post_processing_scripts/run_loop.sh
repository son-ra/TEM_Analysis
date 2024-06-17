#!/bin/bash -l 

regions=('region_14' 'region_27' 'region_29')

# regions=('region_11' 'region_14' 'region_17' 'region_2'   'region_22' 'region_25' 'region_28' 'region_4' 'region_7' 
# 'region_1' 'region_12' 'region_15' 'region_18' 'region_20' 'region_23' 'region_26' 'region_29' 'region_5' 'region_8'
# 'region_10' 'region_13' 'region_16' 'region_19' 'region_21' 'region_24' 'region_27' 'region_3' 'region_6' 'region_9')


for region in "${regions[@]}"
do
echo $region
    sbatch /home/smmrrr/TEM_Analysis/TEM_Analysis/post_processing_scripts/submit_job.sh "$region" 
done
