#!/bin/bash -l
  
# setting name of job
#SBATCH -J post_equil

# setting standard error output
#SBATCH -e out/output_%j.txt

# setting standard output
#SBATCH -o out/output_%j.txt
#SBATCH -p bmm

#SBATCH --nodes=1
#SBATCH --mem=100G

# setting the max time
#SBATCH -t 25:00:00

# mail alerts at beginning and end of job
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END

# send mail here
#SBATCH --mail-user=srauschenbach@ucdavis.edu

cd ${SLURM_SUBMIT_DIR}

region=$1
# var=$2

srun /home/smmrrr/miniconda3/envs/condaforge/bin/python3.10 cru_historical_summary.py $region
# srun /home/smmrrr/miniconda3/envs/condaforge/bin/python3.10 post_equil_summary.py $region $var

