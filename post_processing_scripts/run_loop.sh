#!/bin/bash -l 

#!/bin/bash

# region='region_5/'
# variables=('GPP' 'VEGC' 'NETNMIN' 'LAI' 'SOILORGC' 'AVAILN')
# variables=('GPP' 'VEGINNPP' 'NCE' 'VEGC' 'NETNMIN' 'NPP' 'LAI' 'SOILORGC' 'AVAILN' 'VSM' 'NEP')

# regions=('region_10' 'region_17' 'region_14' 'region_2' 'region_7' 'region_24' 'region_9')
# regions=('region_1' 'region_21' 'region_5' 'region_6' 'region_20' 'region_8' 'region_13' 'region_27' 'region_19' 'region_28' 'region_23')
# regions=('region_4' 'region_11' 'region_16' 'region_18' 'region_25')
# regions=('region_11' 'region_16' 'region_18' 'region_25')

regions=('region_12' 'region_14' 'region_15' 'region_22' 'region_26' 'region_29')

for region in "${regions[@]}"
do
    sbatch /home/smmrrr/TEM_Analysis/TEM_Analysis/post_processing_scripts/submit_job.sh "$region" 
done
