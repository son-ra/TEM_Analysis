#!/bin/bash -l
  
# setting name of job
#SBATCH -J correl_tair


# setting standard error output
#SBATCH -e sterror_%j.txt

# setting standard output
#SBATCH -o stdoutput_%j.txt
# setting medium priority
#SBATCH -p bmh

##SBATCH --nodes=1
#SBATCH --mem=70G
##SBATCH --ntasks=1
###SBATCH --cpus-per-task=1

# setting the max time
#SBATCH -t 20:00:00

# mail alerts at beginning and end of job
##SBATCH --mail-type=BEGIN
#SBATCH --mail-type=FAIL

# send mail here
#SBATCH --mail-user=srauschenbach@ucdavis.edu

srun /home/smmrrr/miniconda3/envs/condaforge/bin/python3.10 /home/smmrrr/TEM_Analysis/TEM_Analysis/test_parallel_run/tair_cor_dataset.py
