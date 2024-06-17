#!/bin/bash -l
  
# setting name of job
#SBATCH -J gp720_5000

# setting standard error output
#SBATCH -e out/output_%j.txt

# setting standard output
#SBATCH -o out/output_%j.txt
#SBATCH -p bmm

#SBATCH --nodes=1
#SBATCH --mem=100G

# setting the max time
#SBATCH -t 400:00:00

# mail alerts at beginning and end of job
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END

# send mail here
#SBATCH --mail-user=srauschenbach@ucdavis.edu

cd ${SLURM_SUBMIT_DIR}


srun /home/smmrrr/miniconda3/envs/condaforge/bin/python3.10 GP_720ip_5000iter_all_vars.py 

