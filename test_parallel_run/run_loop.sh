#!/bin/bash -l 

for ((i=0; i<2; i++))
do
    # export loopnum=$i
    sbatch ~/TEM_Analysis/TEM_Analysis/test_parallel_run/submit_array_job.sh $i
done
